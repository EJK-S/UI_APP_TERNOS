// lib/screens/gestion_alquileres_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORTAMOS PROVIDER
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart'; // <-- 2. IMPORTAMOS EL CEREBRO
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/screens/detalles_alquiler_screen.dart';
// import 'package:proyecto_tienda_ternos/data/mock_data.dart'; // <-- 3. YA NO NECESITAMOS LOS DATOS MOCK
import 'package:proyecto_tienda_ternos/models/alquiler.dart';

class GestionAlquileresScreen extends StatelessWidget {
  const GestionAlquileresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. PEDIMOS LA INSTANCIA DEL PROVIDER
    // (Esto NO escucha cambios, solo es para leer datos iniciales si fuera necesario)
    // final alquilerProvider = Provider.of<AlquilerProvider>(context);

    // 5. USAMOS UN CONSUMER PARA "ESCUCHAR" CAMBIOS
    return Consumer<AlquilerProvider>(
      builder: (context, alquilerProvider, child) {
        // 'alquilerProvider' es la instancia de nuestro cerebro.
        // 'child' es un widget que podemos pasar si no queremos que se redibuje (no lo usamos aquí).

        // Ahora, en lugar de usar 'mockAlquileres', usamos la lista VIVA del provider:
        final alquileresActivos = alquilerProvider.alquileres
            .where((a) => a.estado != AlquilerEstado.pendiente)
            .toList();
        final alquileresFinalizados = alquilerProvider.alquileres
            .where((a) => a.estado == AlquilerEstado.pendiente)
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Alquileres'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Activos'),
                  Tab(text: 'Finalizados'),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.stone600,
              ),
            ),
            body: SafeArea(
              child: TabBarView(
                children: [
                  // Contenido de la pestaña "Activos"
                  _AlquilerListView(
                    alquileres:
                        alquileresActivos, // <-- 6. Usamos la lista del provider
                  ),
                  // Contenido de la pestaña "Finalizados"
                  _AlquilerListView(
                    alquileres:
                        alquileresFinalizados, // <-- 7. Usamos la lista del provider
                  ),
                ],
              ),
            ),
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
      },
    );
  }
}

// --- NINGÚN CAMBIO DE AQUÍ PARA ABAJO ---
// (Los widgets internos (_AlquilerListView, _AlquilerCard, _StatusTag)
// siguen exactamente iguales, ya que ahora reciben la lista filtrada)

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
        return _AlquilerCard(alquiler: alquiler);
      },
    );
  }
}

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesAlquilerScreen(alquiler: alquiler),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
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
              const SizedBox(width: 16),
              _StatusTag(estado: alquiler.estado),
            ],
          ),
        ),
      ),
    );
  }
}

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
