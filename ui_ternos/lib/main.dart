import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/providers/inventario_provider.dart';
import 'package:proyecto_tienda_ternos/providers/settings_provider.dart';
import 'package:proyecto_tienda_ternos/screens/panel_control/panel_administracion_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes/gestion_clientes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes/nuevo_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/gestion_alquileres_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/nuevo_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_ventas/gestion_ventas_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_ventas/nueva_venta_screen.dart';
import 'package:proyecto_tienda_ternos/screens/pagos/gestion_pagos_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_inventario/inventario_ternos_screen.dart';
import 'package:proyecto_tienda_ternos/screens/reportes/generar_reportes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/configuracion/configuracion_sistema_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_citas/citas_pendientes_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_inventario/registrar_terno_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_citas/nueva_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes/seleccionar_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/data/repositories/cliente_repository.dart';
import 'package:proyecto_tienda_ternos/data/repositories/venta_repository.dart';
import 'package:proyecto_tienda_ternos/data/repositories/alquiler_repository.dart';
import 'package:proyecto_tienda_ternos/data/repositories/cita_repository.dart';
import 'package:proyecto_tienda_ternos/data/repositories/prenda_repository.dart';
import 'package:proyecto_tienda_ternos/data/repositories/pago_repository.dart';
import 'package:proyecto_tienda_ternos/providers/pago_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // --- NIVEL 0: REPOSITORIOS (No tienen dependencias) ---
        Provider(create: (context) => ClienteRepository()),
        Provider(create: (context) => VentaRepository()),
        Provider(create: (context) => AlquilerRepository()),
        Provider(create: (context) => CitaRepository()),
        Provider(create: (context) => PrendaRepository()),
        Provider(create: (context) => PagoRepository()),

        // --- NIVEL 1: PROVIDERS BÁSICOS (Dependen solo de Repositorios) ---
        ChangeNotifierProvider(create: (context) => SettingsProvider()),

        ChangeNotifierProxyProvider<ClienteRepository, ClienteProvider>(
          create: (context) =>
              ClienteProvider(context.read<ClienteRepository>())
                ..fetchClientes(), // <-- CORREGIDO
          update: (context, repo, prev) => prev ?? ClienteProvider(repo),
        ),
        ChangeNotifierProxyProvider<CitaRepository, CitaProvider>(
          create: (context) =>
              CitaProvider(context.read<CitaRepository>())
                ..fetchCitas(), // <-- CORREGIDO
          update: (context, repo, prev) => prev ?? CitaProvider(repo),
        ),
        ChangeNotifierProxyProvider<PrendaRepository, PrendaProvider>(
          create: (context) =>
              PrendaProvider(context.read<PrendaRepository>())
                ..fetchPrendas(), // <-- CORREGIDO
          update: (context, repo, prev) => prev ?? PrendaProvider(repo),
        ),
        ChangeNotifierProxyProvider<PagoRepository, PagoProvider>(
          create: (context) =>
              PagoProvider(context.read<PagoRepository>())
                ..fetchPagos(), // <-- CORREGIDO
          update: (context, repo, prev) => prev ?? PagoProvider(repo),
        ),

        // --- NIVEL 2: PROVIDERS COMPUESTOS (Dependen de otros Providers) ---
        ChangeNotifierProxyProvider<PrendaProvider, InventarioProvider>(
          create: (context) =>
              InventarioProvider(context.read<PrendaProvider>()),
          update: (context, prendaProvider, invProvider) =>
              invProvider!..update(prendaProvider),
        ),

        ChangeNotifierProxyProvider2<
          AlquilerRepository,
          PagoProvider,
          AlquilerProvider
        >(
          create: (context) => AlquilerProvider(
            context.read<AlquilerRepository>(),
            context.read<PagoProvider>(),
          )..fetchAlquileres(), // <-- CORREGIDO
          update: (context, alqRepo, pagoProvider, previous) =>
              previous!..updatePagoProvider(pagoProvider),
        ),

        ChangeNotifierProxyProvider2<
          VentaRepository,
          PagoProvider,
          VentaProvider
        >(
          create: (context) => VentaProvider(
            context.read<VentaRepository>(),
            context.read<PagoProvider>(),
          )..fetchVentas(), // <-- CORREGIDO
          update: (context, ventaRepo, pagoProvider, previous) =>
              previous!..updatePagoProvider(pagoProvider),
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
            Routes.nuevaCita: (_) => const NuevaCitaScreen(),
            Routes.seleccionarCliente: (_) => const SeleccionarClienteScreen(),
          }, // <-- Llaves de MAPA
        );
      },
    );
  }
}
