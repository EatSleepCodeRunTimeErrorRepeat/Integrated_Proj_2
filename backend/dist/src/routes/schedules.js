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
// --- GET PEAK SCHEDULES BY PROVIDER ---
// Path: GET /api/schedules/:provider
// Note: This route is protected, ensuring only logged-in users can access it.
router.get('/:provider', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { provider } = req.params;
        // Validate the provider parameter
        if (!provider || (provider !== 'MEA' && provider !== 'PEA')) {
            res.status(400).json({ message: 'A valid provider (MEA or PEA) is required' });
            return;
        }
        // Fetch all schedules for the given provider from the database
        const schedules = yield prisma.peakSchedule.findMany({
            where: { provider: provider },
        });
        // If no schedules are found, return an empty array
        if (!schedules) {
            res.status(404).json({ message: 'No schedules found for this provider.' });
            return;
        }
        // Send the schedules back to the client
        res.status(200).json(schedules);
    }
    catch (error) {
        console.error('Error fetching peak schedules:', error);
        res.status(500).json({ message: 'Server error fetching schedules' });
    }
}));
exports.default = router;
