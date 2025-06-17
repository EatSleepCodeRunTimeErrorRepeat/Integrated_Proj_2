import express, { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
import moment from 'moment-timezone';

const prisma = new PrismaClient();
const router = express.Router();

// --- CREATE A NEW NOTE ---
router.post('/', protect, async (req: AuthRequest, res: Response) => {
  try {
    const { content, date, peakPeriod } = req.body;
    const userId = req.user?.userId;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user || !user.provider) {
      return res.status(400).json({ message: 'User or user provider not found.' });
    }

    if (!content || !date || !peakPeriod) {
      return res.status(400).json({ message: 'Content, date, and peakPeriod are required' });
    }

    const newNote = await prisma.note.create({
      data: {
        content,
        peakPeriod,
        provider: user.provider,
        date: moment.tz(date, 'UTC').toDate(),
        authorId: userId as string,
      },
    });
    res.status(201).json(newNote);
  } catch (error) {
    console.error('Create Note Error:', error);
    res.status(500).json({ message: 'Server error creating note' });
  }
});

// --- NEW: SEARCH NOTES BY CONTENT ---
// This route will be used by your search feature.
router.get('/search', protect, async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.user?.userId;
    const { q } = req.query; 

    const user = await prisma.user.findUnique({ where: { id: userId }});
    if (!user || !user.provider) {
        return res.status(400).json({ message: 'User or provider not set.' });
    }

    if (!q || typeof q !== 'string') {
      return res.status(400).json({ message: 'A search query parameter "q" is required.' });
    }

    const notes = await prisma.note.findMany({
      where: {
        authorId: userId,
        provider: user.provider, // Only search notes for the current provider
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


// --- GET NOTES (FOR DATE RANGE OR ALL) ---
// If you call GET /api/notes, it gets all notes for the provider.
// If you call GET /api/notes?startDate=...&endDate=..., it gets notes for that date range.
router.get('/', protect, async (req: AuthRequest, res: Response) => {
  try {
    const authorId = req.user?.userId;
    const { startDate, endDate } = req.query;

    const user = await prisma.user.findUnique({ where: { id: authorId } });
    if (!user || !user.provider) {
      return res.status(400).json({ message: 'User or user provider not found.' });
    }

    const whereClause: any = {
      authorId: authorId,
      provider: user.provider,
    };

    if (startDate && endDate && typeof startDate === 'string' && typeof endDate === 'string') {
      whereClause.date = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      };
    }

    const notes = await prisma.note.findMany({
      where: whereClause,
      orderBy: { date: 'asc' },
    });

    res.status(200).json(notes);
  } catch (error) {
    console.error('Fetch Notes Error:', error);
    res.status(500).json({ message: 'Server error fetching notes' });
  }
});


// --- UPDATE A NOTE ---
router.put('/:noteId', protect, async (req: AuthRequest, res: Response) => {
  try {
    const { noteId } = req.params;
    const { content, peakPeriod, date } = req.body;
    const authorId = req.user?.userId;

    if (!content || !peakPeriod) {
      return res.status(400).json({ message: 'Content and peakPeriod are required' });
    }

    const note = await prisma.note.findUnique({ where: { id: noteId } });

    if (!note || note.authorId !== authorId) {
      return res.status(404).json({ message: 'Note not found or user not authorized' });
    }

    const dataToUpdate: { content: string; peakPeriod: string; date?: Date } = {
      content,
      peakPeriod,
    };
    if (date) {
      dataToUpdate.date = moment.tz(date, 'UTC').toDate();
    }

    const updatedNote = await prisma.note.update({
      where: { id: noteId },
      data: dataToUpdate,
    });

    res.status(200).json(updatedNote);
  } catch (error) {
    console.error('Update Note Error:', error);
    res.status(500).json({ message: 'Server error updating note' });
  }
});

// --- DELETE A NOTE ---
router.delete('/:noteId', protect, async (req: AuthRequest, res: Response) => {
  try {
    const { noteId } = req.params;
    const authorId = req.user?.userId;

    const note = await prisma.note.findUnique({ where: { id: noteId } });

    if (!note || note.authorId !== authorId) {
      res.status(404).json({ message: 'Note not found or user not authorized' });
      return;
    }

    await prisma.note.delete({ where: { id: noteId } });

    res.status(200).json({ message: 'Note deleted successfully' });
  } catch (error) {
    console.error('Delete Note Error:', error);
    res.status(500).json({ message: 'Server error deleting note' });
  }
});

export default router;