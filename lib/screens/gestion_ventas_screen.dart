// lib/screens/gestion_ventas_screen.dart
// (CÓDIGO NUEVO PARA QUE COINCIDA CON LA IMAGEN 4)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';

class GestionVentasScreen extends StatelessWidget {
  const GestionVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: mockVentas.length,
          itemBuilder: (context, index) {
            final venta = mockVentas[index];
            // Aquí creamos la tarjeta personalizada
            return _VentaCard(venta: venta);
          },
        ),
      ),
      // Tu botón FAB para navegar a /ventas/nueva
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/ventas/nueva');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const MainBottomNav(
        currentIndex: 0,
      ), // "Inicio" es el índice 0
    );
  }
}

// Widget interno para la tarjeta de Venta (Diseño de la Imagen 4)
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
          Navigator.pushNamed(context, '/ventas/detalle');
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
                      venta.producto,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cliente: ${venta.cliente}',
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
                venta.total,
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
