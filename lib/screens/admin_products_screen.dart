import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/admin_service.dart';
import 'product_detail_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  final String initialStatus;

  AdminProductsScreen({this.initialStatus = 'PENDING'});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  final Map<String, List<Product>> _productsByStatus = {
    'ALL': [],
    'PENDING': [],
    'APPROVED': [],
    'REJECTED': [],
  };
  
  final Map<String, bool> _isLoadingByStatus = {
    'ALL': true,
    'PENDING': true,
    'APPROVED': true,
    'REJECTED': true,
  };

  int _getInitialIndex() {
    switch (widget.initialStatus) {
      case 'PENDING': return 1;
      case 'APPROVED': return 2;
      case 'REJECTED': return 3;
      default: return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: _getInitialIndex(),
    );
    _loadAllProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    for (var status in ['ALL', 'PENDING', 'APPROVED', 'REJECTED']) {
      await _loadProducts(status);
    }
  }

  Future<void> _loadProducts(String status) async {
    setState(() => _isLoadingByStatus[status] = true);
    try {
      final result = await AdminService.getAllProducts(
        status: status == 'ALL' ? null : status,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      setState(() {
        _productsByStatus[status] = result['products'];
        _isLoadingByStatus[status] = false;
      });
    } catch (e) {
      setState(() => _isLoadingByStatus[status] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _approveProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Approuver le produit'),
        content: Text('Voulez-vous approuver "${product.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Approuver'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.approveProduct(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit approuvé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAllProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectProduct(Product product) async {
    final reasonController = TextEditingController();
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rejeter le produit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejeter "${product.title}" ?'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Raison (optionnelle)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Rejeter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.rejectProduct(
          product.id,
          reason: reasonController.text.isEmpty ? null : reasonController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit rejeté'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadAllProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le produit'),
        content: Text('Voulez-vous vraiment supprimer "${product.title}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await AdminService.deleteProduct(product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produit supprimé'),
            backgroundColor: Colors.red,
          ),
        );
        _loadAllProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modération Produits'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tous'),
            Tab(text: 'En attente'),
            Tab(text: 'Approuvés'),
            Tab(text: 'Rejetés'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadAllProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (_) => _loadAllProducts(),
            ),
          ),
          // Liste des produits
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList('ALL'),
                _buildProductList('PENDING'),
                _buildProductList('APPROVED'),
                _buildProductList('REJECTED'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(String status) {
    final isLoading = _isLoadingByStatus[status] ?? true;
    final products = _productsByStatus[status] ?? [];

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun produit',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(status),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index]);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.photos.isNotEmpty
                  ? Image.network(
                      product.photos.first,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: Icon(Icons.image),
                    ),
            ),
            title: Text(
              product.title,
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  'Par: ${product.seller?.fullName ?? "Inconnu"}',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                _buildStatusChip(product.status),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                );
              },
            ),
          ),
          // Actions
          if (product.status == 'PENDING')
            Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.check),
                      label: Text('Approuver'),
                      onPressed: () => _approveProduct(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.close),
                      label: Text('Rejeter'),
                      onPressed: () => _rejectProduct(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Bouton supprimer (pour tous)
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text('Supprimer', style: TextStyle(color: Colors.red)),
                onPressed: () => _deleteProduct(product),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        label = 'Approuvé';
        break;
      case 'PENDING':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejeté';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
