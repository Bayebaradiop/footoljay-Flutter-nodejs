import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/product.dart';

class ProductService {
  // Récupérer tous les produits (publics)
  static Future<List<Product>> getProducts({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    String endpoint = '/products?page=$page&limit=$limit';
    
    if (status != null) {
      endpoint += '&status=$status';
    }
    if (search != null) {
      endpoint += '&search=$search';
    }

    final response = await ApiClient.get(endpoint);
    return (response['products'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // Récupérer un produit par son ID
  static Future<Product> getProductById(String id) async {
    final response = await ApiClient.get('/products/$id');
    // Le backend renvoie directement l'objet produit, pas {"product": {...}}
    return Product.fromJson(response);
  }

  // Créer un nouveau produit avec photos
  static Future<Product> createProduct({
    required String title,
    required String description,
    required List<Uint8List> photoBytes,
    required List<String> photoNames,
  }) async {
    // Convertir les bytes en MultipartFile
    final List<MultipartFile> files = [];
    for (int i = 0; i < photoBytes.length; i++) {
      files.add(
        MultipartFile.fromBytes(
          photoBytes[i],
          filename: photoNames[i],
        ),
      );
    }

    final response = await ApiClient.multipartBytes(
      '/products',
      {
        'title': title,
        'description': description,
      },
      files,
    );
    return Product.fromJson(response['product']);
  }

  // Récupérer mes propres produits
  static Future<List<Product>> getMyProducts({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    String endpoint = '/sellers/my-products?page=$page&limit=$limit';
    
    if (status != null) {
      endpoint += '&status=$status';
    }
    if (search != null) {
      endpoint += '&search=$search';
    }

    final response = await ApiClient.get(endpoint);
    return (response['products'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // Mettre à jour un produit
  static Future<Product> updateProduct({
    required String id, // ✅ Changé de int à String
    String? title,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;

    final response = await ApiClient.put('/products/$id', body);
    return Product.fromJson(response['product']);
  }

  // Supprimer un produit
  static Future<void> deleteProduct(String id) async { // ✅ Changé de int à String
    await ApiClient.delete('/products/$id');
  }

  // Republier un produit expiré
  static Future<Product> republishProduct(String id) async { // ✅ Changé de int à String
    final response = await ApiClient.post('/products/$id/republish', {});
    return Product.fromJson(response['product']);
  }

  // === MODÉRATION (Admin/Moderator uniquement) ===

  // Récupérer les produits en attente de modération
  static Future<List<Product>> getPendingProducts({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '/products/moderation/pending?page=$page&limit=$limit',
    );
    return (response['products'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // Approuver un produit
  static Future<Product> approveProduct(String id) async { // ✅ Changé de int à String
    final response = await ApiClient.post('/products/$id/approve', {});
    return Product.fromJson(response['product']);
  }

  // Rejeter un produit
  static Future<Product> rejectProduct(String id, {String? reason}) async { // ✅ Changé de int à String
    final body = <String, dynamic>{};
    if (reason != null) {
      body['reason'] = reason;
    }
    final response = await ApiClient.post('/products/$id/reject', body);
    return Product.fromJson(response['product']);
  }
}
