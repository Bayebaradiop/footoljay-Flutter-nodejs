import '../services/api_client.dart';
import '../models/product.dart';
import '../models/user.dart';

class AdminService {
  // ==================== TABLEAU DE BORD ====================
  
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await ApiClient.get('/admin/dashboard/stats');
    return response;
  }

  // ==================== GESTION DES PRODUITS ====================
  
  static Future<Map<String, dynamic>> getAllProducts({
    String? status,
    String? search,
    String? sellerId,
    int page = 1,
    int limit = 20,
  }) async {
    String endpoint = '/admin/products?page=$page&limit=$limit';
    
    if (status != null && status != 'ALL') {
      endpoint += '&status=$status';
    }
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=$search';
    }
    if (sellerId != null) {
      endpoint += '&sellerId=$sellerId';
    }

    final response = await ApiClient.get(endpoint);
    
    return {
      'products': (response['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList(),
      'pagination': response['pagination'],
    };
  }

  static Future<Product> approveProduct(String productId) async {
    final response = await ApiClient.patch('/admin/products/$productId/approve', {});
    return Product.fromJson(response['product']);
  }

  static Future<Product> rejectProduct(String productId, {String? reason}) async {
    final response = await ApiClient.patch(
      '/admin/products/$productId/reject',
      {'reason': reason},
    );
    return Product.fromJson(response['product']);
  }

  static Future<void> deleteProduct(String productId) async {
    await ApiClient.delete('/admin/products/$productId');
  }

  // ==================== GESTION DES UTILISATEURS ====================
  
  static Future<Map<String, dynamic>> getAllUsers({
    String? role,
    String? search,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    String endpoint = '/admin/users?page=$page&limit=$limit';
    
    if (role != null && role != 'ALL') {
      endpoint += '&role=$role';
    }
    if (search != null && search.isNotEmpty) {
      endpoint += '&search=$search';
    }
    if (isActive != null) {
      endpoint += '&isActive=$isActive';
    }

    final response = await ApiClient.get(endpoint);
    
    return {
      'users': (response['users'] as List)
          .map((json) => User.fromJson(json))
          .toList(),
      'pagination': response['pagination'],
    };
  }

  static Future<User> getUserDetails(String userId) async {
    final response = await ApiClient.get('/admin/users/$userId');
    return User.fromJson(response);
  }

  static Future<User> toggleUserStatus(String userId, bool isActive) async {
    final response = await ApiClient.patch(
      '/admin/users/$userId/status',
      {'isActive': isActive},
    );
    return User.fromJson(response['user']);
  }

  static Future<User> updateUserRole(String userId, String role) async {
    final response = await ApiClient.patch(
      '/admin/users/$userId/role',
      {'role': role},
    );
    return User.fromJson(response['user']);
  }

  static Future<User> toggleVipStatus(String userId, bool isVip) async {
    final response = await ApiClient.patch(
      '/admin/users/$userId/vip',
      {'isVip': isVip},
    );
    return User.fromJson(response['user']);
  }

  static Future<void> deleteUser(String userId) async {
    await ApiClient.delete('/admin/users/$userId');
  }
}
