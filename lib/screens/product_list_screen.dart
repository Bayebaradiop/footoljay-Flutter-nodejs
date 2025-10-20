import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = false;
  String selectedStatus = 'APPROVED';
  final searchController = TextEditingController();
  User? currentUser; // Stocker l'utilisateur actuel
  bool isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadProducts();
  }

  // Vérifier si l'utilisateur est connecté et récupérer ses infos
  Future<void> _checkAuth() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        currentUser = user;
        isCheckingAuth = false;
      });
    } catch (e) {
      // L'utilisateur n'est pas connecté (visiteur)
      setState(() {
        currentUser = null;
        isCheckingAuth = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);

    try {
      final result = await ProductService.getProducts(
        status: selectedStatus,
        search: searchController.text.isEmpty ? null : searchController.text,
      );
      setState(() => products = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FOTOL JAY - Produits'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _loadProducts(),
            ),
          ),
          
          // Filtres par statut (visibles uniquement pour les admins)
          if (currentUser?.isAdmin == true) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Approuvés',
                  isSelected: selectedStatus == 'APPROVED',
                  onSelected: () {
                    setState(() => selectedStatus = 'APPROVED');
                    _loadProducts();
                  },
                ),
                SizedBox(width: 8),
                _FilterChip(
                  label: 'En attente',
                  isSelected: selectedStatus == 'PENDING',
                  onSelected: () {
                    setState(() => selectedStatus = 'PENDING');
                    _loadProducts();
                  },
                ),
                SizedBox(width: 8),
                _FilterChip(
                  label: 'Rejetés',
                  isSelected: selectedStatus == 'REJECTED',
                  onSelected: () {
                    setState(() => selectedStatus = 'REJECTED');
                    _loadProducts();
                  },
                ),
                SizedBox(width: 8),
                _FilterChip(
                  label: 'Expirés',
                  isSelected: selectedStatus == 'EXPIRED',
                  onSelected: () {
                    setState(() => selectedStatus == 'EXPIRED');
                    _loadProducts();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          ],
          
          // Liste des produits
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucun produit trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              product: products[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(
                                      productId: products[index].id,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// Widget personnalisé pour les filtres
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}
