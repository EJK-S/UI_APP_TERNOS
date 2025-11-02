import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  const MainBottomNav({super.key, required this.currentIndex});

  void _handleTap(BuildContext context, int i) {
    if (i == currentIndex) return;
    switch (i) {
      case 0:
        Navigator.pushReplacementNamed(context, Routes.panelAdministracion);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, Routes.gestionClientes);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, Routes.configuracionSistema);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.stone600,
      backgroundColor: Theme.of(context).colorScheme.surface,
      onTap: (i) => _handleTap(context, i),
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
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
