import { Router } from 'express';
import adminController from '../controllers/admin.controller';
import { authMiddleware } from '../middlewares/auth.middleware';
import { requireModerator } from '../middlewares/rbac.middleware';

const router = Router();

// Toutes les routes nécessitent d'être authentifié ET d'avoir le rôle ADMIN ou MODERATOR
const requireAdmin = [authMiddleware, requireModerator];

// ==================== TABLEAU DE BORD ====================
router.get('/dashboard/stats', requireAdmin, (req, res) => 
  adminController.getDashboardStats(req, res)
);

// ==================== GESTION DES PRODUITS ====================
router.get('/products', requireAdmin, (req, res) => 
  adminController.getAllProducts(req, res)
);

router.patch('/products/:id/approve', requireAdmin, (req, res) => 
  adminController.approveProduct(req, res)
);

router.patch('/products/:id/reject', requireAdmin, (req, res) => 
  adminController.rejectProduct(req, res)
);

router.delete('/products/:id', requireAdmin, (req, res) => 
  adminController.deleteProduct(req, res)
);

// ==================== GESTION DES UTILISATEURS ====================
router.get('/users', requireAdmin, (req, res) => 
  adminController.getAllUsers(req, res)
);

router.get('/users/:id', requireAdmin, (req, res) => 
  adminController.getUserDetails(req, res)
);

router.patch('/users/:id/status', requireAdmin, (req, res) => 
  adminController.toggleUserStatus(req, res)
);

router.patch('/users/:id/role', requireAdmin, (req, res) => 
  adminController.updateUserRole(req, res)
);

router.patch('/users/:id/vip', requireAdmin, (req, res) => 
  adminController.toggleVipStatus(req, res)
);

router.delete('/users/:id', requireAdmin, (req, res) => 
  adminController.deleteUser(req, res)
);

export default router;
