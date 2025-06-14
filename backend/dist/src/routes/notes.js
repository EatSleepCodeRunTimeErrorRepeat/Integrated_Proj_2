"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const client_1 = require("@prisma/client");
const authMiddleware_1 = require("../middleware/authMiddleware");
const prisma = new client_1.PrismaClient();
const router = express_1.default.Router();
// --- CREATE A NEW NOTE ---
router.post('/', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { content, date, peakPeriod } = req.body;
        const authorId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!content || !date || !authorId || !peakPeriod) {
            res.status(400).json({ message: 'Content, date, peakPeriod, and authorId are required' });
            return;
        }
        const newNote = yield prisma.note.create({
            data: { content, peakPeriod, date: new Date(date), authorId: authorId },
        });
        res.status(201).json(newNote);
    }
    catch (error) {
        console.error('Create Note Error:', error);
        res.status(500).json({ message: 'Server error creating note' });
    }
}));
// --- GET NOTES FOR A SPECIFIC DATE ---
// FIX: This route now uses a date range for timezone-safe queries.
router.get('/', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const authorId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        const { startDate, endDate } = req.query;
        if (!startDate || !endDate || typeof startDate !== 'string' || typeof endDate !== 'string' || !authorId) {
            res.status(400).json({ message: 'A valid startDate and endDate query parameter are required' });
            return;
        }
        const notes = yield prisma.note.findMany({
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
    }
    catch (error) {
        console.error('Fetch Notes Error:', error);
        res.status(500).json({ message: 'Server error fetching notes' });
    }
}));
// --- UPDATE A NOTE ---
router.put('/:noteId', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { noteId } = req.params;
        const { content, peakPeriod } = req.body;
        const authorId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!content || !peakPeriod) {
            res.status(400).json({ message: 'Content and peakPeriod are required' });
            return;
        }
        const note = yield prisma.note.findUnique({ where: { id: noteId } });
        if (!note || note.authorId !== authorId) {
            res.status(404).json({ message: 'Note not found or user not authorized' });
            return;
        }
        const updatedNote = yield prisma.note.update({
            where: { id: noteId },
            data: { content, peakPeriod },
        });
        res.status(200).json(updatedNote);
    }
    catch (error) {
        console.error('Update Note Error:', error);
        res.status(500).json({ message: 'Server error updating note' });
    }
}));
// --- DELETE A NOTE ---
router.delete('/:noteId', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { noteId } = req.params;
        const authorId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        const note = yield prisma.note.findUnique({ where: { id: noteId } });
        if (!note || note.authorId !== authorId) {
            res.status(404).json({ message: 'Note not found or user not authorized' });
            return;
        }
        yield prisma.note.delete({ where: { id: noteId } });
        res.status(200).json({ message: 'Note deleted successfully' });
    }
    catch (error) {
        console.error('Delete Note Error:', error);
        res.status(500).json({ message: 'Server error deleting note' });
    }
}));
// --- GET ALL NOTES FOR A USER ---
router.get('/all', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const authorId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!authorId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        const notes = yield prisma.note.findMany({
            where: { authorId: authorId },
            orderBy: { date: 'asc' },
        });
        res.status(200).json(notes);
    }
    catch (error) {
        console.error('Fetch All Notes Error:', error);
        res.status(500).json({ message: 'Server error fetching all notes' });
    }
}));
exports.default = router;
