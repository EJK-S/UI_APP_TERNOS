import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class DetallesVentaScreen extends StatelessWidget {
  const DetallesVentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            // --- Encabezado ---
            Text(
              'Venta #20240001',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Serie 001-000001\nFecha: 15 de mayo de 2024',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
            ),
            const SizedBox(height: 24),

            // --- Tarjeta de Cliente y Estado ---
            _buildClienteEstadoCard(context),
            const SizedBox(height: 24),

            // --- Tarjeta de Detalle de Ítems ---
            _buildItemsCard(context),
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
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: _buttonStyle(context),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: _buttonStyle(context),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Anular Venta'),
              style: _buttonStyle(context, isDestructive: true),
              onPressed: () {},
            ),
            const SizedBox(height: 24),

            // --- Notas / Observaciones ---
            Text(
              'Notas / Observaciones',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }

  // Helper para la tarjeta de Cliente y Estado
  Widget _buildClienteEstadoCard(BuildContext context) {
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
                'Sofia Ramirez',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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
                'Tarjeta',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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
              // Etiqueta de Estado
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
  }

  // Helper para la tarjeta de Ítems y Total
  Widget _buildItemsCard(BuildContext context) {
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
          _buildItemRow(context, 'Traje Clásico', '1 x S/ 350.00', 'S/ 350.00'),
          _buildItemRow(context, 'Camisa Blanca', '1 x S/ 150.00', 'S/ 150.00'),
          _buildItemRow(context, 'Corbata de Seda', '1 x S/ 50.00', 'S/ 50.00'),
          const Divider(height: 24),
          _buildSummaryRow(context, 'Subtotal', 'S/ 550.00'),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Descuentos', 'S/ 0.00'),
          const SizedBox(height: 12),
          _buildSummaryRow(context, 'Total', 'S/ 550.00', isTotal: true),
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
}
