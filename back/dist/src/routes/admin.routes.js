"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const admin_controller_1 = __importDefault(require("../controllers/admin.controller"));
const auth_middleware_1 = require("../middlewares/auth.middleware");
const rbac_middleware_1 = require("../middlewares/rbac.middleware");
const router = (0, express_1.Router)();
// Toutes les routes nécessitent d'être authentifié ET d'avoir le rôle ADMIN ou MODERATOR
const requireAdmin = [auth_middleware_1.authMiddleware, rbac_middleware_1.requireModerator];
// ==================== TABLEAU DE BORD ====================
router.get('/dashboard/stats', requireAdmin, (req, res) => admin_controller_1.default.getDashboardStats(req, res));
// ==================== GESTION DES PRODUITS ====================
router.get('/products', requireAdmin, (req, res) => admin_controller_1.default.getAllProducts(req, res));
router.patch('/products/:id/approve', requireAdmin, (req, res) => admin_controller_1.default.approveProduct(req, res));
router.patch('/products/:id/reject', requireAdmin, (req, res) => admin_controller_1.default.rejectProduct(req, res));
router.delete('/products/:id', requireAdmin, (req, res) => admin_controller_1.default.deleteProduct(req, res));
// ==================== GESTION DES UTILISATEURS ====================
router.get('/users', requireAdmin, (req, res) => admin_controller_1.default.getAllUsers(req, res));
router.get('/users/:id', requireAdmin, (req, res) => admin_controller_1.default.getUserDetails(req, res));
router.patch('/users/:id/status', requireAdmin, (req, res) => admin_controller_1.default.toggleUserStatus(req, res));
router.patch('/users/:id/role', requireAdmin, (req, res) => admin_controller_1.default.updateUserRole(req, res));
router.patch('/users/:id/vip', requireAdmin, (req, res) => admin_controller_1.default.toggleVipStatus(req, res));
router.delete('/users/:id', requireAdmin, (req, res) => admin_controller_1.default.deleteUser(req, res));
exports.default = router;
//# sourceMappingURL=admin.routes.js.map