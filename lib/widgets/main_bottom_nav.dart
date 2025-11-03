import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  const MainBottomNav({super.key, required this.currentIndex});

  void _handleTap(BuildContext context, int i) {
    if (i == currentIndex) return;

    // LÓGICA DE NAVEGACIÓN CORREGIDA
    switch (i) {
      case 0: // Inicio
        Navigator.pushReplacementNamed(context, Routes.panelAdministracion);
        break;
      case 1: // Clientes
        Navigator.pushReplacementNamed(context, Routes.gestionClientes);
        break;
      case 2: // Pagos (NUEVO)
        Navigator.pushReplacementNamed(
          context,
          Routes.pagos,
        ); // Ruta que creamos
        break;
      case 3: // Ajustes (AHORA ES EL ÍNDICE 3)
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

      // Asegúrate de que el tipo sea 'fixed' para que se vean los 4 items
      type: BottomNavigationBarType.fixed,

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
          icon: Icon(Icons.payment_outlined), // ÍCONO CORREGIDO
          activeIcon: Icon(Icons.payment), // ÍCONO ACTIVO AÑADIDO
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
