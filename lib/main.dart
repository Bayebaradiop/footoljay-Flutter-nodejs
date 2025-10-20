import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Initialiser le client API avec gestion des cookies
  ApiClient.initialize();
  
  // Configurer le callback pour récupérer le token
  ApiClient.getTokenCallback = AuthService.getToken;
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOTOL JAY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Page de démarrage : liste des produits (accessible sans connexion)
      home: MainScreen(),
    );
  }
}