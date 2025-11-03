import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';

class GestionAlquileresScreen extends StatelessWidget {
  const GestionAlquileresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos DefaultTabController para manejar las pestañas
    return DefaultTabController(
      length: 2, // Dos pestañas: Activos y Finalizados
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alquileres'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Activos'),
              Tab(text: 'Finalizados'),
            ],
            // Estilos para que coincida con la imagen
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.stone600,
          ),
        ),
        body: SafeArea(
          // TabBarView para mostrar el contenido de cada pestaña
          child: TabBarView(
            children: [
              // Contenido de la pestaña "Activos"
              _AlquilerListView(
                alquileres: mockAlquileres
                    .where(
                      (a) => a.estado != AlquilerEstado.pendiente,
                    ) // Ejemplo de filtro
                    .toList(),
              ),
              // Contenido de la pestaña "Finalizados" (ponemos una lista vacía como ejemplo)
              _AlquilerListView(
                alquileres: mockAlquileres
                    .where(
                      (a) => a.estado == AlquilerEstado.pendiente,
                    ) // Ejemplo de filtro
                    .toList(),
              ),
            ],
          ),
        ),
        // Tu botón FAB para navegar a /alquileres/nuevo (Imagen 2)
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/alquileres/nuevo');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: const MainBottomNav(
          currentIndex: 1,
        ), // "Clientes" es el índice 1
      ),
    );
  }
}

// Widget interno para la lista (así no repetimos código)
class _AlquilerListView extends StatelessWidget {
  final List<Alquiler> alquileres;
  const _AlquilerListView({required this.alquileres});

  @override
  Widget build(BuildContext context) {
    if (alquileres.isEmpty) {
      return const Center(child: Text('No hay alquileres en esta categoría.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: alquileres.length,
      itemBuilder: (context, index) {
        final alquiler = alquileres[index];
        // Aquí creamos la tarjeta personalizada
        return _AlquilerCard(alquiler: alquiler);
      },
    );
  }
}

// Widget interno para la tarjeta de Alquiler (Diseño de la Imagen 3)
class _AlquilerCard extends StatelessWidget {
  final Alquiler alquiler;
  const _AlquilerCard({required this.alquiler});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/alquileres/detalle');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Columna para Cliente, Producto y Fechas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alquiler.cliente,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alquiler.producto,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${alquiler.fechaInicio} - ${alquiler.fechaDevolucion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.stone600,
                      ),
                    ),
                  ],
                ),
              ),
              // Espacio
              const SizedBox(width: 16),
              // Etiqueta de Estado
              _StatusTag(estado: alquiler.estado),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget interno para la etiqueta de estado (Activo, En Mora)
class _StatusTag extends StatelessWidget {
  final AlquilerEstado estado;
  const _StatusTag({required this.estado});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    Color backgroundColor;

    switch (estado) {
      case AlquilerEstado.activo:
        text = 'Activo';
        color = Colors.green.shade800;
        backgroundColor = Colors.green.shade100;
        break;
      case AlquilerEstado.atrasado:
        text = 'En Mora';
        color = Colors.red.shade800;
        backgroundColor = Colors.red.shade100;
        break;
      case AlquilerEstado.pendiente:
        text = 'Finalizado';
        color = Colors.grey.shade800;
        backgroundColor = Colors.grey.shade200;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
