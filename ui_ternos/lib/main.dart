import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/providers/inventario_provider.dart';
import 'package:proyecto_tienda_ternos/providers/settings_provider.dart';
import 'package:proyecto_tienda_ternos/screens/panel_administracion_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nuevo_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquileres_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nuevo_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_ventas_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nueva_venta_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_pagos_screen.dart';
import 'package:proyecto_tienda_ternos/screens/inventario_ternos_screen.dart';
import 'package:proyecto_tienda_ternos/screens/generar_reportes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/configuracion_sistema_screen.dart';
import 'package:proyecto_tienda_ternos/screens/citas_pendientes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/registrar_terno_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nueva_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:proyecto_tienda_ternos/screens/lista_prendas_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // <-- Corchetes de LISTA
        ChangeNotifierProvider(create: (context) => AlquilerProvider()),
        ChangeNotifierProvider(create: (context) => CitaProvider()),
        ChangeNotifierProvider(create: (context) => VentaProvider()),
        ChangeNotifierProvider(create: (context) => ClienteProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => PrendaProvider()),
        ChangeNotifierProxyProvider<PrendaProvider, InventarioProvider>(
          // 'create' solo crea la instancia inicial
          create: (context) => InventarioProvider(
            // <-- Corregí mi typo de 'InventioProvider'
            Provider.of<PrendaProvider>(context, listen: false),
          ),

          // 'update' se asegura de que se actualice cuando PrendaProvider cambie
          update: (context, prendaProvider, inventarioProvider) {
            if (inventarioProvider == null)
              return InventarioProvider(prendaProvider);
            return inventarioProvider..update(prendaProvider);
          },
        ),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al SettingsProvider para el modo oscuro
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Gestión de Ternos',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(dark: false),
          darkTheme: buildTheme(dark: true),
          // El ThemeMode ahora es controlado por el Provider
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          // El mapa de rutas solo debe contener las rutas nombradas
          routes: {
            // <-- Llaves de MAPA
            '/': (_) => const PanelAdministracionScreen(),
            '/clientes': (_) => const GestionClientesScreen(),
            '/clientes/nuevo': (_) => const NuevoClienteScreen(),
            '/alquileres': (_) => const GestionAlquileresScreen(),
            '/alquileres/nuevo': (_) => const NuevoAlquilerScreen(),
            '/ventas': (_) => const GestionVentasScreen(),
            '/ventas/nueva': (_) => const NuevaVentaScreen(),
            '/pagos': (_) => const GestionPagosScreen(),
            '/inventario': (_) => const InventarioTernosScreen(),
            '/reportes': (_) => const GenerarReportesScreen(),
            '/config': (_) => const ConfiguracionSistemaScreen(),
            Routes.citasPendientes: (_) => const CitasPendientesScreen(),
            Routes.inventarioNuevo: (_) => const RegistrarTernoScreen(),
            Routes.nuevaCita: (_) => const NuevaCitaScreen(),
            Routes.listaPrendas: (_) => const ListaPrendasScreen(),
          }, // <-- Llaves de MAPA
        );
      },
    );
  }
}
