import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';

  // Sauvegarder le token (pour Flutter Web uniquement)
  static Future<void> _saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    }
  }

  // Récupérer le token (pour Flutter Web uniquement)
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    }
    return null;
  }

  // Supprimer le token
  static Future<void> _clearToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    }
  }
  // Inscription d'un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    return await ApiClient.post('/auth/register', {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    });
  }

  // Connexion (le cookie est géré automatiquement par Dio sur mobile, token manuel sur web)
  static Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    // Sur Web, sauvegarder le token manuellement
    if (kIsWeb && response['token'] != null) {
      await _saveToken(response['token']);
    }
    
    return User.fromJson(response['user']);
  }

  // Récupérer l'utilisateur actuellement connecté
  static Future<User> getCurrentUser() async {
    final response = await ApiClient.get('/auth/me');
    return User.fromJson(response['user']);
  }

  // Changer le mot de passe
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.put('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Déconnexion
  static Future<void> logout() async {
    try {
      // Appeler l'endpoint de déconnexion du backend
      await ApiClient.post('/auth/logout', {});
    } catch (e) {
      // Même si l'API échoue, on supprime les cookies localement
      print('Erreur lors de la déconnexion: $e');
    } finally {
      // Supprimer le token sur Web
      await _clearToken();
      // Vider les cookies localement (pour mobile)
      await ApiClient.clearCookies();
    }
  }

  // Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
