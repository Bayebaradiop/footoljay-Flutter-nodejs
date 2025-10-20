import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';
import 'admin_products_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoading = true;
  Map<String, dynamic>? stats;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await AdminService.getDashboardStats();
      setState(() {
        stats = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Tableau de bord', style: AppTheme.h2),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : error != null
              ? _buildError()
              : _buildDashboard(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppTheme.spacingLG),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppTheme.errorColor,
              ),
            ),
            SizedBox(height: AppTheme.spacingLG),
            Text('Erreur de chargement', style: AppTheme.h3),
            SizedBox(height: AppTheme.spacingSM),
            Text(
              error!,
              style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spacingLG),
            ElevatedButton.icon(
              onPressed: _loadStats,
              icon: Icon(Icons.refresh_rounded),
              label: Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingXL,
                  vertical: AppTheme.spacingMD,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    final products = stats!['products'] as Map<String, dynamic>;
    final users = stats!['users'] as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppTheme.primaryColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Padding responsive
          final horizontalPadding = constraints.maxWidth > 600 
              ? AppTheme.spacingLG 
              : AppTheme.spacingMD;
          
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: AppTheme.spacingMD,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Text(
                  'Statistiques',
                  style: AppTheme.h2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTheme.spacingXS),
                Text(
                  'Vue d\'ensemble de la plateforme',
                  style: AppTheme.bodyText2.copyWith(color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppTheme.spacingXL),

                // Section Produits
                _buildSectionHeader('Produits', Icons.inventory_2_rounded),
                SizedBox(height: AppTheme.spacingMD),
                _buildProductsGrid(products),
                SizedBox(height: AppTheme.spacingXXL),

                // Section Utilisateurs
                _buildSectionHeader('Utilisateurs', Icons.people_rounded),
                SizedBox(height: AppTheme.spacingMD),
                _buildUsersGrid(users),
                SizedBox(height: AppTheme.spacingXXL),

                // Actions rapides
                _buildSectionHeader('Actions rapides', Icons.flash_on_rounded),
                SizedBox(height: AppTheme.spacingMD),
                _buildQuickActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppTheme.spacingSM),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        SizedBox(width: AppTheme.spacingMD),
        Expanded(
          child: Text(
            title,
            style: AppTheme.h3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(Map<String, dynamic> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive: 2 colonnes sur mobile, 4 sur tablette/desktop
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.0;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingMD,
          crossAxisSpacing: AppTheme.spacingMD,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Total',
              products['total'].toString(),
              Icons.inventory_rounded,
              AppTheme.primaryColor,
              () => _navigateToProducts('ALL'),
            ),
            _buildStatCard(
              'En attente',
              products['pending'].toString(),
              Icons.pending_rounded,
              AppTheme.warningColor,
              () => _navigateToProducts('PENDING'),
            ),
            _buildStatCard(
              'Approuvés',
              products['approved'].toString(),
              Icons.check_circle_rounded,
              AppTheme.successColor,
              () => _navigateToProducts('APPROVED'),
            ),
            _buildStatCard(
              'Rejetés',
              products['rejected'].toString(),
              Icons.cancel_rounded,
              AppTheme.errorColor,
              () => _navigateToProducts('REJECTED'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsersGrid(Map<String, dynamic> users) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.0;
        
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingMD,
          crossAxisSpacing: AppTheme.spacingMD,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Total',
              users['total'].toString(),
              Icons.people_rounded,
              AppTheme.primaryColor,
              () => _navigateToUsers('ALL'),
            ),
            _buildStatCard(
              'Vendeurs',
              users['sellers'].toString(),
              Icons.storefront_rounded,
              AppTheme.infoColor,
              () => _navigateToUsers('SELLER'),
            ),
            _buildStatCard(
              'VIP',
              users['vipSellers'].toString(),
              Icons.star_rounded,
              AppTheme.warningColor,
              () => _navigateToUsers('VIP'),
            ),
            _buildStatCard(
              'Actifs',
              users['activeSellers'].toString(),
              Icons.check_circle_outline_rounded,
              AppTheme.successColor,
              () => _navigateToUsers('ACTIVE'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        child: Container(
          decoration: AppTheme.cardDecoration(),
          padding: EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMD),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              SizedBox(height: AppTheme.spacingMD),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppTheme.h1.copyWith(color: color, fontSize: 28),
                  overflow: TextOverflow.visible,
                ),
              ),
              SizedBox(height: AppTheme.spacingXS),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 100),
                  child: Text(
                    title,
                    style: AppTheme.bodyText2.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur mobile: stack vertical, sur desktop: row
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildActionButton(
                'Modérer produits',
                Icons.pending_actions_rounded,
                AppTheme.warningColor,
                () => _navigateToProducts('PENDING'),
              ),
              SizedBox(height: AppTheme.spacingMD),
              _buildActionButton(
                'Gérer utilisateurs',
                Icons.people_outline_rounded,
                AppTheme.primaryColor,
                () => _navigateToUsers('ALL'),
              ),
            ],
          );
        }
        
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Modérer produits',
                Icons.pending_actions_rounded,
                AppTheme.warningColor,
                () => _navigateToProducts('PENDING'),
              ),
            ),
            SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: _buildActionButton(
                'Gérer utilisateurs',
                Icons.people_outline_rounded,
                AppTheme.primaryColor,
                () => _navigateToUsers('ALL'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Sur mobile, réduire le padding
        final verticalPadding = constraints.maxWidth < 600 
            ? AppTheme.spacingMD 
            : AppTheme.spacingLG;
        
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: AppTheme.spacingMD,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              SizedBox(width: AppTheme.spacingSM),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.subtitle1.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToProducts(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProductsScreen(initialStatus: status),
      ),
    );
  }

  void _navigateToUsers(String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminUsersScreen(initialFilter: filter),
      ),
    );
  }
}
