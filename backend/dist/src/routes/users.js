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
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
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
// --- GET CURRENT USER PROFILE ---
router.get('/me', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        const user = yield prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            res.status(404).json({ message: 'User not found' });
            return;
        }
        const { password } = user, userWithoutPassword = __rest(user, ["password"]);
        res.status(200).json(userWithoutPassword);
    }
    catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({ message: 'Server error fetching user profile' });
    }
}));
// --- UPDATE USER PROFILE (e.g., set provider AND/OR name) ---
// Path: PUT /api/users/me
router.put('/me', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { name, provider } = req.body;
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        // Build the data object with only the fields that are provided
        const dataToUpdate = {};
        if (name) {
            dataToUpdate.name = name;
        }
        if (provider) {
            if (provider !== 'MEA' && provider !== 'PEA') {
                res.status(400).json({ message: 'A valid provider (MEA or PEA) is required' });
                return;
            }
            dataToUpdate.provider = provider;
        }
        if (Object.keys(dataToUpdate).length === 0) {
            res.status(400).json({ message: 'No update data provided (name or provider)' });
            return;
        }
        const updatedUser = yield prisma.user.update({
            where: { id: userId },
            data: dataToUpdate,
        });
        const { password } = updatedUser, userWithoutPassword = __rest(updatedUser, ["password"]);
        res.status(200).json(userWithoutPassword);
    }
    catch (error) {
        console.error('Error updating user:', error);
        res.status(500).json({ message: 'Server error updating user profile' });
    }
}));
// --- UPDATE USER NOTIFICATION PREFERENCES ---
router.put('/me/preferences', authMiddleware_1.protect, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { notificationsEnabled } = req.body;
        const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.userId;
        if (!userId) {
            res.status(401).json({ message: 'Not authorized' });
            return;
        }
        if (typeof notificationsEnabled !== 'boolean') {
            res.status(400).json({ message: 'A boolean value for notificationsEnabled is required.' });
            return;
        }
        const updatedUser = yield prisma.user.update({
            where: { id: userId },
            data: { notificationsEnabled: notificationsEnabled },
        });
        res.status(200).json({
            message: 'Preferences updated successfully',
            notificationsEnabled: updatedUser.notificationsEnabled
        });
    }
    catch (error) {
        console.error('Error updating notification preferences:', error);
        res.status(500).json({ message: 'Server error updating preferences' });
    }
}));
exports.default = router;
