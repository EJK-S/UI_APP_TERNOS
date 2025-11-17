// lib/screens/gestion_citas/detalles_cita_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_citas/editar_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/utils/whatsapp_service.dart';
import 'package:intl/intl.dart';

class DetallesCitaScreen extends StatelessWidget {
  final Cita cita;
  const DetallesCitaScreen({super.key, required this.cita});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los providers (sin escuchar, solo para los botones)
    final citaProvider = context.read<CitaProvider>();
    final clienteProvider = context.read<ClienteProvider>();

    // --- Búsqueda de Cliente (tu lógica ya era correcta) ---
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.id == cita.clienteId,
      );
    } catch (e) {
      cliente = null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Cita')),
      body: Consumer<CitaProvider>(
        builder: (context, provider, child) {
          // --- 2. AÑADIR LÓGICA DE CARGA ---
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- 3. CORREGIR BÚSQUEDA DE CITA ACTUALIZADA ---
          // (Usar 'id' (int) en lugar de 'prendaDetalleId' (String))
          final citaActualizada = provider.citas.firstWhere(
            (c) => c.id == cita.id, // <-- CORREGIDO
            orElse: () => cita,
          );

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _StatusTag(estado: citaActualizada.estado),
                ),
                const SizedBox(height: 16),

                // --- Tarjeta de Cliente (ya estaba bien) ---
                Text('Cliente', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildCard(
                  context,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        text: cliente != null
                            ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
                            : 'Cliente no encontrado',
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        text: cliente?.telefono ?? 'Sin teléfono',
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        text: cliente?.correo ?? 'Sin correo',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- 4. TARJETA DE DETALLES (CORREGIDA) ---
                Text(
                  'Detalles de la Cita',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildCard(
                  context,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.list_alt_outlined,
                        // De 'tipo.tipoTexto' a 'proposito.texto'
                        text: citaActualizada.proposito.texto, // <-- CORREGIDO
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        // De 'fecha' a 'fechaHora' formateada
                        text: DateFormat(
                          'dd/MM/yyyy',
                        ).format(citaActualizada.fechaHora), // <-- CORREGIDO
                      ),
                      _InfoRow(
                        icon: Icons.access_time_outlined,
                        // De 'hora' a 'fechaHora' formateada
                        text: DateFormat(
                          'hh:mm a',
                        ).format(citaActualizada.fechaHora), // <-- CORREGIDO
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- 5. TARJETA DE NOTAS (CORREGIDA) ---
                // (Reemplaza la antigua tarjeta "Prendas")
                Text('Notas', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildCard(
                  context,
                  child: _InfoRow(
                    icon: Icons.notes, // <-- CORREGIDO
                    text: citaActualizada.notas ?? 'Sin notas', // <-- CORREGIDO
                    // (Ya no hay 'prendaDetalleId')
                  ),
                ),
                const SizedBox(height: 32),

                // --- 6. BOTONES DE ACCIÓN (CORREGIDOS CON ASYNC/AWAIT) ---
                _buildActionButton(
                  label: 'Marcar como Completada',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () async {
                    // <-- ASYNC
                    await citaProvider.marcarComoCompletada(
                      citaActualizada,
                    ); // <-- AWAIT
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: 'Editar Cita',
                  color: AppColors.borderLight,
                  textColor: AppColors.stone800,
                  onPressed: () {
                    // (La navegación a EditarCitaScreen sigue igual)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditarCitaScreen(cita: citaActualizada),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: 'Cancelar Cita',
                  color: Colors.transparent,
                  textColor: Colors.red,
                  onPressed: () async {
                    // <-- ASYNC
                    await citaProvider.cancelarCita(
                      citaActualizada,
                    ); // <-- AWAIT
                    if (context.mounted) Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 12),
                _buildActionButton(
                  label: 'Recordatorio WhatsApp',
                  icon: Icons.chat_bubble_outline, // <-- Icono opcional
                  color: Colors.green.shade600,
                  textColor: Colors.white,
                  onPressed: () {
                    // 1. Validar que el cliente exista
                    if (cliente == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cliente no encontrado para enviar mensaje.',
                          ),
                        ),
                      );
                      return;
                    }

                    // 2. Crear el mensaje (RF-36)
                    final fecha = DateFormat(
                      'dd/MM/yyyy',
                    ).format(citaActualizada.fechaHora);
                    final hora = DateFormat(
                      'hh:mm a',
                    ).format(citaActualizada.fechaHora);
                    final mensaje =
                        'Hola ${cliente.nombre}! Te recordamos tu cita de ${citaActualizada.proposito.texto} para el día $fecha a las $hora. ¡Te esperamos!';

                    // 3. Llamar al servicio
                    WhatsappService().launchWhatsApp(
                      context: context,
                      telefono: cliente.telefono,
                      mensaje: mensaje,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets Auxiliares (Sin cambios) ---

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }

  Widget _InfoRow({
    required IconData icon,
    required String text,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.stone600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            // <-- Añadido Expanded para que las notas largas no se desborden
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.stone600,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    if (icon != null) {
      return ElevatedButton.icon(
        icon: Icon(icon, size: 18), // <-- AÑADIDO
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // ... (el resto de tu estilo)
        ),
      );
    }
    // Si no, usa el botón normal
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: color == Colors.transparent
              ? const BorderSide(color: Colors.red)
              : BorderSide.none,
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// (El _StatusTag ya era correcto y no necesita cambios)
class _StatusTag extends StatelessWidget {
  final CitaEstado estado;
  const _StatusTag({required this.estado});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    Color backgroundColor;

    switch (estado) {
      case CitaEstado.Pendiente:
        text = 'Pendiente';
        color = Colors.orange.shade800;
        backgroundColor = Colors.orange.shade100;
        break;
      case CitaEstado.Completada:
        text = 'Completada';
        color = Colors.green.shade800;
        backgroundColor = Colors.green.shade100;
        break;
      case CitaEstado.Cancelada:
        text = 'Cancelada';
        color = Colors.red.shade800;
        backgroundColor = Colors.red.shade100;
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
