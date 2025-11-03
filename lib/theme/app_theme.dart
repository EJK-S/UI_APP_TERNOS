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
