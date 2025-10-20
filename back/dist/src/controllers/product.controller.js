"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProductController = void 0;
const product_service_1 = __importDefault(require("../services/product.service"));
const client_1 = require("@prisma/client");
const cloudinary_util_1 = __importDefault(require("../utils/cloudinary.util"));
class ProductController {
    // Créer un produit (vendeur authentifié)
    async createProduct(req, res) {
        try {
            console.log('=== CREATE PRODUCT REQUEST ===');
            console.log('Body:', req.body);
            console.log('Files:', req.files);
            console.log('User:', req.user);
            const { title, description } = req.body;
            const userId = req.user?.id;
            console.log('Extracted data:', { title, description, userId });
            // Validation
            if (!title || !description) {
                console.error('Validation failed: Missing title or description');
                return res.status(400).json({ error: 'Title and description are required' });
            }
            if (!userId) {
                console.error('Authentication failed: No user ID in token');
                return res.status(401).json({ error: 'Authentication required' });
            }
            // Vérifier que des photos ont été uploadées
            const files = req.files;
            if (!files || files.length === 0) {
                console.error('Validation failed: No photos uploaded');
                return res.status(400).json({ error: 'At least one photo is required' });
            }
            if (files.length > 5) {
                console.error('Validation failed: Too many photos');
                return res.status(400).json({ error: 'Maximum 5 photos allowed' });
            }
            console.log('Uploading photos to Cloudinary...');
            // Upload des photos vers Cloudinary
            const uploadedPhotos = await cloudinary_util_1.default.uploadMultipleImages(files);
            console.log('Photos uploaded successfully:', uploadedPhotos);
            console.log('Creating product in database...');
            const product = await product_service_1.default.createProduct({
                title,
                description,
                sellerId: userId,
                photos: uploadedPhotos,
            });
            console.log('Product created successfully:', product.id);
            res.status(201).json({
                message: 'Product submitted successfully. It will be reviewed by our team.',
                product,
            });
        }
        catch (error) {
            console.error('Error creating product:', error);
            console.error('Error stack:', error.stack);
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Récupérer tous les produits (public)
    async getProducts(req, res) {
        try {
            const { status, search, page, limit } = req.query;
            const filters = {
                search: search,
                page: page ? parseInt(page) : undefined,
                limit: limit ? parseInt(limit) : undefined,
            };
            // Pour l'endpoint public, ne montrer que les produits approuvés par défaut
            // sauf si un statut spécifique est demandé (pour les admins/modérateurs)
            filters.status = status || client_1.ProductStatus.APPROVED;
            const result = await product_service_1.default.getProducts(filters);
            res.json(result);
        }
        catch (error) {
            console.error('Error fetching products:', error);
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Récupérer les produits du vendeur actuellement connecté
    async getCurrentSellerProducts(req, res) {
        try {
            const userId = req.user?.id;
            if (!userId) {
                return res.status(401).json({ error: 'Authentication required' });
            }
            const { status, search, page, limit } = req.query;
            const filters = {
                sellerId: userId,
                status: status,
                search: search,
                page: page ? parseInt(page) : undefined,
                limit: limit ? parseInt(limit) : undefined,
            };
            const result = await product_service_1.default.getProducts(filters);
            res.json(result);
        }
        catch (error) {
            console.error('Error fetching current seller products:', error);
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Récupérer un produit par ID
    async getProductById(req, res) {
        try {
            const { id } = req.params;
            const product = await product_service_1.default.getProductById(id);
            res.json(product);
        }
        catch (error) {
            console.error('Error fetching product:', error);
            if (error.message === 'Product not found') {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Modifier un produit (vendeur propriétaire uniquement)
    async updateProduct(req, res) {
        try {
            console.log('=== UPDATE PRODUCT REQUEST ===');
            const { id } = req.params;
            const { title, description, removedPhotoIds } = req.body;
            const userId = req.user?.id;
            const userRole = req.user?.role;
            console.log('Update data:', { id, title, description, removedPhotoIds, userId, userRole });
            if (!userId) {
                return res.status(401).json({ error: 'Authentication required' });
            }
            // Vérifier que le produit existe et appartient au vendeur
            const existingProduct = await product_service_1.default.getProductById(id);
            if (existingProduct.sellerId !== userId && userRole !== 'ADMIN') {
                return res.status(403).json({ error: 'You are not authorized to update this product' });
            }
            // Préparer les données de mise à jour
            const updateData = {};
            if (title)
                updateData.title = title;
            if (description)
                updateData.description = description;
            // Gérer les nouvelles photos
            const files = req.files;
            if (files && files.length > 0) {
                console.log('Uploading new photos to Cloudinary...');
                const uploadedPhotos = await cloudinary_util_1.default.uploadMultipleImages(files);
                updateData.newPhotos = uploadedPhotos;
            }
            // Gérer les photos à supprimer
            if (removedPhotoIds) {
                const photoIdsArray = typeof removedPhotoIds === 'string'
                    ? JSON.parse(removedPhotoIds)
                    : removedPhotoIds;
                updateData.removedPhotoIds = photoIdsArray;
            }
            const updatedProduct = await product_service_1.default.updateProduct(id, updateData);
            res.json({
                message: 'Product updated successfully',
                product: updatedProduct,
            });
        }
        catch (error) {
            console.error('Error updating product:', error);
            console.error('Error stack:', error.stack);
            if (error.message === 'Product not found') {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Supprimer un produit (vendeur propriétaire ou admin)
    async deleteProduct(req, res) {
        try {
            console.log('=== DELETE PRODUCT REQUEST ===');
            const { id } = req.params;
            const userId = req.user?.id;
            const userRole = req.user?.role;
            console.log('Delete request:', { id, userId, userRole });
            if (!userId) {
                return res.status(401).json({ error: 'Authentication required' });
            }
            // Vérifier que le produit existe et appartient au vendeur
            const existingProduct = await product_service_1.default.getProductById(id);
            if (existingProduct.sellerId !== userId && userRole !== 'ADMIN') {
                return res.status(403).json({ error: 'You are not authorized to delete this product' });
            }
            const result = await product_service_1.default.deleteProduct(id);
            res.json(result);
        }
        catch (error) {
            console.error('Error deleting product:', error);
            if (error.message === 'Product not found') {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Modération: Récupérer les produits en attente
    async getPendingProducts(req, res) {
        try {
            const { page, limit } = req.query;
            const result = await product_service_1.default.getPendingProducts(page ? parseInt(page) : undefined, limit ? parseInt(limit) : undefined);
            res.json(result);
        }
        catch (error) {
            console.error('Error fetching pending products:', error);
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Modération: Approuver un produit
    async approveProduct(req, res) {
        try {
            const { id } = req.params;
            const product = await product_service_1.default.approveProduct(id);
            res.json(product);
        }
        catch (error) {
            console.error('Error approving product:', error);
            if (error.message === 'Product not found') {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
    // Modération: Rejeter un produit
    async rejectProduct(req, res) {
        try {
            const { id } = req.params;
            const { reason } = req.body;
            const product = await product_service_1.default.rejectProduct(id, reason);
            res.json(product);
        }
        catch (error) {
            console.error('Error rejecting product:', error);
            if (error.message === 'Product not found') {
                return res.status(404).json({ error: error.message });
            }
            res.status(500).json({ error: error.message || 'Internal server error' });
        }
    }
}
exports.ProductController = ProductController;
exports.default = new ProductController();
//# sourceMappingURL=product.controller.js.map