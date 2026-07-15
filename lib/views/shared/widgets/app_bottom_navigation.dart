import 'package:flutter/material.dart';

// CORRECTION DE L'IMPORT : Remplacement par le chemin absolu de ton projet
// (Remplace 'ton_nom_de_projet' par le nom exact écrit à la ligne 1 de ton pubspec.yaml)
import 'package:freelance_front/controllers/auth/auth_controller.dart';

class AppBottomNavigation extends StatelessWidget {
  final AuthController authController;
  final String currentRoute;
  final Function(String routeName)? onRouteSelected;

  const AppBottomNavigation({
    super.key,
    required this.authController,
    required this.currentRoute,
    this.onRouteSelected,
  });

  // Liste ordonnée de nos éléments de navigation
  final List<Map<String, dynamic>> _menuItems = const [
    {
      'route': '/dashboard',
      'label': 'Accueil',
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
    },
    {
      'route': '/tasks',
      'label': 'Missions',
      'icon': Icons.assignment_outlined,
      'activeIcon': Icons.assignment,
    },
    {
      'route': '/profile',
      'label': 'Profil',
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // On trouve l'index de la route actuelle dans notre liste, sinon par défaut 0
    int currentIndex = _menuItems.indexWhere(
      (item) => item['route'] == currentRoute,
    );
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed, // Aligne proprement les icônes
        onTap: (index) {
          final selectedRoute = _menuItems[index]['route'] as String;

          if (onRouteSelected != null) {
            onRouteSelected!(selectedRoute);
          } else {
            // Navigation par défaut : on évite de recharger la page si on clique sur l'onglet actif
            if (currentRoute != selectedRoute) {
              Navigator.pushReplacementNamed(
                context,
                selectedRoute,
                arguments: authController,
              );
            }
          }
        },
        items: _menuItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            activeIcon: Icon(item['activeIcon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }
}
