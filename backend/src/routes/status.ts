// backend/src/routes/status.ts

import express, { Response } from 'express';
import { PrismaClient, PeakSchedule } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
import moment from 'moment-timezone';

const prisma = new PrismaClient();
const router = express.Router();

// Helper function to get sorted rules for a given day
const getRulesForDay = async (provider: string, day: moment.Moment): Promise<PeakSchedule[]> => {
    const dayOfWeek = day.day();
    const specificDate = day.clone().startOf('day').toDate();

    const rules = await prisma.peakSchedule.findMany({
        where: {
            provider,
            OR: [{ dayOfWeek }, { specificDate }],
        },
    });

    // Holiday/specific date rules take precedence over regular day-of-week rules
    const specificDayRules = rules.filter(r => r.specificDate);
    if (specificDayRules.length > 0) {
        return specificDayRules.sort((a, b) => a.startTime.localeCompare(b.startTime));
    }
    
    return rules.filter(r => r.dayOfWeek === dayOfWeek).sort((a, b) => a.startTime.localeCompare(b.startTime));
};


router.get('/', protect, async (req: AuthRequest, res: Response): Promise<void> => {
    try {
        const userId = req.user?.userId;
        const user = await prisma.user.findUnique({ where: { id: userId } });

        if (!user || !user.provider) {
             res.status(400).json({ message: 'User provider has not been set.' });
             return;
        }

        const { provider } = user;
        const timeZone = 'Asia/Bangkok';
        const now = moment.tz(timeZone);

        // 1. Get today's rules
        const todaysRules = await getRulesForDay(provider, now);

        // 2. Determine the current status by finding the last applicable rule before "now"
        let isCurrentlyPeak = false; // Default to off-peak
        if (todaysRules.length > 0) {
            // Find the last rule whose start time is before or at the current time
            const applicableRules = todaysRules.filter(rule => {
                const startTime = moment.tz(`${now.format('YYYY-MM-DD')} ${rule.startTime}`, timeZone);
                return startTime.isSameOrBefore(now);
            });
            if (applicableRules.length > 0) {
                isCurrentlyPeak = applicableRules[applicableRules.length - 1].isPeak;
            }
        }

        // 3. Find the next change event
        let nextChangeTime: moment.Moment | null = null;

        // First, look for a change later today
        for (const rule of todaysRules) {
            const startTime = moment.tz(`${now.format('YYYY-MM-DD')} ${rule.startTime}`, timeZone);
            if (startTime.isAfter(now) && rule.isPeak !== isCurrentlyPeak) {
                nextChangeTime = startTime;
                break;
            }
        }

        // If no change today, look for the first change tomorrow
        if (!nextChangeTime) {
            const tomorrowsRules = await getRulesForDay(provider, now.clone().add(1, 'day'));
            if (tomorrowsRules.length > 0) {
                // Find the first rule tomorrow that represents a change from our current state
                const firstRuleTomorrow = tomorrowsRules.find(rule => rule.isPeak !== isCurrentlyPeak);
                if (firstRuleTomorrow) {
                    nextChangeTime = moment.tz(`${now.clone().add(1, 'day').format('YYYY-MM-DD')} ${firstRuleTomorrow.startTime}`, timeZone);
                }
            }
        }

        let timeToNextChangeInSeconds = -1;
        if (nextChangeTime) {
            timeToNextChangeInSeconds = nextChangeTime.diff(now, 'seconds');
        }

        res.status(200).json({
            provider,
            isPeak: isCurrentlyPeak,
            timeToNextChange: timeToNextChangeInSeconds,
        });

    } catch (error) {
        console.error('Error fetching peak status:', error);
        res.status(500).json({ message: 'Server error fetching status' });
    }
});

export default router;