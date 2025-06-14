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

router.post('/register', async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, name } = req.body;
    if (!email || !password || !name) {
      res.status(400).json({ message: 'All fields are required' });
      return;
    }
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      res.status(409).json({ message: 'User with this email already exists' });
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await prisma.$transaction(async (tx) => {
      const newUser = await tx.user.create({ data: { email, name, password: hashedPassword } });
      await createDefaultNotes(newUser.id, tx);
      return newUser;
    });
    
    res.status(201).json({ message: 'User created successfully', userId: user.id });
    
  } catch (error) {
    console.error('Registration Error:', error);
    res.status(500).json({ message: 'Internal server error during registration' });
  }
});

router.post('/login', async (req: Request, res: Response): Promise<void> => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            res.status(400).json({ message: 'Email and password are required' });
            return;
        }
        const user = await prisma.user.findUnique({ where: { email } });
        
        // FIX: Combined guard clause to handle null user or null password.
        if (!user || !user.password) {
            res.status(401).json({ message: 'Invalid credentials' });
            return;
        }

        // Because of the check above, TypeScript now knows user.password is a string.
        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            res.status(401).json({ message: 'Invalid credentials' });
            return;
        }

        const { accessToken, refreshToken } = generateTokens(user.id);
        res.status(200).json({ accessToken, refreshToken, user });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

router.post('/google/signin', async (req: Request, res: Response): Promise<void> => {
    try {
        const { token } = req.body;
        if (!token) {
            res.status(400).json({ message: 'Google token is required' });
            return;
        }

        const ticket = await googleClient.verifyIdToken({
            idToken: token,
            audience: process.env.ANDROID_CLIENT_ID,
        });

        const payload = ticket.getPayload();

        if (!payload || !payload.sub || !payload.email) {
            res.status(400).json({ message: 'Invalid Google token payload.' });
            return;
        }
        
        const { sub: googleId, email, name, picture: avatarUrl } = payload;
        
        let user = await prisma.user.findUnique({ where: { googleId } });

        if (!user) {
            user = await prisma.user.findUnique({ where: { email } });
            if (user) {
                user = await prisma.user.update({ where: { email }, data: { googleId, avatarUrl: user.avatarUrl || avatarUrl }});
            } else {
                user = await prisma.$transaction(async (tx) => {
                    const newUser = await tx.user.create({
                        data: { email, name: name || 'User', googleId, avatarUrl }
                    });
                    await createDefaultNotes(newUser.id, tx);
                    return newUser;
                });
            }
        }
        
        const { accessToken, refreshToken } = generateTokens(user.id);
        res.status(200).json({ accessToken, refreshToken, user });

    } catch (error) {
        console.error('Google Sign-In Error:', error);
        res.status(500).json({ message: 'Internal server error during Google Sign-In' });
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
        
        // FIX: Same combined guard clause as in the login route.
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

export default router;