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
// src/index.ts
require("dotenv/config");
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const client_1 = require("@prisma/client");
const auth_1 = __importDefault(require("./routes/auth"));
const notes_1 = __importDefault(require("./routes/notes"));
const users_1 = __importDefault(require("./routes/users"));
const schedules_1 = __importDefault(require("./routes/schedules"));
// --- INITIALIZATION ---
const app = (0, express_1.default)();
const port = process.env.PORT || 8000;
const prisma = new client_1.PrismaClient();
// --- MIDDLEWARE ---
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// --- ROUTES ---
app.get('/api/test', (req, res) => {
    res.json({ message: 'Success! The PeakSmart API is running.' });
});
app.get('/api/schedules/:provider', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { provider } = req.params;
        if (!provider || (provider.toUpperCase() !== 'MEA' && provider.toUpperCase() !== 'PEA')) {
            res.status(400).json({ message: 'Provider must be MEA or PEA' });
            return;
        }
        const schedules = yield prisma.peakSchedule.findMany({
            where: { provider: provider.toUpperCase() }
        });
        res.status(200).json(schedules);
    }
    catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error fetching schedules' });
    }
}));
app.use('/api/auth', auth_1.default);
app.use('/api/notes', notes_1.default);
app.use('/api/users', users_1.default);
app.use('/api/schedules', schedules_1.default);
// --- SERVER STARTUP ---
const server = app.listen(port, () => {
    console.log(`[server]: Server is running at http://localhost:${port}/api/test`);
    console.log(`[server]: Check schedules updateded http://localhost:${port}/api/schedules/:provider`);
});
// --- GRACEFUL SHUTDOWN ---
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
