import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
//import '../../api_ternos/routes/routes.dart'; // 👈 importa tus rutas

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  const MainBottomNav({super.key, required this.currentIndex});

  void _handleTap(BuildContext context, int i) {
    if (i == currentIndex) return;
    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/clientes');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/pagos');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/ajustes');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => _handleTap(context, i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.stone600,
      backgroundColor: Theme.of(context).colorScheme.surface,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment_outlined),
          activeIcon: Icon(Icons.payment),
          label: 'Pagos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
