import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class GestionPagosScreen extends StatelessWidget {
  const GestionPagosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagos')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: mockPagos.length,
          itemBuilder: (context, index) {
            final pago = mockPagos[index];
            return _PagoCard(pago: pago);
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNav(
        currentIndex: 2,
      ), // Índice 2 para Pagos
    );
  }
}

// Widget para la tarjeta de Pago
class _PagoCard extends StatelessWidget {
  final Pago pago;
  const _PagoCard({required this.pago});

  String _getMetodoPagoIcon(MetodoPago metodo) {
    switch (metodo) {
      case MetodoPago.Tarjeta:
        return '💳';
      case MetodoPago.Yape:
        return '📱'; // Puedes usar un logo de Yape aquí
      case MetodoPago.Efectivo:
        return '💵';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Al tocar, te lleva a la pantalla de detalle de venta
          Navigator.pushNamed(context, '/ventas/detalle');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pago.fecha,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.stone600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pago.cliente,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getMetodoPagoIcon(pago.metodo)} ${pago.metodo.name} • ${pago.tipo.name}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                pago.monto,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
