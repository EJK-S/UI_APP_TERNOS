import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/widgets/quick_action_card.dart';
import 'package:proyecto_tienda_ternos/widgets/summary_stat_card.dart';

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
            // --- ACCESOS RÁPIDOS (Actualizados) ---
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
                  icon: Icons.shopping_cart, // Ícono de 'Alquiler'
                  label: 'Alquiler',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.gestionAlquileres);
                  },
                ),
                QuickActionCard(
                  icon: Icons.sell, // Ícono de 'Venta'
                  label: 'Venta',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.gestionVentas);
                  },
                ),
                QuickActionCard(
                  icon: Icons.inventory_2, // Ícono de 'Inventario'
                  label: 'Inventario',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.inventario);
                  },
                ),
                QuickActionCard(
                  icon: Icons.pending_actions, // Ícono de 'Citas Pendientes'
                  label: 'Citas Pendientes',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.citasPendientes);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- RESUMEN (Actualizado) ---
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
              icon: Icons.calendar_today, // Ícono de calendario
            ),
            const SizedBox(height: 12),
            const SummaryStatCard(
              title: 'Devoluciones pendientes',
              value: '3',
              icon: Icons.watch_later, // Ícono de reloj
            ),
            const SizedBox(height: 12),
            const SummaryStatCard(
              title: 'Ventas totales del día',
              value: 'S/ 1,250',
              icon: Icons.paid, // Ícono de dinero
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
