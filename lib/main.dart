import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/panel_administracion_screen.dart';
import 'screens/gestion_clientes_screen.dart';
import 'screens/nuevo_cliente_screen.dart';
import 'screens/gestion_alquileres_screen.dart';
import 'screens/nuevo_alquiler_screen.dart';
import 'screens/detalles_alquiler_screen.dart';
import 'screens/devolucion_ternos_screen.dart';
import 'screens/gestion_ventas_screen.dart';
import 'screens/nueva_venta_screen.dart';
import 'screens/detalles_venta_screen.dart';
import 'screens/inventario_ternos_screen.dart';
import 'screens/generar_reportes_screen.dart';
import 'screens/configuracion_sistema_screen.dart';

void main() {
  runApp(const AppRoot());
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
        '/': (_) => const PanelAdministracionScreen(),
        '/clientes': (_) => const GestionClientesScreen(),
        '/clientes/nuevo': (_) => const NuevoClienteScreen(),
        '/alquileres': (_) => const GestionAlquileresScreen(),
        '/alquileres/nuevo': (_) => const NuevoAlquilerScreen(),
        '/alquileres/detalle': (_) => const DetallesAlquilerScreen(),
        '/alquileres/devolucion': (_) => const DevolucionTernosScreen(),
        '/ventas': (_) => const GestionVentasScreen(),
        '/ventas/nueva': (_) => const NuevaVentaScreen(),
        '/ventas/detalle': (_) => const DetallesVentaScreen(),
        '/inventario': (_) => const InventarioTernosScreen(),
        '/reportes': (_) => const GenerarReportesScreen(),
        '/config': (_) => const ConfiguracionSistemaScreen(),
      },
    );
  }
}
