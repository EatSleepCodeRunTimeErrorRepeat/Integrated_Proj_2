import express, { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';

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


// --- UPDATE PROVIDER AND RESET NOTES ---
router.put('/me/provider', protect, async (req: AuthRequest, res: Response) => {
    try {
        const { provider } = req.body;
        const userId = req.user?.userId;

        if (!userId) {
            return res.status(401).json({ message: 'Not authorized' });
        }
        if (!provider || (provider !== 'MEA' && provider !== 'PEA')) {
            return res.status(400).json({ message: 'A valid provider (MEA or PEA) is required' });
        }
        
        // This logic now ONLY updates the user's provider in the database.
        // It does not delete or create any notes, preserving all user data.
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
        const { notificationsEnabled, peakHourAlertsEnabled } = req.body;
        const userId = req.user?.userId;

        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        
        const dataToUpdate: { notificationsEnabled?: boolean, peakHourAlertsEnabled?: boolean } = {};

        if (typeof notificationsEnabled === 'boolean') {
            dataToUpdate.notificationsEnabled = notificationsEnabled;
        }
        if (typeof peakHourAlertsEnabled === 'boolean') {
            dataToUpdate.peakHourAlertsEnabled = peakHourAlertsEnabled;
        }

        if (Object.keys(dataToUpdate).length === 0) {
            res.status(400).json({ message: 'A boolean value for notificationsEnabled or peakHourAlertsEnabled is required.' });
            return;
        }

        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: dataToUpdate,
        });
        
        res.status(200).json({ 
            message: 'Preferences updated successfully',
            notificationsEnabled: updatedUser.notificationsEnabled,
            peakHourAlertsEnabled: updatedUser.peakHourAlertsEnabled,
        });

    } catch (error) {
        console.error('Error updating notification preferences:', error);
        res.status(500).json({ message: 'Server error updating preferences' });
    }
});

export default router;
