"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SellerController = void 0;
const client_1 = require("@prisma/client");
const bcrypt_1 = __importDefault(require("bcrypt"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const prisma = new client_1.PrismaClient();
class SellerController {
    async register(req, res) {
        try {
            const { email, password, firstName, lastName, phone } = req.body;
            if (!email || !password || !firstName || !lastName) {
                return res.status(400).json({
                    error: 'Email, mot de passe, prénom et nom sont requis'
                });
            }
            const existingUser = await prisma.user.findUnique({
                where: { email }
            });
            if (existingUser) {
                return res.status(400).json({
                    error: 'Un compte avec cet email existe déjà'
                });
            }
            const hashedPassword = await bcrypt_1.default.hash(password, 10);
            const user = await prisma.user.create({
                data: {
                    email,
                    password: hashedPassword,
                    firstName,
                    lastName,
                    phone,
                    role: 'SELLER',
                    isActive: true
                }
            });
            const token = jsonwebtoken_1.default.sign({
                userId: user.id,
                email: user.email,
                role: user.role
            }, process.env.JWT_SECRET || 'your-secret-key', { expiresIn: '7d' });
            res.status(201).json({
                message: 'Compte vendeur créé avec succès',
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    phone: user.phone,
                    role: user.role
                }
            });
        }
        catch (error) {
            console.error('Erreur lors de l\'inscription:', error);
            res.status(500).json({ error: 'Erreur lors de l\'inscription' });
        }
    }
    async login(req, res) {
        try {
            console.log('Seller login attempt:', { email: req.body.email });
            const { email, password } = req.body;
            if (!email || !password) {
                console.log('Login failed: Missing email or password');
                return res.status(400).json({
                    error: 'Email et mot de passe requis'
                });
            }
            const user = await prisma.user.findUnique({
                where: { email }
            });
            console.log('User lookup result:', {
                email,
                userFound: !!user,
                userActive: user?.isActive,
                userRole: user?.role
            });
            if (!user) {
                console.log('Login failed: User not found');
                return res.status(401).json({
                    error: 'Email ou mot de passe incorrect'
                });
            }
            if (!user.isActive) {
                return res.status(403).json({
                    error: 'Votre compte a été désactivé'
                });
            }
            const validPassword = await bcrypt_1.default.compare(password, user.password);
            if (!validPassword) {
                return res.status(401).json({
                    error: 'Email ou mot de passe incorrect'
                });
            }
            const token = jsonwebtoken_1.default.sign({
                userId: user.id,
                email: user.email,
                role: user.role
            }, process.env.JWT_SECRET || 'your-secret-key', { expiresIn: '7d' });
            res.json({
                message: 'Connexion réussie',
                token,
                user: {
                    id: user.id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    phone: user.phone,
                    role: user.role,
                    isVip: user.isVip
                }
            });
        }
        catch (error) {
            console.error('Erreur lors de la connexion:', error);
            res.status(500).json({ error: 'Erreur lors de la connexion' });
        }
    }
    async getProfile(req, res) {
        try {
            const userId = req.user.id;
            const user = await prisma.user.findUnique({
                where: { id: userId },
                select: {
                    id: true,
                    email: true,
                    firstName: true,
                    lastName: true,
                    phone: true,
                    role: true,
                    isVip: true,
                    createdAt: true
                }
            });
            if (!user) {
                return res.status(404).json({ error: 'Utilisateur non trouvé' });
            }
            res.json(user);
        }
        catch (error) {
            console.error('Erreur lors de la récupération du profil:', error);
            res.status(500).json({ error: 'Erreur serveur' });
        }
    }
    async getMyProducts(req, res) {
        try {
            const userId = req.user.id;
            const { status, search, page = '1', limit = '20' } = req.query;
            const pageNum = parseInt(page);
            const limitNum = parseInt(limit);
            const skip = (pageNum - 1) * limitNum;
            // Construire les conditions de filtrage
            const where = { sellerId: userId };
            if (status && status !== 'ALL') {
                where.status = status;
            }
            if (search) {
                where.OR = [
                    { title: { contains: search, mode: 'insensitive' } },
                    { description: { contains: search, mode: 'insensitive' } }
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
                                isVip: true
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
        }
        catch (error) {
            console.error('Erreur lors de la récupération des produits:', error);
            res.status(500).json({ error: 'Erreur serveur' });
        }
    }
}
exports.SellerController = SellerController;
//# sourceMappingURL=seller.controller.js.map