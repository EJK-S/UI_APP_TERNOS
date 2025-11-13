import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_inventario/editar_prenda_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_inventario/registrar_terno_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class ListaPrendasScreen extends StatelessWidget {
  // --- ACEPTA EL NOMBRE DE LA CATEGORÍA ---
  final String categoriaNombre;
  const ListaPrendasScreen({super.key, required this.categoriaNombre});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrendaProvider>(
      builder: (context, prendaProvider, child) {
        // --- FILTRA LA LISTA DE PRENDAS ---
        final prendas = prendaProvider.getPrendasPorCategoria(categoriaNombre);

        return Scaffold(
          appBar: AppBar(title: Text('Prendas: $categoriaNombre')),
          body: SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: prendas.length,
              itemBuilder: (context, index) {
                final prenda = prendas[index];
                return _PrendaCard(prenda: prenda);
              },
            ),
          ),
          // --- AÑADE EL BOTÓN FLOTANTE (+) ---
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Navega a la pantalla de "Registrar Terno"
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrarTernoScreen(
                    // ¡AQUÍ ESTÁ LA MAGIA!
                    // Pasamos la categoría de esta pantalla a la siguiente
                    categoriaPreseleccionada: categoriaNombre,
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

// (El widget _PrendaCard es el mismo de la respuesta anterior,
// con su PopupMenuButton de Editar/Eliminar. Lo copio aquí)
class _PrendaCard extends StatelessWidget {
  final Prenda prenda;
  const _PrendaCard({required this.prenda});

  @override
  Widget build(BuildContext context) {
    final prendaProvider = Provider.of<PrendaProvider>(context, listen: false);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prenda.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${prenda.id} • Talla: ${prenda.talla}', // Ya no mostramos categoría
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.stone600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: prenda.estado.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prenda.estado.texto,
                      style: TextStyle(
                        color: prenda.estado.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarPrendaScreen(prenda: prenda),
                    ),
                  );
                } else if (value == 'eliminar') {
                  prendaProvider.eliminarPrenda(prenda.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
