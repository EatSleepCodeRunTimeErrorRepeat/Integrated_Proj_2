import express, { Response } from 'express';
import { PrismaClient } from '@prisma/client';
import { protect, AuthRequest } from '../middleware/authMiddleware';
// FIX: Import moment-timezone to handle dates reliably
import moment from 'moment-timezone';

const prisma = new PrismaClient();
const router = express.Router();

// --- CREATE A NEW NOTE ---
router.post('/', protect, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { content, date, peakPeriod } = req.body;
    const authorId = req.user?.userId;

    if (!content || !date || !authorId || !peakPeriod) {
      res.status(400).json({ message: 'Content, date, peakPeriod, and authorId are required' });
      return;
    }

    const newNote = await prisma.note.create({
      data: {
        content,
        peakPeriod,
        // FIX: Explicitly interpret the incoming date string as UTC
        date: moment.tz(date, 'UTC').toDate(),
        authorId: authorId,
      },
    });
    res.status(201).json(newNote);
  } catch (error) {
    console.error('Create Note Error:', error);
    res.status(500).json({ message: 'Server error creating note' });
  }
});

// --- GET NOTES FOR A SPECIFIC DATE ---
router.get('/', protect, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const authorId = req.user?.userId;
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate || typeof startDate !== 'string' || typeof endDate !== 'string' || !authorId) {
      res.status(400).json({ message: 'A valid startDate and endDate query parameter are required' });
      return;
    }
    
    const notes = await prisma.note.findMany({
      where: { 
        authorId: authorId, 
        date: { 
          gte: new Date(startDate), 
          lte: new Date(endDate) 
        } 
      },
      orderBy: { date: 'asc' },
    });

    res.status(200).json(notes);
  } catch (error) {
    console.error('Fetch Notes Error:', error);
    res.status(500).json({ message: 'Server error fetching notes' });
  }
});

// --- UPDATE A NOTE ---
router.put('/:noteId', protect, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { noteId } = req.params;
    const { content, peakPeriod, date } = req.body;
    const authorId = req.user?.userId;

    if (!content || !peakPeriod) {
      res.status(400).json({ message: 'Content and peakPeriod are required' });
      return;
    }

    const note = await prisma.note.findUnique({ where: { id: noteId } });

    if (!note || note.authorId !== authorId) {
      res.status(404).json({ message: 'Note not found or user not authorized' });
      return;
    }

    const dataToUpdate: { content: string; peakPeriod: string; date?: Date } = {
      content,
      peakPeriod,
    };
    if (date) {
      // FIX: Explicitly interpret the incoming date string as UTC
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
router.delete('/:noteId', protect, async (req: AuthRequest, res: Response): Promise<void> => {
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

// --- GET ALL NOTES FOR A USER ---
router.get('/all', protect, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const authorId = req.user?.userId;

    if (!authorId) {
      res.status(401).json({ message: 'Not authorized' });
      return;
    }
    
    const notes = await prisma.note.findMany({
      where: { authorId: authorId },
      orderBy: { date: 'asc' },
    });

    res.status(200).json(notes);
  } catch (error) {
    console.error('Fetch All Notes Error:', error);
    res.status(500).json({ message: 'Server error fetching all notes' });
  }
});

export default router;
