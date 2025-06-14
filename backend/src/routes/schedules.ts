import express, { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';

const prisma = new PrismaClient();
const router = express.Router();

// --- GET PEAK SCHEDULES BY PROVIDER ---
// Path: GET /api/schedules/:provider
// Note: This route is protected, ensuring only logged-in users can access it.
router.get('/:provider', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const { provider } = req.params;

        // Validate the provider parameter
        if (!provider || (provider !== 'MEA' && provider !== 'PEA')) {
            res.status(400).json({ message: 'A valid provider (MEA or PEA) is required' });
            return;
        }

        // Fetch all schedules for the given provider from the database
        const schedules = await prisma.peakSchedule.findMany({
            where: { provider: provider },
        });

        // If no schedules are found, return an empty array
        if (!schedules) {
            res.status(404).json({ message: 'No schedules found for this provider.' });
            return;
        }

        // Send the schedules back to the client
        res.status(200).json(schedules);

    } catch (error) {
        console.error('Error fetching peak schedules:', error);
        res.status(500).json({ message: 'Server error fetching schedules' });
    }
});

export default router;
