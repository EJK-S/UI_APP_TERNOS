// lib/screens/citas_pendientes_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORTAMOS PROVIDER
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart'; // <-- 2. IMPORTAMOS EL CEREBRO
// Ya no necesitamos importar datos de prueba
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/screens/detalles_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class CitasPendientesScreen extends StatelessWidget {
  const CitasPendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Usamos un Consumer para "escuchar" los cambios del provider
    return Consumer<CitaProvider>(
      builder: (context, citaProvider, child) {
        // 5. Obtenemos la lista "viva" desde el provider
        final List<Cita> citas = citaProvider.citas
            .where((c) => c.estado == CitaEstado.Pendiente)
            .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Citas Pendientes')),
          body: SafeArea(
            child: citas.isEmpty
                ? const Center(child: Text('No hay citas pendientes.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      return _CitaCard(cita: cita);
                    },
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, Routes.nuevaCita);
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
          bottomNavigationBar: const MainBottomNav(currentIndex: 0),
        );
      },
    );
  }
}

// --- NINGÚN CAMBIO DE AQUÍ PARA ABAJO ---
// (El widget _CitaCard sigue exactamente igual)

class _CitaCard extends StatelessWidget {
  final Cita cita;
  const _CitaCard({required this.cita});

  @override
  Widget build(BuildContext context) {
    // --- 2. BUSCAMOS AL CLIENTE ---
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.dni == cita.clienteId,
      );
    } catch (e) {
      cliente = null; // No se encontró
    }
    final nombreCliente = cliente != null
        ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
        : 'Cliente (ID: ${cita.clienteId})';
    // --- FIN DE LA BÚSQUEDA ---

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesCitaScreen(cita: cita),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cita.tipoTexto,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      nombreCliente,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cita.prendasResumen,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    cita.fecha,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.stone600),
                  ),
                  Text(
                    cita.hora,
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
