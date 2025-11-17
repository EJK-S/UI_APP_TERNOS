// lib/screens/detalles_alquiler_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/editar_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/providers/settings_provider.dart';
import 'package:proyecto_tienda_ternos/utils/pdf_service.dart';
import 'package:proyecto_tienda_ternos/utils/whatsapp_service.dart';
import 'package:intl/intl.dart';

// --- 1. IMPORTA LA NUEVA PANTALLA ---
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/registrar_devolucion_screen.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';

class DetallesAlquilerScreen extends StatelessWidget {
  final Alquiler alquiler;

  const DetallesAlquilerScreen({super.key, required this.alquiler});

  double _calcularMora(Alquiler alquiler, String tipoCambioStr) {
    // Parámetros de negocio (de requerimientos.docx)
    final double tipoCambio = double.tryParse(tipoCambioStr) ?? 3.80;
    final double moraDiariaUSD = 10.0; // [cite: 1140, 1142]
    final double moraTopePEN = 150.0; // [cite: 1140, 1142]
    final int diasGracia =
        2; // (RF-05: "desde el tercer día", o sea 2 días de gracia)

    final now = DateTime.now();
    // La mora empieza DESPUÉS de los días de gracia
    final fechaLimite = alquiler.fechaDevolucion.add(
      Duration(days: diasGracia),
    );

    // No hay mora si ya fue devuelto (pendiente) o si aún está a tiempo
    if (alquiler.estado == AlquilerEstado.pendiente ||
        now.isBefore(fechaLimite)) {
      return 0.0;
    }

    // Calcula los días de mora (asegúrate de que sea solo el día, ignorando la hora)
    final diaDeHoy = DateTime(now.year, now.month, now.day);
    final diaLimite = DateTime(
      fechaLimite.year,
      fechaLimite.month,
      fechaLimite.day,
    );

    final int diasDeMora = diaDeHoy.difference(diaLimite).inDays;

    if (diasDeMora <= 0) return 0.0;

    // Calcular el total
    final double moraTotalUSD = diasDeMora * moraDiariaUSD;
    final double moraTotalPEN = moraTotalUSD * tipoCambio;

    // Aplicar el tope (RN-12)
    if (moraTotalPEN > moraTopePEN) {
      return moraTopePEN;
    }

    return moraTotalPEN;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Alquiler')),

      // Usamos Consumer3 para leer Alquiler, Cliente y Settings
      body: Consumer3<AlquilerProvider, ClienteProvider, SettingsProvider>(
        builder: (context, alquilerProvider, clienteProvider, settingsProvider, child) {
          // --- 1. CORRECCIÓN DE ÁMBITO DE VARIABLE ---
          // Declaramos 'cliente' aquí para que sea accesible en todo el builder
          Cliente? cliente;
          String nombreCliente;

          if (clienteProvider.isLoading) {
            nombreCliente = 'Cargando cliente...';
            cliente = null; // Asignamos null mientras carga
          } else {
            try {
              // Asignamos a la variable 'cliente' (sin 'final')
              cliente = clienteProvider.clientes.firstWhere(
                (c) => c.id == alquiler.clienteId,
              );
              nombreCliente = '${cliente.nombre} ${cliente.apellidos ?? ''}';
            } catch (e) {
              cliente = null; // Asignamos null si falla
              nombreCliente = 'Cliente (ID: ${alquiler.clienteId})';
            }
          }
          // --- FIN DE LA CORRECCIÓN ---

          final alquilerActualizado = alquilerProvider.alquileres.firstWhere(
            (a) => a.codigo == alquiler.codigo,
            orElse: () => alquiler,
          );

          final moraCalculada = _calcularMora(
            alquilerActualizado,
            settingsProvider.tipoCambio,
          );
          final bool estaEnMora = moraCalculada > 0;

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // --- Tarjeta de Detalles ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(context, 'Cliente', nombreCliente),
                      _buildDetailRow(
                        context,
                        'Traje',
                        alquilerActualizado.producto,
                      ),
                      _buildDetailRow(
                        context,
                        'Fechas',
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
                        widget: _StatusTag(alquiler: alquilerActualizado),
                      ),
                      if (estaEnMora)
                        _buildDetailRow(
                          context,
                          'Mora Acumulada',
                          'S/ ${moraCalculada.toStringAsFixed(2)}',
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar PDF (Contrato)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    // --- ¡CONECTADO! ---
                    // (Recuerda que 'alquilerActualizado' y 'cliente' vienen
                    // del Consumer3 que está más arriba en tu 'build')
                    PdfGenerationService().generateAlquilerPdf(
                      alquilerActualizado,
                      cliente,
                    );
                    // --- FIN DE LA CONEXIÓN ---
                  },
                ),

                // --- Lógica de Botones ---
                const SizedBox(height: 24),
                if (alquilerActualizado.estado == AlquilerEstado.pendiente)
                  // Si está finalizado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.backgroundDark
                          : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Este alquiler ya fue devuelto y está finalizado.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                else
                  // Si NO está finalizado
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Botón Prolongar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _mostrarDialogoProlongar(
                            context,
                            alquilerProvider,
                            settingsProvider,
                            alquiler,
                          );
                        },
                        child: const Text('Prolongar Alquiler (S/25)'),
                      ),
                      const SizedBox(height: 12),

