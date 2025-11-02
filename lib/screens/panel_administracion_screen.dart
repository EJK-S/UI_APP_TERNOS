import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/widgets/quick_action_card.dart';
import 'package:proyecto_tienda_ternos/widgets/summary_stat_card.dart';
import '../theme/app_theme.dart';
import 'nuevo_alquiler_screen.dart';
import 'nueva_venta_screen.dart';
import 'devolucion_ternos_screen.dart';
import 'generar_reportes_screen.dart';

class PanelAdministracionScreen extends StatelessWidget {
  const PanelAdministracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Accesos Rápidos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                QuickActionCard(
                  icon: Icons.add_shopping_cart,
                  label: 'Registrar Alquiler',
                  onTap: () {
                    Navigator.pushNamed(context, '/alquileres/nuevo');
                  },
                ),
                QuickActionCard(
                  icon: Icons.sell_outlined,
                  label: 'Registrar Venta',
                  onTap: () {
                    Navigator.pushNamed(context, '/ventas/nueva');
                  },
                ),
                QuickActionCard(
                  icon: Icons.assignment_return,
                  label: 'Devoluciones',
                  onTap: () {
                    Navigator.pushNamed(context, '/alquileres/devolucion');
                  },
                ),
                QuickActionCard(
                  icon: Icons.bar_chart,
                  label: 'Reportes',
                  onTap: () {
                    Navigator.pushNamed(context, '/reportes');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Resumen',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const SummaryStatCard(
              title: 'Alquileres activos',
              value: '15',
              icon: Icons.inventory_2,
            ),
            const SizedBox(height: 12),
            const SummaryStatCard(
              title: 'Devoluciones pendientes',
              value: '3',
              icon: Icons.schedule,
            ),
            const SizedBox(height: 12),
            const SummaryStatCard(
              title: 'Ventas totales del día',
              value: 'S/ 1,250',
              icon: Icons.paid,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
