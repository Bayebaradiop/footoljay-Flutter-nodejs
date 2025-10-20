import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class MyProductsScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const MyProductsScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);
  
  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final Map<String, List<Product>> _productsByStatus = {
    'APPROVED': [],
    'PENDING': [],
    'REJECTED': [],
  };
  
  final Map<String, bool> _isLoadingByStatus = {
    'APPROVED': true,
    'PENDING': true,
    'REJECTED': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadAllProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    for (var status in ['APPROVED', 'PENDING', 'REJECTED']) {
      await _loadProducts(status);
    }
  }

  Future<void> _loadProducts(String status) async {
    setState(() => _isLoadingByStatus[status] = true);
    try {
      final products = await ProductService.getMyProducts(status: status);
      setState(() {
        _productsByStatus[status] = products;
        _isLoadingByStatus[status] = false;
      });
    } catch (e) {
      setState(() => _isLoadingByStatus[status] = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
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
        title: Text('Mes produits'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 18),
                  SizedBox(width: 4),
                  Text('Approuvés'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pending, size: 18),
                  SizedBox(width: 4),
                  Text('En attente'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cancel, size: 18),
                  SizedBox(width: 4),
                  Text('Rejetés'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductList('APPROVED'),
          _buildProductList('PENDING'),
          _buildProductList('REJECTED'),
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
            Icon(
              status == 'APPROVED' ? Icons.inventory_2_outlined :
              status == 'PENDING' ? Icons.hourglass_empty :
              Icons.block,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              status == 'APPROVED' ? 'Aucun produit approuvé' :
              status == 'PENDING' ? 'Aucun produit en attente' :
              'Aucun produit rejeté',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.photos.isNotEmpty
                    ? Image.network(
                        product.photos.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(Icons.image),
                      ),
              ),
              SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(product.status),
                        SizedBox(width: 8),
                        Text(
                          '${product.photos.length} photo${product.photos.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'APPROVED':
        color = Colors.green;
        label = 'Approuvé';
        icon = Icons.check_circle;
        break;
      case 'PENDING':
        color = Colors.orange;
        label = 'En attente';
        icon = Icons.pending;
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejeté';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = status;
        icon = Icons.help;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
