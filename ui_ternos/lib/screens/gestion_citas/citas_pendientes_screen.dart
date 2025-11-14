// lib/screens/citas_pendientes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_citas/detalles_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class CitasPendientesScreen extends StatelessWidget {
  const CitasPendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CitaProvider>(
      builder: (context, citaProvider, child) {
        // ============ Loading ============ //
        if (citaProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Citas Pendientes')),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: const MainBottomNav(currentIndex: 0),
          );
        }

        // ============ Filtrar solo pendientes ============ //
        final List<Cita> pendientes = citaProvider.citas
            .where((c) => c.estado == CitaEstado.Pendiente)
            .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Citas Pendientes')),
          body: SafeArea(
            child: pendientes.isEmpty
                ? const Center(
                    child: Text(
                      'No hay citas pendientes.',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendientes.length,
                    itemBuilder: (context, index) {
                      final cita = pendientes[index];
                      return _CitaCard(cita: cita);
                    },
                  ),
          ),

          // ============ Crear nueva cita ============ //
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, Routes.nuevaCita),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),

          bottomNavigationBar: const MainBottomNav(currentIndex: 0),
        );
      },
    );
  }
}

class _CitaCard extends StatelessWidget {
  final Cita cita;
  const _CitaCard({required this.cita});

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );

    // ============ Buscar el cliente asociado ============ //
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.id == cita.clienteId,
      );
    } catch (_) {
      cliente = null;
    }

    final nombreCliente = cliente != null
        ? '${cliente.nombres} ${cliente.apellidos ?? ''}'
        : 'Cliente (ID ${cita.clienteId})';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetallesCitaScreen(cita: cita)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Propósito
                    Text(
                      cita.proposito.texto,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Cliente
                    Text(
                      nombreCliente,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Notas
                    Text(
                      cita.notas ?? 'Sin notas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Fecha y hora
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(cita.fechaHora),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.stone600),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(cita.fechaHora),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
