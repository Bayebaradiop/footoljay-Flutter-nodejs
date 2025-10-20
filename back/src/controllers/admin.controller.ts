import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class AdminController {
  // ==================== TABLEAU DE BORD ====================
  async getDashboardStats(req: Request, res: Response) {
    try {
      const [
        totalProducts,
        pendingProducts,
        approvedProducts,
        rejectedProducts,
        expiredProducts,
        totalUsers,
        totalSellers,
        totalModerators,
        vipSellers,
        activeSellers,
        inactiveSellers,
        recentProducts,
        topSellers
      ] = await Promise.all([
        // Statistiques produits
        prisma.product.count(),
        prisma.product.count({ where: { status: 'PENDING' } }),
        prisma.product.count({ where: { status: 'APPROVED' } }),
        prisma.product.count({ where: { status: 'REJECTED' } }),
        prisma.product.count({ where: { status: 'EXPIRED' } }),
        
        // Statistiques utilisateurs
        prisma.user.count(),
        prisma.user.count({ where: { role: 'SELLER' } }),
        prisma.user.count({ where: { role: 'MODERATOR' } }),
        prisma.user.count({ where: { role: 'SELLER', isVip: true } }),
        prisma.user.count({ where: { role: 'SELLER', isActive: true } }),
        prisma.user.count({ where: { role: 'SELLER', isActive: false } }),
        
        // Produits récents
        prisma.product.findMany({
          take: 5,
          orderBy: { createdAt: 'desc' },
          include: {
            seller: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                email: true,
                phone: true,
                isVip: true
              }
            },
            photos: {
              where: { isPrimary: true },
              take: 1
            }
          }
        }),
        
        // Top vendeurs (par nombre de produits approuvés)
        prisma.user.findMany({
          where: {
            role: 'SELLER',
            isActive: true
          },
          take: 5,
          include: {
            _count: {
              select: {
                products: {
                  where: { status: 'APPROVED' }
                }
              }
            }
          },
          orderBy: {
            products: {
              _count: 'desc'
            }
          }
        })
      ]);

      res.json({
        products: {
          total: totalProducts,
          pending: pendingProducts,
          approved: approvedProducts,
          rejected: rejectedProducts,
          expired: expiredProducts
        },
        users: {
          total: totalUsers,
          sellers: totalSellers,
          moderators: totalModerators,
          vipSellers,
          activeSellers,
          inactiveSellers
        },
        recentProducts,
        topSellers: topSellers.map(seller => ({
          id: seller.id,
          firstName: seller.firstName,
          lastName: seller.lastName,
          email: seller.email,
          phone: seller.phone,
          isVip: seller.isVip,
          isActive: seller.isActive,
          approvedProductsCount: seller._count.products
        }))
      });
    } catch (error) {
      console.error('Erreur tableau de bord:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // ==================== GESTION DES PRODUITS ====================
  
  // Obtenir tous les produits avec filtres pour modération
  async getAllProducts(req: Request, res: Response) {
    try {
      const { status, search, page = '1', limit = '20', sellerId } = req.query;

      const pageNum = parseInt(page as string);
      const limitNum = parseInt(limit as string);
      const skip = (pageNum - 1) * limitNum;

      const where: any = {};

      if (status && status !== 'ALL') {
        where.status = status;
      }

      if (sellerId) {
        where.sellerId = sellerId;
      }

      if (search) {
        where.OR = [
          { title: { contains: search as string, mode: 'insensitive' } },
          { description: { contains: search as string, mode: 'insensitive' } }
        ];
      }

      const [products, total] = await Promise.all([
        prisma.product.findMany({
          where,
          include: {
            photos: true,
            seller: {
              select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                phone: true,
                isVip: true,
                isActive: true
              }
            }
          },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limitNum
        }),
        prisma.product.count({ where })
      ]);

      res.json({
        products,
        pagination: {
          total,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    } catch (error) {
      console.error('Erreur récupération produits:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Approuver un produit
  async approveProduct(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const product = await prisma.product.update({
        where: { id },
        data: {
          status: 'APPROVED',
          publishedAt: new Date()
        },
        include: {
          seller: true,
          photos: true
        }
      });

      // Créer une notification pour le vendeur
      await prisma.notification.create({
        data: {
          type: 'PRODUCT_APPROVED',
          message: `Votre annonce "${product.title}" a été approuvée et est maintenant visible.`,
          userId: product.sellerId,
          recipientEmail: product.seller.email,
          productId: product.id
        }
      });

      res.json({
        message: 'Produit approuvé avec succès',
        product
      });
    } catch (error) {
      console.error('Erreur approbation produit:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Rejeter un produit
  async rejectProduct(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { reason } = req.body;

      const product = await prisma.product.update({
        where: { id },
        data: {
          status: 'REJECTED'
        },
        include: {
          seller: true,
          photos: true
        }
      });

      // Créer une notification pour le vendeur
      await prisma.notification.create({
        data: {
          type: 'PRODUCT_REJECTED',
          message: `Votre annonce "${product.title}" a été rejetée. ${reason ? `Raison: ${reason}` : ''}`,
          userId: product.sellerId,
          recipientEmail: product.seller.email,
          productId: product.id
        }
      });

      res.json({
        message: 'Produit rejeté avec succès',
        product
      });
    } catch (error) {
      console.error('Erreur rejet produit:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Supprimer un produit
  async deleteProduct(req: Request, res: Response) {
    try {
      const { id } = req.params;

      await prisma.product.delete({
        where: { id }
      });

      res.json({ message: 'Produit supprimé avec succès' });
    } catch (error) {
      console.error('Erreur suppression produit:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // ==================== GESTION DES UTILISATEURS ====================
  
  // Obtenir tous les utilisateurs
  async getAllUsers(req: Request, res: Response) {
    try {
      const { role, search, page = '1', limit = '20', isActive } = req.query;

      const pageNum = parseInt(page as string);
      const limitNum = parseInt(limit as string);
      const skip = (pageNum - 1) * limitNum;

      const where: any = {};

      if (role && role !== 'ALL') {
        where.role = role;
      }

      if (isActive !== undefined) {
        where.isActive = isActive === 'true';
      }

      if (search) {
        where.OR = [
          { firstName: { contains: search as string, mode: 'insensitive' } },
          { lastName: { contains: search as string, mode: 'insensitive' } },
          { email: { contains: search as string, mode: 'insensitive' } },
          { phone: { contains: search as string, mode: 'insensitive' } }
        ];
      }

      const [users, total] = await Promise.all([
        prisma.user.findMany({
          where,
          select: {
            id: true,
            email: true,
            firstName: true,
            lastName: true,
            phone: true,
            role: true,
            isVip: true,
            isActive: true,
            createdAt: true,
            updatedAt: true,
            _count: {
              select: {
                products: true
              }
            }
          },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limitNum
        }),
        prisma.user.count({ where })
      ]);

      res.json({
        users,
        pagination: {
          total,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum)
        }
      });
    } catch (error) {
      console.error('Erreur récupération utilisateurs:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Activer/Désactiver un utilisateur
  async toggleUserStatus(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { isActive } = req.body;

      const user = await prisma.user.update({
        where: { id },
        data: { isActive },
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          phone: true,
          role: true,
          isVip: true,
          isActive: true
        }
      });

      res.json({
        message: `Utilisateur ${isActive ? 'activé' : 'suspendu'} avec succès`,
        user
      });
    } catch (error) {
      console.error('Erreur modification statut utilisateur:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Promouvoir/Rétrograder un utilisateur (changer le rôle)
  async updateUserRole(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { role } = req.body;

      if (!['SELLER', 'MODERATOR', 'ADMIN'].includes(role)) {
        return res.status(400).json({ error: 'Rôle invalide' });
      }

      const user = await prisma.user.update({
        where: { id },
        data: { role },
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          phone: true,
          role: true,
          isVip: true,
          isActive: true
        }
      });

      res.json({
        message: 'Rôle utilisateur modifié avec succès',
        user
      });
    } catch (error) {
      console.error('Erreur modification rôle utilisateur:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Promouvoir/Rétrograder VIP
  async toggleVipStatus(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const { isVip } = req.body;

      const user = await prisma.user.update({
        where: { id },
        data: { isVip },
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          phone: true,
          role: true,
          isVip: true,
          isActive: true
        }
      });

      res.json({
        message: `Statut VIP ${isVip ? 'activé' : 'désactivé'} avec succès`,
        user
      });
    } catch (error) {
      console.error('Erreur modification statut VIP:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Supprimer un utilisateur
  async deleteUser(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const adminId = (req as any).user.id;

      // Empêcher l'admin de se supprimer lui-même
      if (id === adminId) {
        return res.status(400).json({ error: 'Vous ne pouvez pas supprimer votre propre compte' });
      }

      await prisma.user.delete({
        where: { id }
      });

      res.json({ message: 'Utilisateur supprimé avec succès' });
    } catch (error) {
      console.error('Erreur suppression utilisateur:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }

  // Obtenir les détails d'un utilisateur
  async getUserDetails(req: Request, res: Response) {
    try {
      const { id } = req.params;

      const user = await prisma.user.findUnique({
        where: { id },
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          phone: true,
          role: true,
          isVip: true,
          isActive: true,
          createdAt: true,
          updatedAt: true,
          products: {
            include: {
              photos: {
                where: { isPrimary: true },
                take: 1
              }
            },
            orderBy: { createdAt: 'desc' }
          },
          _count: {
            select: {
              products: true,
              notifications: true
            }
          }
        }
      });

      if (!user) {
        return res.status(404).json({ error: 'Utilisateur non trouvé' });
      }

      res.json(user);
    } catch (error) {
      console.error('Erreur récupération détails utilisateur:', error);
      res.status(500).json({ error: 'Erreur serveur' });
    }
  }
}

export default new AdminController();
