import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
// 1. IMPORTA LA NUEVA PANTALLA DE EDICIÓN
import 'package:proyecto_tienda_ternos/screens/gestion_ventas/editar_venta_screen.dart';
// 2. IMPORTA EL MODELO VENTA (necesitarás pasarlo)
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart'; // <-- 1. IMPORTA PROVIDER
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:share_plus/share_plus.dart';

class DetallesVentaScreen extends StatelessWidget {
  final Venta venta;
  const DetallesVentaScreen({super.key, required this.venta});

  void _compartirVenta(Venta v, Cliente? c) {
    final String nombreCliente = c != null
        ? '${c.nombres} ${c.apellidos ?? ''}'
        : 'Mostrador';

    final String resumen =
        """
🧾 *Resumen de Venta* 🧾
--------------------
Código: ${v.codigo}
Fecha: ${v.fecha}
Cliente: $nombreCliente
Ítem: ${v.producto} (x${v.cantidad})
Método: ${v.metodoPago}

*Total Pagado:*
S/ ${v.total.toStringAsFixed(2)}
""";
    Share.share(resumen); // Llama a la función del paquete share_plus
  }

  @override
  Widget build(BuildContext context) {
    final ventaProvider = Provider.of<VentaProvider>(context, listen: false);
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.dni == venta.clienteId,
      );
    } catch (e) {
      cliente = null;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        // Usamos un Consumer para que los datos se actualicen si se editan
        child: Consumer<VentaProvider>(
          builder: (context, provider, child) {
            // Busca la versión más actualizada de la venta
            final ventaActualizada = provider.ventas.firstWhere(
              (v) => v.codigo == venta.codigo,
              orElse: () => venta, // Si no la encuentra, usa la original
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // --- Encabezado ---
                Text(
                  'Venta ${ventaActualizada.codigo}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Serie 001-000001\nFecha: ${ventaActualizada.fecha}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                ),
                const SizedBox(height: 24),

                // --- Tarjeta de Cliente y Estado ---
                _buildClienteEstadoCard(
                  context,
                  ventaActualizada,
                ), // <-- Pasa la Venta
                const SizedBox(height: 24),

                // --- Tarjeta de Detalle de Ítems ---
                _buildItemsCard(context, ventaActualizada), // <-- Pasa la Venta
                const SizedBox(height: 24),

                // --- Botones de Acción ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Descargar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Lógica de PDF (futuro)
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        style: _buttonStyle(context),
                        onPressed: () {
                          _compartirVenta(ventaActualizada, cliente);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                        style: _buttonStyle(context),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditarVentaScreen(venta: ventaActualizada),
                              fullscreenDialog: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Anular Venta'),
                  style: _buttonStyle(context, isDestructive: true),
                  onPressed: () {
                    _mostrarDialogoConfirmacion(
                      context: context,
                      titulo: 'Anular Venta',
                      contenido:
                          '¿Está seguro de que desea anular esta venta? Esta acción no se puede deshacer.',
                      onConfirmar: () {
                        ventaProvider.anularVenta(ventaActualizada);
                        Navigator.pop(context); // Cierra el diálogo
                        Navigator.pop(context); // Cierra la pantalla de detalle
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // --- Notas / Observaciones ---
                Text(
                  'Notas / Observaciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Añadir una nota...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Helper para la tarjeta de Cliente y Estado
  Widget _buildClienteEstadoCard(BuildContext context, Venta venta) {
    // --- 1. Envolver la lógica en un Consumer<ClienteProvider> ---
    return Consumer<ClienteProvider>(
      builder: (context, clienteProvider, child) {
        // --- 2. Lógica de búsqueda (ahora es segura) ---
        String nombreCliente;
        if (clienteProvider.isLoading) {
          nombreCliente = 'Cargando cliente...';
        } else {
          try {
            // Asumimos que el cliente "Mostrador" tiene id 1 (como en nueva_venta)
            if (venta.clienteId == 1) {
              nombreCliente = 'Mostrador';
            } else {
              final cliente = clienteProvider.clientes.firstWhere(
                (c) => c.id == venta.clienteId, // Compara int con int
              );
              nombreCliente = '${cliente.nombres} ${cliente.apellidos ?? ''}';
            }
          } catch (e) {
            nombreCliente = 'Cliente (ID: ${venta.clienteId})'; // Fallback
          }
        }
        // --- Fin de la lógica de búsqueda ---

        // --- 3. Devolver la UI de la tarjeta ---
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(context),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cliente',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                  ),
                  Text(
                    nombreCliente, // <-- USA EL NOMBRE DINÁMICO
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Método de pago',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                  ),
                  Text(
                    venta.metodoPago, // <-- USA DATOS REALES
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estado',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                  ),
                  // (La etiqueta de estado no cambia)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Completada',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper para la tarjeta de Ítems y Total
  Widget _buildItemsCard(BuildContext context, Venta venta) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle de Ítems',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // --- USA DATOS REALES ---
          _buildItemRow(
            context,
            venta.producto,
            '${venta.cantidad} x S/ ${venta.precioUnitario.toStringAsFixed(2)}',
            'S/ ${venta.total.toStringAsFixed(2)}',
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            context,
            'Subtotal',
            'S/ ${venta.total.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Descuentos', 'S/ 0.00'),
          const SizedBox(height: 12),
          _buildSummaryRow(
            context,
            'Total',
            'S/ ${venta.total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  // Helper para una fila de ítem
  Widget _buildItemRow(
    BuildContext context,
    String item,
    String qty,
    String total,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  qty,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                ),
              ],
            ),
          ),
          Text(
            total,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Helper para la fila de resumen (Subtotal, Total)
  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String amount, {
    bool isTotal = false,
  }) {
    final style = isTotal
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.stone700);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(amount, style: style),
      ],
    );
  }

  // Helper para el estilo de los botones
  ButtonStyle _buttonStyle(BuildContext context, {bool isDestructive = false}) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDestructive ? Colors.red : AppColors.primary,
      side: BorderSide(
        color: isDestructive ? Colors.red.shade200 : AppColors.borderLight,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Helper para la decoración de las tarjetas
  BoxDecoration _cardDecoration(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor),
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
      barrierDismissible: false, // El usuario debe presionar un botón
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(contenido),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: onConfirmar,
              child: const Text('Confirmar'), // Ejecuta la acción
            ),
          ],
        );
      },
    );
  }
}
