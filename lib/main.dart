import 'package:flutter/material.dart';
import 'theme.dart';
import 'panel_administracion_screen.dart';
import 'gestion_clientes_screen.dart';
import 'nuevo_cliente_screen.dart';
import 'gestion_alquileres_screen.dart';
import 'nuevo_alquiler_screen.dart';
import 'detalles_alquiler_screen.dart';
import 'devolucion_ternos_screen.dart';
import 'gestion_ventas_screen.dart';
import 'nueva_venta_screen.dart';
import 'detalles_venta_screen.dart';
import 'inventario_ternos_screen.dart';
import 'generar_reportes_screen.dart';
import 'configuracion_sistema_screen.dart';

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
