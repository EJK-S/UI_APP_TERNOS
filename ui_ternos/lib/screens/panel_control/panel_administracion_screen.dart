// lib/screens/panel_administracion_screen.dart (CORREGIDO Y CONECTADO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORTAR INTL (para monedas y fechas)
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
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
            // --- ACCESOS RÁPIDOS (Sin cambios) ---
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
                  icon: Icons.shopping_cart,
                  label: 'Alquiler',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.gestionAlquileres);
                  },
                ),
                QuickActionCard(
                  icon: Icons.sell,
                  label: 'Venta',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.gestionVentas);
                  },
                ),
                QuickActionCard(
                  icon: Icons.inventory_2,
                  label: 'Inventario',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.inventario);
                  },
                ),
                QuickActionCard(
                  icon: Icons.pending_actions,
                  label: 'Citas Pendientes',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.citasPendientes);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. SECCIÓN DE RESUMEN (CORREGIDA) ---
            Text(
              'Resumen',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Usamos Consumer2 para escuchar a AMBOS providers
            Consumer2<AlquilerProvider, VentaProvider>(
              builder: (context, alquilerProvider, ventaProvider, child) {
                // 3. Manejar el estado de carga
                if (alquilerProvider.isLoading || ventaProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // --- 4. Calcular valores reales ---

                // Valor 1: Alquileres Activos
                final alquileresActivos = alquilerProvider.alquileres
                    .where((a) => a.estado != AlquilerEstado.pendiente)
                    .length;

                // Valor 2: Devoluciones Pendientes (En Mora)
                final devolucionesPendientes = alquilerProvider.alquileres
                    .where((a) => a.estado == AlquilerEstado.atrasado)
                    .length;

                // Valor 3: Ventas Totales DEL DÍA (¡Ahora es posible!)
                final now = DateTime.now();
                // Crea una fecha de "hoy" a medianoche (para comparar solo el día)
                final today = DateTime(now.year, now.month, now.day);

                final double ventasHoy = ventaProvider.ventas
                    .where((venta) {
                      // Normaliza la fecha de la venta (ignora la hora)
                      final ventaDate = DateTime(
                        venta.fecha.year,
                        venta.fecha.month,
                        venta.fecha.day,
                      );
                      // Compara si la fecha de la venta es igual a "hoy"
                      return ventaDate.isAtSameMomentAs(today);
                    })
                    .fold(0.0, (sum, venta) => sum + venta.total);

                // Formateador de moneda
                final currencyFormatter = NumberFormat.currency(
                  locale: 'es_PE', // O el local que prefieras
                  symbol: 'S/ ',
                  decimalDigits: 2,
                );

                // 5. Mostrar los widgets con los valores reales
                return Column(
                  children: [
                    SummaryStatCard(
                      title: 'Alquileres activos',
                      value: alquileresActivos.toString(), // <-- VALOR REAL
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 12),
                    SummaryStatCard(
                      title: 'Devoluciones pendientes (En Mora)',
                      value: devolucionesPendientes
                          .toString(), // <-- VALOR REAL
                      icon: Icons.watch_later,
                    ),
                    const SizedBox(height: 12),
                    SummaryStatCard(
                      title: 'Ventas totales del día', // <-- CORREGIDO
                      value: currencyFormatter.format(
                        ventasHoy,
                      ), // <-- VALOR REAL
                      icon: Icons.paid,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
