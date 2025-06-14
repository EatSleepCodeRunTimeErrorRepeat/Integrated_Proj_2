// backend/src/routes/status.ts

import express, { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
import moment from 'moment-timezone';

const prisma = new PrismaClient();
const router = express.Router();

// This single endpoint will determine the current peak status and countdown
// for the user's selected provider.
// Endpoint: GET /api/status
router.get('/', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const userId = req.user?.userId;
        const user = await prisma.user.findUnique({ where: { id: userId } });

        if (!user || !user.provider) {
            res.status(400).json({ message: 'User provider has not been set.' });
            return;
        }

        const { provider } = user;
        const timeZone = 'Asia/Bangkok'; // Set the correct timezone for Thailand
        const now = moment().tz(timeZone);
        
        // Find all schedules for the provider
        const schedules = await prisma.peakSchedule.findMany({ where: { provider } });
        
        // Find today's schedule, prioritizing specific holidays over regular weekdays
        const todaySchedule = schedules.find(s => s.specificDate && moment(s.specificDate).tz(timeZone).isSame(now, 'day')) 
            || schedules.find(s => s.dayOfWeek === now.day());

        // Default to OFF_PEAK if no schedule is found for today (e.g., weekends without rules)
        if (!todaySchedule) {
            res.status(200).json({ provider, isPeak: false, message: 'No peak schedule defined for today.' });
            return;
        }
        
        // --- Calculate Current Status and Next Change ---
        const startTime = moment.tz(`${now.format('YYYY-MM-DD')} ${todaySchedule.startTime}`, timeZone);
        const endTime = moment.tz(`${now.format('YYYY-MM-DD')} ${todaySchedule.endTime}`, timeZone);

        // Determine if we are currently within the peak period defined by the schedule
        const isCurrentlyPeak = todaySchedule.isPeak && now.isBetween(startTime, endTime);
        
        let timeToNextChangeInSeconds: number;
        let nextPeriod: 'ON_PEAK' | 'OFF_PEAK';

        if (isCurrentlyPeak) {
            // If we are currently IN a peak period, the next change is when it ends.
            timeToNextChangeInSeconds = endTime.diff(now, 'seconds');
            nextPeriod = 'OFF_PEAK';
        } else {
            // If we are currently OFF-peak, there are two possibilities:
            if (now.isBefore(startTime)) {
                // 1. The peak period for today hasn't started yet.
                timeToNextChangeInSeconds = startTime.diff(now, 'seconds');
                nextPeriod = 'ON_PEAK';
            } else {
                // 2. The peak period for today is already over. We need to find the start of the next day's peak period.
                const tomorrow = now.clone().add(1, 'day');
                const tomorrowSchedule = schedules.find(s => s.specificDate && moment(s.specificDate).tz(timeZone).isSame(tomorrow, 'day')) 
                    || schedules.find(s => s.dayOfWeek === tomorrow.day());

                if (tomorrowSchedule) {
                    const nextStartTime = moment.tz(`${tomorrow.format('YYYY-MM-DD')} ${tomorrowSchedule.startTime}`, timeZone);
                    timeToNextChangeInSeconds = nextStartTime.diff(now, 'seconds');
                    nextPeriod = 'ON_PEAK';
                } else {
                    // Fallback if there's no schedule for tomorrow either (e.g., a long holiday)
                    timeToNextChangeInSeconds = -1; // -1 can signify 'no upcoming change'
                    nextPeriod = 'OFF_PEAK';
                }
            }
        }

        res.status(200).json({
            provider,
            isPeak: isCurrentlyPeak,
            timeToNextChange: timeToNextChangeInSeconds, // This is the countdown in seconds
            nextPeriod,
            scheduleForToday: todaySchedule
        });

    } catch (error) {
        console.error('Error fetching peak status:', error);
        res.status(500).json({ message: 'Server error fetching status' });
    }
});

export default router;