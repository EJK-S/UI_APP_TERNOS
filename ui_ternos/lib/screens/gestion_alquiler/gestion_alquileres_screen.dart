// lib/screens/gestion_alquileres_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
// 1. IMPORTA EL CLIENTE PROVIDER Y EL MODELO
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
// ---
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/detalles_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:intl/intl.dart';

class GestionAlquileresScreen extends StatelessWidget {
  final String? filtroClienteNombre;

  const GestionAlquileresScreen({super.key, this.filtroClienteNombre});

  @override
  Widget build(BuildContext context) {
    final bool enModoFiltro = (filtroClienteNombre != null);

    return Consumer<AlquilerProvider>(
      builder: (context, alquilerProvider, child) {
        List<Alquiler> todosLosAlquileres = alquilerProvider.alquileres;
        List<Alquiler> alquileresFiltrados;

        if (enModoFiltro) {
          // 2. ACTUALIZA EL FILTRO PARA USAR EL ID
          // (Buscamos el ID del cliente basado en el nombre)
          final clienteProvider = Provider.of<ClienteProvider>(
            context,
            listen: false,
          );
          int clienteId = 1;
          try {
            // Buscamos el cliente por nombre
            final cliente = clienteProvider.clientes.firstWhere(
              (c) => '${c.nombre} ${c.apellidos ?? ''}' == filtroClienteNombre,
            );
            clienteId = cliente.id!; // Usamos su DNI (ID)
          } catch (e) {
            // Maneja el caso si el cliente no se encuentra
          }

          alquileresFiltrados = todosLosAlquileres
              .where((a) => a.clienteId == clienteId)
              .toList();
        } else {
          alquileresFiltrados = todosLosAlquileres;
        }

        // (El resto de la lógica de pestañas sigue igual)
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
            bottomNavigationBar: enModoFiltro
                ? null
                : const MainBottomNav(currentIndex: 0),
          ),
        );
      },
    );
  }
}

// --- El _AlquilerListView no cambia ---
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

// --- EL _AlquilerCard CAMBIA SIGNIFICATIVAMENTE ---
class _AlquilerCard extends StatelessWidget {
  final Alquiler alquiler;
  const _AlquilerCard({required this.alquiler});

  @override
  Widget build(BuildContext context) {
    // --- 1. USA UN CONSUMER PARA ESCUCHAR AL CLIENTEPROVIDER ---
    return Consumer<ClienteProvider>(
      builder: (context, clienteProvider, child) {
        String nombreCliente;

        // --- 2. COMPRUEBA SI EL PROVIDER ESTÁ CARGANDO ---
        if (clienteProvider.isLoading) {
          nombreCliente = 'Cargando...';
        } else {
          // --- 3. SI NO ESTÁ CARGANDO, BUSCA EL NOMBRE ---
          try {
            final cliente = clienteProvider.clientes.firstWhere(
              (c) => c.id == alquiler.clienteId,
            );
            nombreCliente = '${cliente.nombre} ${cliente.apellidos ?? ''}';
          } catch (e) {
            nombreCliente = 'Cliente (ID: ${alquiler.clienteId})';
          }
        }

        // --- 4. DEVUELVE LA TARJETA CON EL NOMBRE CORRECTO ---
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetallesAlquilerScreen(alquiler: alquiler),
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
                          nombreCliente, // <-- AHORA ES DINÁMICO
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alquiler.producto,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.stone700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // <-- CORREGIDO -->
                          '${DateFormat('dd/MM/yy').format(alquiler.fechaInicio)} - ${DateFormat('dd/MM/yy').format(alquiler.fechaDevolucion)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.stone600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _StatusTag(alquiler: alquiler), // <-- Pasa el objeto completo
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- (El _StatusTag no cambia) ---
class _StatusTag extends StatelessWidget {
  final Alquiler alquiler;
  const _StatusTag({required this.alquiler});

  @override
  Widget build(BuildContext context) {
    AlquilerEstado estadoCalculado = alquiler.estado;
    final now = DateTime.now();
    final fechaMora = alquiler.fechaDevolucion.add(const Duration(days: 2));

    if (alquiler.estado == AlquilerEstado.activo && now.isAfter(fechaMora)) {
      estadoCalculado = AlquilerEstado.atrasado;
    }

    String text;
    Color color;
    Color backgroundColor;

    switch (estadoCalculado) {
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
