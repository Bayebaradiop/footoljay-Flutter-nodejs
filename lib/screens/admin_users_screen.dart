import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  final String initialFilter;

  AdminUsersScreen({this.initialFilter = 'ALL'});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];
  bool isLoading = true;
  String currentFilter = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentFilter = widget.initialFilter;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    try {
      String? role;
      bool? isActive;

      if (currentFilter == 'SELLER' || currentFilter == 'MODERATOR' || currentFilter == 'ADMIN') {
        role = currentFilter;
      } else if (currentFilter == 'ACTIVE') {
        isActive = true;
      } else if (currentFilter == 'INACTIVE') {
        isActive = false;
      } else if (currentFilter == 'VIP') {
        role = 'SELLER';
        // On filtrera côté client pour les VIP
      }

      final result = await AdminService.getAllUsers(
        role: role,
        isActive: isActive,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
      
      List<User> fetchedUsers = result['users'];
      
      // Filtrer les VIP côté client si nécessaire
      if (currentFilter == 'VIP') {
        fetchedUsers = fetchedUsers.where((u) => u.isVip).toList();
      }

      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
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

  Future<void> _toggleUserStatus(User user) async {
    try {
      await AdminService.toggleUserStatus(user.id, !user.isActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleVipStatus(User user) async {
    try {
      await AdminService.toggleVipStatus(user.id, !user.isVip);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut VIP modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'utilisateur'),
        content: Text('Voulez-vous vraiment supprimer ${user.fullName} ? Cette action est irréversible.'),
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
        await AdminService.deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Utilisateur supprimé'),
            backgroundColor: Colors.red,
          ),
        );
        _loadUsers();
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
        title: Text('Gestion des utilisateurs'),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('ALL', 'Tous'),
                  SizedBox(width: 8),
                  _buildFilterChip('SELLER', 'Vendeurs'),
                  SizedBox(width: 8),
                  _buildFilterChip('VIP', 'VIP'),
                  SizedBox(width: 8),
                  _buildFilterChip('ACTIVE', 'Actifs'),
                  SizedBox(width: 8),
                  _buildFilterChip('INACTIVE', 'Suspendus'),
                  SizedBox(width: 8),
                  _buildFilterChip('MODERATOR', 'Modérateurs'),
                ],
              ),
            ),
          ),
          // Barre de recherche
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadUsers();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (_) => _loadUsers(),
            ),
          ),
          // Liste des utilisateurs
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucun utilisateur',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUsers,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(users[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = currentFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          currentFilter = value;
        });
        _loadUsers();
      },
      selectedColor: Colors.blue.withOpacity(0.3),
    );
  }

  Widget _buildUserCard(User user) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? Colors.blue : Colors.grey,
          child: Text(
            user.firstName[0] + user.lastName[0],
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.fullName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (user.isVip)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      'VIP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(user.email, style: TextStyle(fontSize: 12)),
            SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(user.role),
                SizedBox(width: 8),
                _buildStatusChip(user.isActive),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Téléphone: ${user.phone}'),
                if (user.productsCount != null)
                  Text('Produits: ${user.productsCount}'),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(
                        user.isActive ? Icons.block : Icons.check_circle,
                        size: 18,
                      ),
                      label: Text(user.isActive ? 'Suspendre' : 'Activer'),
                      onPressed: () => _toggleUserStatus(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.isActive ? Colors.orange : Colors.green,
                      ),
                    ),
                    if (user.isSeller)
                      ElevatedButton.icon(
                        icon: Icon(Icons.star, size: 18),
                        label: Text(user.isVip ? 'Retirer VIP' : 'Promouvoir VIP'),
                        onPressed: () => _toggleVipStatus(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: user.isVip ? Colors.grey : Colors.amber,
                        ),
                      ),
                    OutlinedButton.icon(
                      icon: Icon(Icons.delete, size: 18, color: Colors.red),
                      label: Text('Supprimer', style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteUser(user),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    String label;

    switch (role) {
      case 'ADMIN':
        color = Colors.red;
        label = 'Admin';
        break;
      case 'MODERATOR':
        color = Colors.purple;
        label = 'Modérateur';
        break;
      case 'SELLER':
        color = Colors.blue;
        label = 'Vendeur';
        break;
      default:
        color = Colors.grey;
        label = role;
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

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? Colors.green : Colors.grey).withOpacity(0.3),
        ),
      ),
      child: Text(
        isActive ? 'Actif' : 'Suspendu',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
