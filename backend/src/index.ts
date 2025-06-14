// backend/src/index.ts
import 'dotenv/config';
import express, { Express, Request, Response } from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';

//  all route files
import authRoutes from './routes/auth';
import noteRoutes from './routes/notes';
import userRoutes from './routes/users';
import scheduleRoutes from './routes/schedules';
import statusRoutes from './routes/status'; 

// --- INITIALIZATION ---
const app: Express = express();
const port = process.env.PORT || 8000;
const prisma = new PrismaClient();

// --- MIDDLEWARE ---
app.use(cors());
app.use(express.json());
// To parse the form data Google sends
app.use(express.urlencoded({ extended: true })); 

// --- ROUTES ---
app.get('/api/test', (req: Request, res: Response) => {
  res.json({ message: 'Success! The PeakSmart API is running.' });
});

// All other app routes are mounted here from their separate files.
app.use('/api/auth', authRoutes);
app.use('/api/notes', noteRoutes);
app.use('/api/users', userRoutes);
app.use('/api/schedules', scheduleRoutes);
app.use('/api/status', statusRoutes);

// --- SERVER STARTUP  & SHUTDOWN---
const server = app.listen(port, () => {
    console.log(`[server]: Server is running at http://localhost:${port}/api/test`);
});

const shutdown = () => {
    console.log('Shutting down server...');
    server.close(() => {
        console.log('HTTP server closed.');
        prisma.$disconnect().then(() => {
            console.log('Prisma client disconnected.');
            process.exit(0);
        });
    });
};
process.on('SIGTERM', shutdown);
process.on('SIGINT', shutdown);