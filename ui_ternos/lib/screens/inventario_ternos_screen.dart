import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/inventario_categoria.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class InventarioTernosScreen extends StatelessWidget {
  const InventarioTernosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Ternos')),
      body: SafeArea(
        child: Column(
          children: [
            // --- LISTA DE CATEGORÍAS ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mockInventarioCategorias.length,
                itemBuilder: (context, index) {
                  final categoria = mockInventarioCategorias[index];
                  return _InventarioCategoryCard(categoria: categoria);
                },
              ),
            ),

            // --- BOTONES DE ACCIÓN ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.inventarioNuevo);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Registrar nuevo terno',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Puedes crear una ruta /inventario/actualizar si es necesario
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.borderLight.withOpacity(0.5),
                      foregroundColor: AppColors.stone800,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Actualizar stock',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}

// --- WIDGET INTERNO PARA LA TARJETA DE CATEGORÍA ---
class _InventarioCategoryCard extends StatelessWidget {
  final InventarioCategoria categoria;
  const _InventarioCategoryCard({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título (ej. "Traje Clásico")
            Text(
              categoria.nombre,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            // Fila de estados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStockColumn('Disponibles', categoria.disponibles),
                _buildStockColumn('Alquilados', categoria.alquilados),
                _buildStockColumn('Mantenimiento', categoria.mantenimiento),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper para las columnas (Disponibles, Alquilados, etc.)
  Widget _buildStockColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.stone600, fontSize: 12),
        ),
      ],
    );
  }
}
