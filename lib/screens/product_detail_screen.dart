import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/product_service.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId; // ✅ Changé de int à String pour UUID

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? product;
  bool isLoading = true;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => isLoading = true);

    try {
      final result = await ProductService.getProductById(widget.productId);
      setState(() => product = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Ouvrir WhatsApp avec message pré-rempli
  Future<void> _openWhatsApp() async {
    if (product == null || product!.user == null) return;

    final phone = product!.user!.phone;
    final productName = product!.title;
    final message = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par votre produit "$productName" sur FOTOL JAY.'
    );
    
    // Formatter le numéro de téléphone (enlever les espaces, + etc.)
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    final whatsappUrl = 'https://wa.me/$cleanPhone?text=$message';
    final uri = Uri.parse(whatsappUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ouverture de WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du produit'),
        actions: [
          if (product != null)
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text('Partager'),
                    ],
                  ),
                  onTap: () {
                    // TODO: Partager le produit
                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonction partage à venir')),
                      );
                    });
                  },
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.report, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Signaler', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  onTap: () {
                    // TODO: Signaler le produit
                    Future.delayed(Duration.zero, () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Fonction signalement à venir')),
                      );
                    });
                  },
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : product == null
              ? Center(child: Text('Produit introuvable'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Galerie d'images
                      _buildImageGallery(),
                      
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Titre
                            Text(
                              product!.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            
                            // Statut
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(product!.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                product!.statusLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            
                            // Date de publication
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  'Publié le ${DateFormat('dd/MM/yyyy à HH:mm').format(product!.createdAt)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                            
                            // Date d'expiration (si existe)
                            if (product!.expiresAt != null) ...[
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.event_busy, size: 16, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    'Expire le ${DateFormat('dd/MM/yyyy').format(product!.expiresAt!)}',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ),
                            ],
                            
                            Divider(height: 32),
                            
                            // Description
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product!.description,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.grey[800],
                              ),
                            ),
                            
                            Divider(height: 32),
                            
                            // Informations du vendeur
                            if (product!.user != null) ...[
                              Text(
                                'Vendeur',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          product!.user!.firstName[0].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  product!.user!.fullName,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (product!.user!.isVip) ...[
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.verified,
                                                    size: 18,
                                                    color: Colors.amber,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              product!.user!.email,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone, size: 14, color: Colors.grey),
                                                SizedBox(width: 4),
                                                Text(
                                                  product!.user!.phone,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.chat,
                                          color: Color(0xFF25D366), // Couleur WhatsApp
                                        ),
                                        onPressed: _openWhatsApp,
                                        tooltip: 'Contacter sur WhatsApp',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            
                            SizedBox(height: 80), // Espace pour le bouton flottant
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: product != null && product!.isApproved && product!.user != null
          ? FloatingActionButton.extended(
              onPressed: _openWhatsApp,
              icon: Icon(Icons.chat, color: Colors.white),
              label: Text('WhatsApp', style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFF25D366), // Couleur WhatsApp
            )
          : null,
    );
  }

  // Galerie d'images avec indicateurs
  Widget _buildImageGallery() {
    if (product!.photos.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: Center(
          child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 300,
          child: PageView.builder(
            itemCount: product!.photos.length,
            onPageChanged: (index) {
              setState(() => currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: product!.photos[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: Center(child: Icon(Icons.error)),
                ),
              );
            },
          ),
        ),
        
        // Indicateurs de pages
        if (product!.photos.length > 1)
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product!.photos.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentImageIndex == index
                        ? Colors.blue
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'EXPIRED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
