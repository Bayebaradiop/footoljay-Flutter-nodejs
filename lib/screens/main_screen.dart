import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import 'home_screen.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ProductListScreen(), // Page d'accueil: liste des produits (accessible sans connexion)
      AddProductScreen(),  // Vendre un produit (nécessite connexion)
      HomeScreen(),        // Profil utilisateur (nécessite connexion)
    ];
  }

  // Vérifier si l'utilisateur est connecté avant de changer d'onglet
  Future<void> _onTabTapped(int index) async {
    // L'onglet "Accueil" (index 0) est toujours accessible
    if (index == 0) {
      setState(() {
        _currentIndex = index;
      });
      return;
    }

    // Pour les autres onglets, vérifier la connexion
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        setState(() {
          _currentIndex = index;
        });
      } else {
        // Rediriger vers la page de connexion
        if (mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          );
          
          // Si l'utilisateur s'est connecté, aller à l'onglet demandé
          if (result == true && mounted) {
            setState(() {
              _currentIndex = index;
            });
          }
        }
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers la connexion
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Vendre',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
