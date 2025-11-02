import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/widgets/summary_stat_card.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
// No es necesario importar 'venta.dart' aquí, 'mock_data.dart' ya lo sabe.

class GestionVentasScreen extends StatelessWidget {
  const GestionVentasScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            onPressed: () {
              Navigator.pushNamed(context, '/ventas/nueva');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              'Ventas del día',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: borderColor),
              ),
              child: Column(
                // 'v' ahora es un objeto Venta
                children: mockVentas.map((v) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          v.codigo, // <-- ANTES: v['codigo'] ?? ''
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          // <-- ANTES: '${v['cliente']} • ${v['fecha']}'
                          '${v.cliente} • ${v.fecha}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.subtleDark
                                : AppColors.subtleLight,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              v.total, // <-- ANTES: v['total'] ?? ''
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/ventas/detalle');
                        },
                      ),
                      if (v != mockVentas.last)
                        Divider(
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const SummaryStatCard(
              title: 'Total vendido hoy',
              value: 'S/ 800.00',
              icon: Icons.attach_money,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
