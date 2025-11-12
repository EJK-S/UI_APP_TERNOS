// lib/screens/citas_pendientes_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_citas/detalles_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORTAR INTL PARA FECHAS

class CitasPendientesScreen extends StatelessWidget {
  const CitasPendientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CitaProvider>(
      builder: (context, citaProvider, child) {
        // --- 2. AÑADIR LÓGICA DE CARGA (¡IMPORTANTE!) ---
        if (citaProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Citas Pendientes')),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: const MainBottomNav(currentIndex: 0),
          );
        }
        // --- FIN DE LÓGICA DE CARGA ---

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
                      // El _CitaCard ya está corregido abajo
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

// --- WIDGET _CitaCard (COMPLETAMENTE CORREGIDO) ---

class _CitaCard extends StatelessWidget {
  final Cita cita;
  const _CitaCard({required this.cita});

  @override
  Widget build(BuildContext context) {
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );

    // --- Lógica de Clientes (Ya estaba correcta) ---
    Cliente? cliente;
    try {
      // (Esta línea ya estaba bien, compara 'id' (int) con 'clienteId' (int))
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.id == cita.clienteId,
      );
    } catch (e) {
      cliente = null;
    }
    final nombreCliente = cliente != null
        ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
        : 'Cliente (ID: ${cita.clienteId})';
    // --- Fin de Búsqueda ---

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
                    // --- 3. CAMPO CORREGIDO ---
                    Text(
                      cita
                          .proposito
                          .texto, // De 'tipoTexto' a 'proposito.texto'
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
                    // --- 4. CAMPO CORREGIDO ---
                    Text(
                      // De 'prendasResumen' a 'notas' (con fallback)
                      cita.notas ?? 'Sin notas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // --- 5. CAMPO CORREGIDO (FECHA) ---
                  Text(
                    // De 'fecha' a 'fechaHora' formateada
                    DateFormat('dd/MM/yyyy').format(cita.fechaHora),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.stone600),
                  ),
                  // --- 6. CAMPO CORREGIDO (HORA) ---
                  Text(
                    // De 'hora' a 'fechaHora' formateada
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
