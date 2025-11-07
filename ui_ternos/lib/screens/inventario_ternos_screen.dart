import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/inventario_categoria.dart';
import 'package:proyecto_tienda_ternos/providers/inventario_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
// Importamos la pantalla de lista de prendas
import 'package:proyecto_tienda_ternos/screens/lista_prendas_screen.dart';

class InventarioTernosScreen extends StatelessWidget {
  const InventarioTernosScreen({super.key});

  // --- NUEVO: Diálogo para agregar categoría ---
  void _mostrarDialogoAgregarCategoria(BuildContext context) {
    final TextEditingController _categoriaCtrl = TextEditingController();
    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Tipo'),
          content: TextField(
            controller: _categoriaCtrl,
            decoration: const InputDecoration(hintText: 'Ej. Smokings'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Agregar'),
              onPressed: () {
                inventarioProvider.agregarCategoria(_categoriaCtrl.text);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventarioProvider>(
      builder: (context, inventarioProvider, child) {
        final categorias = inventarioProvider.categorias;

        return Scaffold(
          appBar: AppBar(title: const Text('Inventario de Ternos')),
          body: SafeArea(
            child: Column(
              children: [
                // --- LISTA DE CATEGORÍAS ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      // --- CAMBIO: Hacemos la tarjeta clicable ---
                      return _InventarioCategoryCard(
                        categoria: categoria,
                        onTap: () {
                          // Navega a la lista de prendas, pasando el nombre de la categoría
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListaPrendasScreen(
                                categoriaNombre: categoria.nombre,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // --- BOTONES DE ACCIÓN (Actualizados) ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // --- CAMBIO: Llama al diálogo ---
                          _mostrarDialogoAgregarCategoria(context);
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
                          'Agregar nuevo tipo de prenda', // <-- Texto cambiado
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          inventarioProvider.actualizarStock();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Stock actualizado (simulado).'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.borderLight.withOpacity(
                            0.5,
                          ),
                          foregroundColor: AppColors.stone800,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Actualizar stock', // <-- Texto se mantiene
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
      },
    );
  }
}

// --- WIDGET INTERNO (Ahora con 'onTap') ---
class _InventarioCategoryCard extends StatelessWidget {
  final InventarioCategoria categoria;
  final VoidCallback onTap; // <-- Acepta una función onTap

  const _InventarioCategoryCard({required this.categoria, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // --- CAMBIO: Envuelto en InkWell ---
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoria.nombre,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20),
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
      ),
    );
  }

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
