// backend/src/routes/auth.ts
import express, { Request, Response, Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
import { OAuth2Client } from 'google-auth-library';

const prisma = new PrismaClient();
const router: Router = express.Router();
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const generateTokens = (userId: string) => {
  const accessToken = jwt.sign({ userId }, process.env.JWT_TOKEN_SECRET as string, { expiresIn: '1d' });
  const refreshToken = jwt.sign({ userId }, process.env.JWT_TOKEN_REFRESH_SECRET as string, { expiresIn: '7d' });
  return { accessToken, refreshToken };
};

// --- LOGIN ROUTE ---
router.post('/login', async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required' });
    }

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.password) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const { accessToken, refreshToken } = generateTokens(user.id);
    const userResponse = {
      id: user.id,
      email: user.email,
      name: user.name,
      provider: user.provider,
      avatarUrl: user.avatarUrl
    };
    res.status(200).json({ accessToken, refreshToken, user: userResponse });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Server error during login' });
  }
});

// --- GOOGLE SIGN-IN ROUTE ---
router.post('/google-signin', async (req: Request, res: Response) => {
    try {
        const { token } = req.body;
        if (!token) {
            return res.status(400).json({ message: 'Google token is required' });
        }

        const ticket = await googleClient.verifyIdToken({
            idToken: token,
            audience: process.env.GOOGLE_CLIENT_ID,
        });

        const payload = ticket.getPayload();
        if (!payload || !payload.sub || !payload.email || !payload.name) {
            return res.status(400).json({ message: 'Invalid Google token' });
        }

        const { sub: googleId, email, name, picture: avatarUrl } = payload;
        
        let user = await prisma.user.findFirst({ where: { googleId } });

        if (!user) {
            // Check if a user with that email already exists (e.g., from password signup)
            user = await prisma.user.findUnique({ where: { email }});
            
            if (user) {
                // If user exists, link the Google ID to their account
                user = await prisma.user.update({
                    where: { email },
                    data: { googleId, avatarUrl: user.avatarUrl ?? avatarUrl },
                });
            } else {
                // If no user exists with that email or googleId, create a new one
                user = await prisma.user.create({
                    data: {
                        email,
                        name,
                        googleId,
                        avatarUrl,
                        // Provider is left null, user will be prompted to select it in the app
                    },
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
router.post('/register', async (req: Request, res: Response) => {
    try {
        const { name, email, password } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ message: 'Name, email, and password are required' });
        }

        const existingUser = await prisma.user.findUnique({ where: { email } });
        if (existingUser) {
            return res.status(400).json({ message: 'User with this email already exists' });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = await prisma.user.create({
            data: {
                name,
                email,
                password: hashedPassword,
                // Provider is intentionally left null. 
                // The app will force the user to select one after registration.
            },
        });

        const { accessToken, refreshToken } = generateTokens(newUser.id);
        const userResponse = { id: newUser.id, email: newUser.email, name: newUser.name, provider: newUser.provider, avatarUrl: newUser.avatarUrl };
        res.status(201).json({ accessToken, refreshToken, user: userResponse });

    } catch (error) {
        console.error('Register Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// --- PASSWORD MANAGEMENT ROUTES ---
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

export default router;