                      // Fila de Botones Secundarios
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: _buttonStyle(context),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditarAlquilerScreen(
                                      alquiler: alquilerActualizado,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Editar Alquiler',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: _buttonStyle(context),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RegistrarDevolucionScreen(
                                          alquiler: alquiler,
                                        ),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                              child: const Text(
                                'Registrar Devolución',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Botón de WhatsApp (¡Ahora 'cliente' es accesible!)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text(
                          'Recordatorio de Devolución',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Ahora 'cliente' se puede leer aquí
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

                          final fecha = DateFormat(
                            'dd/MM/yyyy',
                          ).format(alquilerActualizado.fechaDevolucion);
                          final mensaje =
                              'Hola ${cliente.nombre}! Te recordamos que la fecha de devolución de tu ${alquilerActualizado.producto} (Cód: ${alquilerActualizado.codigo}) es el $fecha. ¡Gracias!';

                          WhatsappService().launchWhatsApp(
                            context: context,
                            telefono: cliente.telefono, // <-- Ahora funciona
                            mensaje: mensaje,
                          );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Historial de Acciones (estático)
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
                  DateFormat(
                    'dd/MM/yyyy',
                  ).format(alquilerActualizado.fechaInicio),
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

  ButtonStyle _buttonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.borderDark
            : AppColors.borderLight,
      ),
      foregroundColor: Theme.of(context).colorScheme.onSurface,
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
    SettingsProvider settingsProvider, // <-- 3er ARGUMENTO
    Alquiler alquiler, // <-- 4to ARGUMENTO
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

    if (nuevaFecha != null) {
      String fechaFormateadaParaDialogo = DateFormat(
        'dd/MM/yyyy',
      ).format(nuevaFecha);

      // 2. Calcular el monto real (RN-14)
      final double tipoCambio =
          double.tryParse(settingsProvider.tipoCambio) ?? 3.80;
      final double prolongacionUSD = 25.0; // $25 USD
      final double montoAdicionalPEN = prolongacionUSD * tipoCambio;
      // 2. Llama al provider
      await provider.prolongarAlquiler(
        alquiler: alquiler,
        nuevaFechaDevolucion: nuevaFecha,
        montoAdicional: montoAdicionalPEN, // <-- PASA EL VALOR CALCULADO
      );

      // 3. Mostrar el diálogo de confirmación
      // (Asegúrate de que la función _mostrarDialogoConfirmacion [cite: 450-452] exista en tu archivo)
      _mostrarDialogoConfirmacion(
        context: context,
        titulo: 'Prolongar Alquiler',
        contenido:
            '¿Prolongar este alquiler hasta el $fechaFormateadaParaDialogo por un costo adicional de S/ ${montoAdicionalPEN.toStringAsFixed(2)}?',

        onConfirmar: () async {
          // 4. Llama al provider con el monto calculado
          await provider.prolongarAlquiler(
            alquiler: alquiler,
            nuevaFechaDevolucion: nuevaFecha,
            montoAdicional: montoAdicionalPEN, // <-- Pasa el valor real
          );

          if (context.mounted) {
            Navigator.pop(context); // Cierra el diálogo de confirmación
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
  // --- CAMBIADO: Ahora acepta el alquiler completo ---
  final Alquiler alquiler;
  const _StatusTag({required this.alquiler});

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE CÁLCULO AÑADIDA ---
    AlquilerEstado estadoCalculado = alquiler.estado;
    final now = DateTime.now();
    // (Añadimos un chequeo de 2 días de gracia como dice RF-05)
    final fechaMora = alquiler.fechaDevolucion.add(const Duration(days: 2));

    if (alquiler.estado == AlquilerEstado.activo && now.isAfter(fechaMora)) {
      estadoCalculado = AlquilerEstado.atrasado;
    }
    // --- FIN DE LÓGICA ---

    String text;
    Color color;
    Color backgroundColor;

    // El switch ahora usa el estado 'calculado'
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

ButtonStyle _buttonStyle(BuildContext context) {
  return OutlinedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: BorderSide(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.borderDark
          : AppColors.borderLight,
    ),
    foregroundColor: Theme.of(context).colorScheme.onSurface,
  );
}
