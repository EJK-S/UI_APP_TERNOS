import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/screens/detalles_venta_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class GestionVentasScreen extends StatelessWidget {
  // --- 1. AÑADIMOS UN FILTRO OPCIONAL ---
  final String? filtroClienteNombre;

  const GestionVentasScreen({
    super.key,
    this.filtroClienteNombre, // El filtro es opcional
  });

  @override
  Widget build(BuildContext context) {
    // --- 2. DETERMINAMOS SI ESTAMOS EN MODO FILTRO ---
    final bool enModoFiltro = (filtroClienteNombre != null);

    return Consumer<VentaProvider>(
      builder: (context, ventaProvider, child) {
        // --- 3. LÓGICA DE FILTRADO ---
        List<Venta> ventas;
        if (enModoFiltro) {
          ventas = ventaProvider.ventas
              .where((v) => v.cliente == filtroClienteNombre)
              .toList();
        } else {
          ventas = ventaProvider.ventas;
        }

        return Scaffold(
          appBar: AppBar(
            // --- 4. TÍTULO DINÁMICO ---
            title: Text(
              enModoFiltro ? 'Ventas de $filtroClienteNombre' : 'Ventas',
            ),
          ),
          body: SafeArea(
            child: ventas.isEmpty
                ? Center(
                    child: Text(
                      enModoFiltro
                          ? 'Este cliente no tiene ventas registradas.'
                          : 'No hay ventas registradas.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: ventas.length,
                    itemBuilder: (context, index) {
                      final venta = ventas[index];
                      return _VentaCard(venta: venta);
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

          // --- 5. LÓGICA DE NAVEGACIÓN INFERIOR ---
          bottomNavigationBar: enModoFiltro
              ? null // No muestra la barra
              : const MainBottomNav(currentIndex: 0),
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
