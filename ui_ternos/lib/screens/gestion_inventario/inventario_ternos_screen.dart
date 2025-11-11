import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/inventario_categoria.dart';
import 'package:proyecto_tienda_ternos/providers/inventario_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_inventario/lista_prendas_screen.dart';

// --- 1. CONVERTIDO A STATEFULWIDGET ---
class InventarioTernosScreen extends StatefulWidget {
  const InventarioTernosScreen({super.key});

  @override
  State<InventarioTernosScreen> createState() => _InventarioTernosScreenState();
}

class _InventarioTernosScreenState extends State<InventarioTernosScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- (El diálogo _mostrarDialogoAgregarCategoria se queda igual) ---
  void _mostrarDialogoAgregarCategoria(
    BuildContext context,
    InventarioProvider inventarioProvider,
  ) {
    final TextEditingController _categoriaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Tipo'),
          content: TextField(
            controller: _categoriaCtrl,
            decoration: const InputDecoration(hintText: 'Ej. Smokings'),
            autofocus: true, // Abre el teclado automáticamente
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Agregar'),
              onPressed: () {
                // 1. Llama al provider (que se pasó como argumento)
                inventarioProvider.agregarCategoria(_categoriaCtrl.text);
                // 2. Cierra el diálogo
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
    // Obtenemos el provider aquí para los botones
    final inventarioProvider = Provider.of<InventarioProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Ternos')),
      body: SafeArea(
        // --- 2. EL CONSUMER AHORA SOLO ENVUELVE LA LISTA ---
        child: Column(
          children: [
            // --- 3. AÑADIMOS LA BARRA DE BÚSQUEDA ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Buscar categoría...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Llama al provider para filtrar en cada tecleo
                  inventarioProvider.filtrarCategorias(value);
                },
              ),
            ),
            // --- 4. LISTA DE CATEGORÍAS (envuelta en Consumer) ---
            Expanded(
              child: Consumer<InventarioProvider>(
                builder: (context, provider, child) {
                  final categorias = provider.categorias;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return _InventarioCategoryCard(
                        categoria: categoria,
                        onTap: () {
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
                  );
                },
              ),
            ),

            // --- 5. BOTONES DE ACCIÓN (sin cambios) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _mostrarDialogoAgregarCategoria(
                        context,
                        inventarioProvider,
                      );
                    },
                    // ... (estilo)
                    child: const Text(
                      'Agregar nuevo tipo de prenda',
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
                    // ... (estilo)
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
