// backend/src/routes/auth.ts

import express, { Request, Response, Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { Prisma, PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
import { OAuth2Client } from 'google-auth-library';

const prisma = new PrismaClient();
const router: Router = express.Router();
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// --- HELPER FUNCTIONS ---

const generateTokens = (userId: string) => {
  const accessToken = jwt.sign({ userId }, process.env.JWT_TOKEN_SECRET as string, { expiresIn: '1d' });
  const refreshToken = jwt.sign({ userId }, process.env.JWT_TOKEN_REFRESH_SECRET as string, { expiresIn: '7d' });
  return { accessToken, refreshToken };
};

// This function now correctly receives the transaction client 'tx'
export const createDefaultNotes = async (userId: string, tx: Prisma.TransactionClient | PrismaClient): Promise<void> => {
    const defaultNotes = [
        { content: 'Avoid using the oven; use a microwave instead.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Postpone laundry until off-peak hours.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Turn up the AC temperature by a degree or two.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Good time to run the dishwasher.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
        { content: 'Charge electric vehicles now.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
        { content: 'Run the washing machine and dryer.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
    ];
    await tx.note.createMany({ data: defaultNotes });
};


// --- AUTHENTICATION ROUTES ---
// --- GOOGLE SIGN-IN ROUTE ---
router.post('/google-signin', async (req: Request, res: Response): Promise<void> => {
    try {
        const { token } = req.body;
        if (!token) {
            res.status(400).json({ message: 'Google token is required' });
            return;
        }

        const ticket = await googleClient.verifyIdToken({
            idToken: token,
            audience: process.env.GOOGLE_CLIENT_ID,
        });

        const payload = ticket.getPayload();
        if (!payload || !payload.sub || !payload.email || !payload.name) {
            res.status(400).json({ message: 'Invalid Google token' });
            return;
        }

        const { sub: googleId, email, name, picture: avatarUrl } = payload;
        
        let user = await prisma.user.findUnique({ where: { googleId } });

        if (!user) {
            user = await prisma.user.findUnique({ where: { email }});
            
            if (user) {
                // Link existing account
                user = await prisma.user.update({
                    where: { email },
                    data: { googleId, avatarUrl: user.avatarUrl ?? avatarUrl },
                });
            } else {
                // **FIX:** Use a transaction to create the user and their notes together.
                user = await prisma.$transaction(async (tx) => {
                    const newUser = await tx.user.create({
                        data: {
                            email,
                            name,
                            googleId,
                            avatarUrl,
                        },
                    });
                    // Pass the transaction client 'tx' to the function
                    await createDefaultNotes(newUser.id, tx);
                    return newUser;
                });
            }
        }

        const { accessToken, refreshToken } = generateTokens(user.id);
        const userResponse = { id: user.id, email: user.email, name: user.name, provider: user.provider, avatarUrl: user.avatarUrl };
        res.status(200).json({ accessToken, refreshToken, user: userResponse });

    } catch (error) {
        console.error('Google Sign-In Error:', error);
        res.status(500).json({ message: 'Internal server error during Google Sign-In' });
    }
});


// --- REGISTER ROUTE ---
router.post('/register', async (req: Request, res: Response): Promise<void> => {
    try {
        const { name, email, password } = req.body;

        if (!name || !email || !password) {
            res.status(400).json({ message: 'Name, email, and password are required' });
            return;
        }

        const existingUser = await prisma.user.findUnique({ where: { email } });
        if (existingUser) {
            res.status(400).json({ message: 'User with this email already exists' });
            return;
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // **FIX:** Use a transaction to create the user and their notes together.
        await prisma.$transaction(async (tx) => {
            const user = await tx.user.create({
                data: {
                    name,
                    email,
                    password: hashedPassword,
                },
            });
            // Pass the transaction client 'tx' to the function
            await createDefaultNotes(user.id, tx);
        });

        res.status(201).json({ message: 'User registered successfully. Please log in.' });
        return;

    } catch (error) {
        console.error('Register Error:', error);
        res.status(500).json({ message: 'Internal server error' });
        return;
    }
});

// --- LOGIN ROUTE ---
router.post('/login', async (req: Request, res: Response): Promise<void> => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            res.status(400).json({ message: 'Email and password are required' });
            return;
        }
        const user = await prisma.user.findUnique({ where: { email } });
        if (!user || !user.password) {
            res.status(401).json({ message: 'Invalid credentials or user logs in with social account.' });
            return;
        }
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            res.status(401).json({ message: 'Invalid credentials' });
            return;
        }
        const { accessToken, refreshToken } = generateTokens(user.id);
        const userResponse = { id: user.id, email: user.email, name: user.name, provider: user.provider, avatarUrl: user.avatarUrl };
        res.status(200).json({ accessToken, refreshToken, user: userResponse });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.post('/verify-password', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { password } = req.body;
        const userId = req.user?.userId;

        if (!userId || !password) {
            res.status(400).json({ message: 'Password is required' });
            return;
        }
        
        const user = await prisma.user.findUnique({ where: { id: userId } });
        
        if (!user || !user.password) {
            res.status(404).json({ message: 'User not found or password not set' });
            return;
        }

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            res.status(401).json({ message: 'Incorrect password' });
            return;
        }
        res.status(200).json({ message: 'Password verified successfully' });
    } catch (error) {
        console.error('Verify Password Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.post('/change-password', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { currentPassword, newPassword } = req.body;
        const userId = req.user?.userId;

        if (!userId || !currentPassword || !newPassword) {
            res.status(400).json({ message: 'All password fields are required' });
            return;
        }
        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user || !user.password) {
            res.status(404).json({ message: 'User not found or password not set' });
            return;
        }
        const isMatch = await bcrypt.compare(currentPassword, user.password);
        if (!isMatch) {
            res.status(401).json({ message: 'Incorrect current password' });
            return;
        }
        const salt = await bcrypt.genSalt(10);
        const hashedNewPassword = await bcrypt.hash(newPassword, salt);
        await prisma.user.update({
            where: { id: userId },
            data: { password: hashedNewPassword },
        });
        res.status(200).json({ message: 'Password updated successfully' });
    } catch (error) {
        console.error('Change Password Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// --- SEARCH NOTES BY CONTENT ---
router.get('/search', protect, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const { q } = req.query; // Search query, e.g., /api/notes/search?q=laundry

    if (!userId) {
      res.status(401).json({ message: 'Not authorized' });
      return;
    }
    if (!q || typeof q !== 'string') {
      res.status(400).json({ message: 'A search query parameter "q" is required.' });
      return;
    }

    const notes = await prisma.note.findMany({
      where: {
        authorId: userId,
        content: {
          contains: q,
          mode: 'insensitive', // Case-insensitive search
        },
      },
      orderBy: {
        date: 'desc',
      },
    });

    res.status(200).json(notes);
  } catch (error) {
    console.error('Search Notes Error:', error);
    res.status(500).json({ message: 'Server error searching notes' });
  }
});

export default router;