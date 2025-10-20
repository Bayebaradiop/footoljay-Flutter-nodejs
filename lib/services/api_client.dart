import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
  // IMPORTANT : Changez cette URL selon votre configuration
  // Pour Web/iOS Simulator: http://localhost:3000/api
  // Pour Android Emulator: http://10.0.2.2:3000/api
  // Pour appareil physique: http://VOTRE_IP:3000/api (ex: http://192.168.1.100:3000/api)
  static const String baseUrl = 'http://localhost:3000/api';
  
  static late Dio _dio;
  static CookieJar? _cookieJar;

  // Import de la méthode getToken depuis auth_service pour éviter la duplication
  // Cette méthode sera appelée par _getOptionsWithAuth
  static Future<String?> Function() getTokenCallback = () async => null;

  // Obtenir les options avec le token (pour Web)
  static Future<Options?> _getOptionsWithAuth() async {
    if (kIsWeb) {
      final token = await getTokenCallback();
      return Options(
        extra: {'withCredentials': true},
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
    }
    return null;
  }

  // Initialiser Dio avec gestion des cookies
  static void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
      // Sur le web, il faut activer withCredentials pour que les cookies HTTP-Only fonctionnent
      extra: {
        'withCredentials': true,
      },
    ));

    // Sur Web, les cookies sont gérés automatiquement par le navigateur
    // On n'utilise CookieManager que sur mobile/desktop
    if (!kIsWeb) {
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }
    
    // Intercepteur pour logger les requêtes (optionnel, utile pour le debug)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  // GET Request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: await _getOptionsWithAuth(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        endpoint, 
        data: body,
        options: await _getOptionsWithAuth(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(
        endpoint, 
        data: body,
        options: await _getOptionsWithAuth(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.patch(
        endpoint, 
        data: body,
        options: await _getOptionsWithAuth(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: await _getOptionsWithAuth(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart Request (pour upload de fichiers)
  // Accepte une liste de bytes pour fonctionner sur Web et Mobile
  static Future<Map<String, dynamic>> multipartBytes(
    String endpoint,
    Map<String, String> fields,
    List<MultipartFile> files,
  ) async {
    try {
      FormData formData = FormData();
      
      // Ajouter les champs texte
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Ajouter les fichiers
      for (var file in files) {
        formData.files.add(MapEntry('photos', file));
      }

      final response = await _dio.post(
        endpoint, 
        data: formData,
        options: await _getOptionsWithAuth(),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Vider les cookies (déconnexion)
  static Future<void> clearCookies() async {
    // Sur Web, les cookies sont gérés par le navigateur
    // Sur mobile/desktop, on utilise CookieJar
    if (!kIsWeb && _cookieJar != null) {
      await _cookieJar!.deleteAll();
    }
  }

  // Gestion des erreurs
  static ApiException _handleError(dynamic error) {
    if (error is DioException) {
      return ApiException(
        statusCode: error.response?.statusCode,
        message: error.response?.data['message'] ?? 
                 error.message ?? 
                 'Erreur de connexion',
      );
    }
    return ApiException(message: 'Erreur inconnue: $error');
  }
}

// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});

  @override
  String toString() => message;
}
