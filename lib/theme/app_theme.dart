import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0A66C2);
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color backgroundDark = Color(0xFF101922);
  static const Color foregroundLight = Color(0xFF111827);
  static const Color foregroundDark = Color(0xFFF9FAFB);
  static const Color subtleLight = Color(0xFF6B7280);
  static const Color subtleDark = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);
  static const Color stone900 = Color(0xFF0C0A09);
  static const Color stone800 = Color(0xFF1C1917);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone300 = Color(0xFFD6D3D1);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color successLight = Color(0xFF16A34A);
}

ThemeData buildTheme({bool dark = false}) {
  final ColorScheme scheme = ColorScheme(
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primary,
    onSecondary: Colors.white,
    surface: dark ? AppColors.backgroundDark : Colors.white,
    onSurface: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
    background: dark ? AppColors.backgroundDark : AppColors.backgroundLight,
    onBackground: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
    error: Colors.red,
    onError: Colors.white,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: dark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      foregroundColor: dark
          ? AppColors.foregroundDark
          : AppColors.foregroundLight,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
      ),
      iconTheme: IconThemeData(
        color: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        color: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: dark ? AppColors.foregroundDark : AppColors.foregroundLight,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Manrope',
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: dark ? AppColors.subtleDark : AppColors.subtleLight,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.stone300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      hintStyle: TextStyle(color: AppColors.stone400, fontSize: 14),
      labelStyle: TextStyle(
        color: AppColors.stone700,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
  );
}

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

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const SummaryStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Icon(
            icon,
            size: 28,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.subtleDark
                : AppColors.subtleLight,
          ),
        ],
      ),
    );
  }
}

class Routes {
  static const String panelAdministracion = '/';
  static const String gestionClientes = '/clientes';
  static const String nuevoCliente = '/clientes/nuevo';
  static const String gestionAlquileres = '/alquileres';
  static const String nuevoAlquiler = '/alquileres/nuevo';
  static const String detallesAlquiler = '/alquileres/detalle';
  static const String devolucionTernos = '/alquileres/devolucion';
  static const String gestionVentas = '/ventas';
  static const String nuevaVenta = '/ventas/nueva';
  static const String detallesVenta = '/ventas/detalle';
  static const String inventario = '/inventario';
  static const String reportes = '/reportes';
  static const String configuracionSistema = '/config';
}
