import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/screens/detalles_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class GestionAlquileresScreen extends StatelessWidget {
  // --- 1. AÑADIMOS UN FILTRO OPCIONAL ---
  final String? filtroClienteNombre;

  const GestionAlquileresScreen({
    super.key,
    this.filtroClienteNombre, // El filtro es opcional
  });

  @override
  Widget build(BuildContext context) {
    // --- 2. DETERMINAMOS SI ESTAMOS EN MODO FILTRO ---
    final bool enModoFiltro = (filtroClienteNombre != null);

    return Consumer<AlquilerProvider>(
      builder: (context, alquilerProvider, child) {
        // --- 3. LÓGICA DE FILTRADO ---
        List<Alquiler> todosLosAlquileres = alquilerProvider.alquileres;
        List<Alquiler> alquileresFiltrados;

        if (enModoFiltro) {
          // Si hay filtro, filtramos la lista
          alquileresFiltrados = todosLosAlquileres
              .where((a) => a.cliente == filtroClienteNombre)
              .toList();
        } else {
          // Si no hay filtro, mostramos todo
          alquileresFiltrados = todosLosAlquileres;
        }

        // Dividimos en pestañas
        final alquileresActivos = alquileresFiltrados
            .where((a) => a.estado != AlquilerEstado.pendiente)
            .toList();
        final alquileresFinalizados = alquileresFiltrados
            .where((a) => a.estado == AlquilerEstado.pendiente)
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              // --- 4. TÍTULO DINÁMICO ---
              title: Text(
                enModoFiltro
                    ? 'Alquileres de $filtroClienteNombre'
                    : 'Alquileres',
              ),
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
                  _AlquilerListView(alquileres: alquileresActivos),
                  _AlquilerListView(alquileres: alquileresFinalizados),
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

            // --- 5. LÓGICA DE NAVEGACIÓN INFERIOR ---
            // Si estamos filtrando, no mostramos la barra principal
            bottomNavigationBar: enModoFiltro
                ? null // No muestra la barra, ya que estamos "dentro" de Clientes
                : const MainBottomNav(currentIndex: 0),
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
