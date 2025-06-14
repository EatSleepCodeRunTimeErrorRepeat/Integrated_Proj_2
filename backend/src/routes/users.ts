import express, { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
import { createDefaultNotes } from './auth';

const prisma = new PrismaClient();
const router = express.Router();

// --- GET CURRENT USER PROFILE ---
router.get('/me', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const userId = req.user?.userId;
        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        const user = await prisma.user.findUnique({ 
            where: { id: userId },
            select: { id: true, name: true, email: true, provider: true, avatarUrl: true, notificationsEnabled: true }
        });

        if (!user) {
            res.status(404).json({ message: 'User not found' });
            return;
        }
        res.status(200).json(user);
    } catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ message: 'Server error fetching user profile' });
    }
});

// --- UPDATE USER PROFILE (Name and Avatar) ---
router.put('/me', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { name, avatarUrl } = req.body;
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }

        const dataToUpdate: { name?: string; avatarUrl?: string } = {};
        if (name) dataToUpdate.name = name;
        if (avatarUrl) dataToUpdate.avatarUrl = avatarUrl;

        if (Object.keys(dataToUpdate).length === 0) {
            res.status(400).json({ message: 'No update data provided' });
            return;
        }
        
        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: dataToUpdate,
            select: { id: true, name: true, email: true, provider: true, avatarUrl: true, notificationsEnabled: true }
        });

        res.status(200).json(updatedUser);
    } catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ message: 'Server error updating user profile' });
    }
});

// --- FIX: UPDATE PROVIDER (Simplified to prevent deadlocks) ---
router.put('/me/provider', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { provider } = req.body;
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        if (!provider || (provider !== 'MEA' && provider !== 'PEA')) {
            res.status(400).json({ message: 'A valid provider (MEA or PEA) is required' });
            return;
        }
        
        // This now only performs one operation: updating the user's provider.
        // This avoids the transaction deadlock and preserves the user's notes.
        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: { provider: provider },
            select: { id: true, name: true, email: true, provider: true, avatarUrl: true, notificationsEnabled: true }
        });

        res.status(200).json(updatedUser);

    } catch (error) {
        console.error('Error updating provider:', error);
        res.status(500).json({ message: 'Server error updating provider' });
    }
});

// --- UPDATE USER NOTIFICATION PREFERENCES ---
router.put('/me/preferences', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { notificationsEnabled } = req.body;
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        
        if (typeof notificationsEnabled !== 'boolean') {
            res.status(400).json({ message: 'A boolean value for notificationsEnabled is required.' });
            return;
        }

        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: { notificationsEnabled: notificationsEnabled },
        });
        
        res.status(200).json({ 
            message: 'Preferences updated successfully',
            notificationsEnabled: updatedUser.notificationsEnabled 
        });

    } catch (error) {
        console.error('Error updating notification preferences:', error);
        res.status(500).json({ message: 'Server error updating preferences' });
    }
});

export default router;
