// lib/screens/gestion_ventas_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/screens/detalles_venta_screen.dart';

class GestionVentasScreen extends StatelessWidget {
  const GestionVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al VentaProvider
    return Consumer<VentaProvider>(
      builder: (context, ventaProvider, child) {
        final List<Venta> ventas = ventaProvider.ventas;

        return Scaffold(
          appBar: AppBar(title: const Text('Ventas')),
          body: SafeArea(
            child: ListView.builder(
              // Cambiado a ListView.builder
              padding: const EdgeInsets.all(16.0),
              itemCount: ventas.length, // Usamos la longitud de la lista
              itemBuilder: (context, index) {
                final venta = ventas[index];
                return _VentaCard(venta: venta); // Usamos el widget de tarjeta
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/ventas/nueva');
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

// Widget interno para la tarjeta de Venta (Diseño de la Imagen 1)
class _VentaCard extends StatelessWidget {
  final Venta venta;
  const _VentaCard({required this.venta});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetallesVentaScreen(venta: venta),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Columna para Fecha, Producto y Cliente
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venta.fecha,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.stone600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      venta.producto, // <-- Campo del nuevo modelo
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cliente: ${venta.cliente}', // <-- Campo del nuevo modelo
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone700,
                      ),
                    ),
                  ],
                ),
              ),
              // Espacio
              const SizedBox(width: 16),
              // Precio
              Text(
                // Formateamos el double a S/ 0.00
                'S/ ${venta.total.toStringAsFixed(2)}', // <-- Campo del nuevo modelo
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
