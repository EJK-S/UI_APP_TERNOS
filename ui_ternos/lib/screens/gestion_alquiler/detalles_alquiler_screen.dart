// lib/screens/detalles_alquiler_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:intl/intl.dart';

// --- 1. IMPORTA LA NUEVA PANTALLA ---
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/registrar_devolucion_screen.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';

class DetallesAlquilerScreen extends StatelessWidget {
  final Alquiler alquiler;

  const DetallesAlquilerScreen({super.key, required this.alquiler});

  @override
  Widget build(BuildContext context) {
    // --- 1. ELIMINAR LA LÓGICA DE BÚSQUEDA DE CLIENTE DE AQUÍ ---
    // (Las líneas 'final clienteProvider = ...' y 'Cliente? cliente; ...' se borran)

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Alquiler')),

      // --- 2. USAR Consumer2 PARA ESCUCHAR AMBOS PROVIDERS ---
      body: Consumer2<AlquilerProvider, ClienteProvider>(
        builder: (context, alquilerProvider, clienteProvider, child) {
          // --- 3. LÓGICA DE BÚSQUEDA DE CLIENTE (AHORA ES SEGURA) ---
          String nombreCliente;
          if (clienteProvider.isLoading) {
            nombreCliente = 'Cargando cliente...';
          } else {
            try {
              final cliente = clienteProvider.clientes.firstWhere(
                (c) => c.id == alquiler.clienteId, // Compara int con int
              );
              nombreCliente = '${cliente.nombre} ${cliente.apellidos ?? ''}';
            } catch (e) {
              nombreCliente = 'Cliente (ID: ${alquiler.clienteId})';
            }
          }
          // --- Fin de la lógica de cliente ---

          // --- Lógica del AlquilerProvider (que ya tenías) ---
          final alquilerActualizado = alquilerProvider.alquileres.firstWhere(
            (a) => a.codigo == alquiler.codigo,
            orElse: () => alquiler,
          );

          // --- 4. DEVOLVER LA UI ---
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      // --- 5. PASAR EL NOMBRE CORREGIDO ---
                      _buildDetailRow(context, 'Cliente', nombreCliente),
                      _buildDetailRow(
                        context,
                        'Traje',
                        alquilerActualizado.producto,
                      ),
                      _buildDetailRow(
                        context,
                        'Fechas',
                        // <-- CORREGIDO -->
                        '${DateFormat('dd/MM/yy').format(alquilerActualizado.fechaInicio)} - ${DateFormat('dd/MM/yy').format(alquilerActualizado.fechaDevolucion)}',
                      ),
                      _buildDetailRow(
                        context,
                        'Método de Pago',
                        alquilerActualizado.metodoPago,
                      ),
                      _buildDetailRow(
                        context,
                        'Monto Total',
                        alquilerActualizado.montoTotal,
                      ),
                      _buildDetailRow(
                        context,
                        'Garantía',
                        alquilerActualizado.garantia,
                      ),
                      _buildDetailRow(
                        context,
                        'Estado',
                        '',
                        widget: _StatusTag(estado: alquilerActualizado.estado),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Botones de Acción (SIN CAMBIOS) ---
                _buildActionButton(
                  label: 'Prolongar Alquiler (S/25)',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    _mostrarDialogoProlongar(
                      context,
                      alquilerProvider, // <-- Pasa el provider del builder
                      alquiler,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: 'Registrar Devolución',
                  color: AppColors.borderLight,
                  textColor: AppColors.stone800,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RegistrarDevolucionScreen(alquiler: alquiler),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // --- Historial de Acciones (SIN CAMBIOS) ---
                Text(
                  'Historial de Acciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimelineEntry(
                  context,
                  'Alquiler Creado',
                  '15/07/2024',
                  isFirst: true,
                ),
                _buildTimelineEntry(
                  context,
                  'Alquiler Extendido',
                  '18/07/2024',
                ),
                _buildTimelineEntry(
                  context,
                  'Devolución Registrada',
                  '22/07/2024',
                  isLast: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper para las filas de detalle (Cliente, Traje, etc.)
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Widget? widget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.stone700),
              ),
              widget ??
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
        ],
      ),
    );
  }

  // Helper para los botones de acción
  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Helper para la línea de tiempo
  Widget _buildTimelineEntry(
    BuildContext context,
    String title,
    String date, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // La línea de tiempo y el punto
        Column(
          children: [
            Container(
              height: isFirst ? 0 : 12,
              width: 2,
              color: AppColors.primary,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              height: isLast ? 0 : 24,
              width: 2,
              color: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(width: 12),
        // El texto
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                date,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoConfirmacion({
    required BuildContext context,
    required String titulo,
    required String contenido,
    required VoidCallback onConfirmar,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirmar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors
                    .primary, // Necesitas importar AppColors si no está
                foregroundColor: Colors.white,
              ),
              onPressed: onConfirmar,
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarDialogoProlongar(
    BuildContext context,
    AlquilerProvider provider,
    Alquiler alquiler,
  ) async {
    // 1. Mostrar el DatePicker
    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: alquiler.fechaDevolucion.isBefore(DateTime.now())
          ? DateTime.now()
          : alquiler.fechaDevolucion,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    // 2. Si el usuario seleccionó una fecha (y no canceló)
    if (nuevaFecha != null) {
      // Formatear el texto solo para el diálogo de confirmación
      String fechaFormateadaParaDialogo = DateFormat(
        'dd/MM/yyyy',
      ).format(nuevaFecha);

      // 3. Mostrar el diálogo de confirmación
      _mostrarDialogoConfirmacion(
        context: context,
        titulo: 'Prolongar Alquiler',
        contenido:
            '¿Prolongar este alquiler hasta el $fechaFormateadaParaDialogo por un costo adicional de S/ 25?',
        onConfirmar: () async {
          // <-- 4. HACER ASÍNCRONO

          // 5. Llamar al provider con el objeto DateTime, no el String
          await provider.prolongarAlquiler(
            alquiler: alquiler,
            nuevaFechaDevolucion: nuevaFecha, // <-- CORREGIDO
            montoAdicional: 25.0,
          );

          if (context.mounted) {
            // Cierra el diálogo de confirmación
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alquiler prolongado exitosamente.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      );
    }
  }
}

// Widget para la etiqueta de estado "Activo"
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
