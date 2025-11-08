// lib/screens/detalles_alquiler_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

// --- 1. IMPORTA LA NUEVA PANTALLA ---
import 'package:proyecto_tienda_ternos/screens/registrar_devolucion_screen.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';

class DetallesAlquilerScreen extends StatelessWidget {
  final Alquiler alquiler;

  const DetallesAlquilerScreen({super.key, required this.alquiler});

  @override
  Widget build(BuildContext context) {
    final alquilerProvider = Provider.of<AlquilerProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Alquiler')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            // --- Sección de Detalles ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _buildDetailRow(context, 'Cliente', alquiler.cliente),
                  _buildDetailRow(context, 'Traje', alquiler.producto),
                  _buildDetailRow(
                    context,
                    'Fechas',
                    '${alquiler.fechaInicio} - ${alquiler.fechaDevolucion}',
                  ),
                  _buildDetailRow(
                    context,
                    'Método de Pago',
                    alquiler.metodoPago,
                  ),
                  _buildDetailRow(context, 'Monto Total', alquiler.montoTotal),
                  _buildDetailRow(context, 'Garantía', alquiler.garantia),
                  _buildDetailRow(
                    context,
                    'Estado',
                    '',
                    widget: _StatusTag(estado: alquiler.estado),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Botones de Acción ---
            _buildActionButton(
              label: 'Prolongar Alquiler (S/25)',
              color: AppColors.primary,
              textColor: Colors.white,
              onPressed: () {
                // Llama a la nueva función del diálogo
                _mostrarDialogoProlongar(context, alquilerProvider, alquiler);
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Registrar Devolución',
              color: AppColors.borderLight,
              textColor: AppColors.stone800,

              // --- 2. ACTUALIZA EL 'onPressed' ---
              onPressed: () {
                // Navega a la nueva pantalla de registro
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Le pasa el alquiler actual a la nueva pantalla
                    builder: (context) =>
                        RegistrarDevolucionScreen(alquiler: alquiler),
                    // Opcional: hace que la pantalla aparezca desde abajo
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // --- Historial de Acciones ---
            Text(
              'Historial de Acciones',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTimelineEntry(
              context,
              'Alquiler Creado',
              '15/07/2024',
              isFirst: true,
            ),
            _buildTimelineEntry(context, 'Alquiler Extendido', '18/07/2024'),
            _buildTimelineEntry(
              context,
              'Devolución Registrada',
              '22/07/2024',
              isLast: true,
            ),
          ],
        ),
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
    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (nuevaFecha != null) {
      // Si el usuario seleccionó una fecha
      String fechaFormateada =
          "${nuevaFecha.day.toString().padLeft(2, '0')}/${nuevaFecha.month.toString().padLeft(2, '0')}/${nuevaFecha.year}";

      // Muestra el diálogo de confirmación
      _mostrarDialogoConfirmacion(
        context: context,
        titulo: 'Prolongar Alquiler',
        contenido:
            '¿Prolongar este alquiler hasta el $fechaFormateada por un costo adicional de S/ 25?',
        onConfirmar: () {
          // Llama al provider
          provider.prolongarAlquiler(alquiler, fechaFormateada, 25.0);

          // Cierra el diálogo de confirmación
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alquiler prolongado exitosamente.'),
              backgroundColor: Colors.green,
            ),
          );
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
