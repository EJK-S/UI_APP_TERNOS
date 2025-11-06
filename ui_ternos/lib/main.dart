import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/screens/panel_administracion_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nuevo_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquileres_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nuevo_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_pagos_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_ventas_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nueva_venta_screen.dart';
import 'package:proyecto_tienda_ternos/screens/detalles_venta_screen.dart';
import 'package:proyecto_tienda_ternos/screens/inventario_ternos_screen.dart';
import 'package:proyecto_tienda_ternos/screens/generar_reportes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/configuracion_sistema_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/screens/citas_pendientes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/registrar_terno_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nueva_cita_screen.dart';

void main() {
  // 2. Envuelve la app con el Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => AlquilerProvider(),
      child: const AppRoot(),
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AlquilerProvider()),
        ChangeNotifierProvider(create: (context) => CitaProvider()),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Ternos',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(dark: false),
      darkTheme: buildTheme(dark: true),
      initialRoute: '/',
      routes: {
        // Tu lista de rutas sigue exactamente igual
        '/': (_) => const PanelAdministracionScreen(),
        '/clientes': (_) => const GestionClientesScreen(),
        '/clientes/nuevo': (_) => const NuevoClienteScreen(),
        '/alquileres': (_) => const GestionAlquileresScreen(),
        '/alquileres/nuevo': (_) => const NuevoAlquilerScreen(),
        '/ventas': (_) => const GestionVentasScreen(),
        '/ventas/nueva': (_) => const NuevaVentaScreen(),
        '/ventas/detalle': (_) => const DetallesVentaScreen(),
        '/pagos': (_) => const GestionPagosScreen(),
        '/inventario': (_) => const InventarioTernosScreen(),
        '/reportes': (_) => const GenerarReportesScreen(),
        '/config': (_) => const ConfiguracionSistemaScreen(),
        Routes.citasPendientes: (_) => const CitasPendientesScreen(),
        Routes.inventarioNuevo: (_) => const RegistrarTernoScreen(),
        Routes.nuevaCita: (_) => const NuevaCitaScreen(),
      },
    );
  }
}
