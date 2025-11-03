import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
// Importa el modelo
import 'package:proyecto_tienda_ternos/models/inventario_item.dart';

class InventarioTernosScreen extends StatelessWidget {
  const InventarioTernosScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    // Función auxiliar para manejar el color y texto del enum
    Color estadoColor(InventarioEstado e) {
      switch (e) {
        case InventarioEstado.disponible:
          return Colors.green;
        case InventarioEstado.alquilado:
          return Colors.orange;
        case InventarioEstado.mantenimiento:
          return Colors.red;
        default:
          return AppColors.primary;
      }
    }

    String estadoTexto(InventarioEstado e) {
      switch (e) {
        case InventarioEstado.disponible:
          return 'Disponible';
        case InventarioEstado.alquilado:
          return 'Alquilado';
        case InventarioEstado.mantenimiento:
          return 'Mantenimiento';
        default:
          return '';
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Ternos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por talla, color, estado...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Column(
                // 'item' ahora es un objeto InventarioItem
                children: mockStock.map((item) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          item.prenda, // <-- ANTES: item['prenda'] ?? ''
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Usos: ${item.usos}', // <-- ANTES: 'Usos: ${item['usos']}'
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
                              estadoTexto(
                                item.estado,
                              ), // <-- Usamos la función auxiliar
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: estadoColor(
                                  item.estado,
                                ), // <-- Usamos la función auxiliar
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                      if (item != mockStock.last)
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
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
