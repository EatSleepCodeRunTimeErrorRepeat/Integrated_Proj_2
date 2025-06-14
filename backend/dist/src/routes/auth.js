"use strict";
// src/routes/auth.ts
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
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const client_1 = require("@prisma/client");
const authMiddleware_1 = require("../middleware/authMiddleware"); // Import protect and AuthRequest
const prisma = new client_1.PrismaClient();
const router = express_1.default.Router();
const createDefaultNotes = (userId) => __awaiter(void 0, void 0, void 0, function* () {
    const defaultNotes = [
        // On-Peak Tips (more expensive time)
        { content: 'Avoid using the oven; use a microwave instead.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Postpone laundry until off-peak hours.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Turn up the AC temperature by a degree or two.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Ensure all non-essential lights are turned off.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        { content: 'Unplug devices on standby like TVs and game consoles.', peakPeriod: 'ON_PEAK', authorId: userId, date: new Date() },
        // Off-Peak Reminders (cheaper time)
        { content: 'Good time to run the dishwasher.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
        { content: 'Charge electric vehicles now.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
        { content: 'Run the washing machine and dryer.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
        { content: 'Pre-cool your home before on-peak hours start.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
        { content: 'Bake or use other high-energy appliances.', peakPeriod: 'OFF_PEAK', authorId: userId, date: new Date() },
    ];
    yield prisma.note.createMany({ data: defaultNotes });
});
router.post('/register', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password, name } = req.body;
        if (!email || !password || !name) {
            res.status(400).json({ message: 'Email, password, and name are required' });
            return;
        }
        const existingUser = yield prisma.user.findUnique({ where: { email } });
        if (existingUser) {
            res.status(409).json({ message: 'User with this email already exists' });
            return;
        }
        const salt = yield bcryptjs_1.default.genSalt(10);
        const hashedPassword = yield bcryptjs_1.default.hash(password, salt);
        const user = yield prisma.user.create({
            data: { email, name, password: hashedPassword },
        });
        yield createDefaultNotes(user.id);
        const userResponse = {
            id: user.id, email: user.email, name: user.name, createdAt: user.createdAt
        };
        res.status(201).json({ message: 'User created successfully', user: userResponse });
    }
    catch (error) {
        console.error('Registration Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}));
router.post('/login', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            res.status(400).json({ message: 'Email and password are required' });
            return;
        }
        const user = yield prisma.user.findUnique({ where: { email } });
        if (!user) {
            res.status(404).json({ message: 'Invalid credentials' });
            return;
        }
        const isMatch = yield bcryptjs_1.default.compare(password, user.password);
        if (!isMatch) {
            res.status(401).json({ message: 'Invalid credentials' });
            return;
        }
        const accessToken = jsonwebtoken_1.default.sign({ userId: user.id }, process.env.JWT_TOKEN_SECRET, { expiresIn: '1d' });
        const refreshToken = jsonwebtoken_1.default.sign({ userId: user.id }, process.env.JWT_TOKEN_REFRESH_SECRET, { expiresIn: '7d' });
        const userResponse = {
            id: user.id, email: user.email, name: user.name,
        };
        res.status(200).json({ accessToken, refreshToken, user: userResponse });
    }
    catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}));
// --- NEW: CHANGE PASSWORD ---
// Path: POST /api/auth/change-password
router.post('/change-password', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { currentPassword, newPassword } = req.body;
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        if (!currentPassword || !newPassword) {
            res.status(400).json({ message: 'Current password and new password are required' });
            return;
        }
        if (newPassword.length < 6) {
            res.status(400).json({ message: 'New password must be at least 6 characters long' });
            return;
        }
        const user = yield prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            res.status(404).json({ message: 'User not found' });
            return;
        }
        const isMatch = yield bcryptjs_1.default.compare(currentPassword, user.password);
        if (!isMatch) {
            res.status(401).json({ message: 'Incorrect current password' });
            return;
        }
        const salt = yield bcryptjs_1.default.genSalt(10);
        const hashedNewPassword = yield bcryptjs_1.default.hash(newPassword, salt);
        yield prisma.user.update({
            where: { id: userId },
            data: { password: hashedNewPassword },
        });
        res.status(200).json({ message: 'Password updated successfully' });
    }
    catch (error) {
        console.error('Change Password Error:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
}));
exports.default = router;
