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
        Provider(create: (context) => ClienteRepository()),
        Provider(create: (context) => VentaRepository()),
        Provider(create: (context) => AlquilerRepository()),
        Provider(create: (context) => CitaRepository()),
        Provider(create: (context) => PrendaRepository()),
        Provider(create: (context) => PagoRepository()),

        // <-- Corchetes de LISTA
        ChangeNotifierProxyProvider<AlquilerRepository, AlquilerProvider>(
          create: (context) => AlquilerProvider(
            Provider.of<AlquilerRepository>(context, listen: false),
          ),
          update: (context, repository, previousProvider) =>
              previousProvider ?? AlquilerProvider(repository),
        ),
        ChangeNotifierProxyProvider<CitaRepository, CitaProvider>(
          create: (context) =>
              CitaProvider(Provider.of<CitaRepository>(context, listen: false)),
          update: (context, repository, previousProvider) =>
              previousProvider ?? CitaProvider(repository),
        ),
        ChangeNotifierProxyProvider<VentaRepository, VentaProvider>(
          create: (context) => VentaProvider(
            Provider.of<VentaRepository>(context, listen: false),
          ),
          update: (context, repository, previousProvider) =>
              previousProvider ?? VentaProvider(repository),
        ),
        ChangeNotifierProxyProvider<ClienteRepository, ClienteProvider>(
          create: (context) => ClienteProvider(
            Provider.of<ClienteRepository>(context, listen: false),
          ),
          update: (context, repository, previousProvider) =>
              previousProvider ?? ClienteProvider(repository),
        ),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProxyProvider<PrendaRepository, PrendaProvider>(
          create: (context) => PrendaProvider(
            Provider.of<PrendaRepository>(context, listen: false),
          ),
          update: (context, repository, previousProvider) =>
              previousProvider ?? PrendaProvider(repository),
        ),
        ChangeNotifierProxyProvider<PrendaProvider, InventarioProvider>(
          create: (context) => InventarioProvider(
            Provider.of<PrendaProvider>(context, listen: false),
          ),

          update: (context, prendaProvider, inventarioProvider) {
            if (inventarioProvider == null)
              return InventarioProvider(prendaProvider);
            return inventarioProvider..update(prendaProvider);
          },
        ),

        ChangeNotifierProxyProvider<PagoRepository, PagoProvider>(
          create: (context) =>
              PagoProvider(Provider.of<PagoRepository>(context, listen: false)),
          update: (context, repository, previousProvider) =>
              previousProvider ?? PagoProvider(repository),
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
            Routes.seleccionarCliente: (_) => const SeleccionarClienteScreen(),
          }, // <-- Llaves de MAPA
        );
      },
    );
  }
}
