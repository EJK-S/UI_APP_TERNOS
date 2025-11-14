// lib/screens/pagos/gestion_pagos_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:provider/provider.dart';
// Importar todos los providers necesarios
import 'package:proyecto_tienda_ternos/providers/pago_provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/detalles_alquiler_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_ventas/detalles_venta_screen.dart';
// (Ya no se importa mock_data)

class GestionPagosScreen extends StatelessWidget {
  const GestionPagosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Usar Consumer para leer el PagoProvider
    return Consumer<PagoProvider>(
      builder: (context, pagoProvider, child) {
        // 2. Añadir lógica de carga
        if (pagoProvider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pagos')),
            body: const Center(child: CircularProgressIndicator()),
            bottomNavigationBar: const MainBottomNav(currentIndex: 2),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Pagos')),
          body: SafeArea(
            // 3. Construir la lista desde el provider
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: pagoProvider.pagos.length, // <-- CORREGIDO
              itemBuilder: (context, index) {
                final pago = pagoProvider.pagos[index]; // <-- CORREGIDO
                return _PagoCard(pago: pago);
              },
            ),
          ),
          bottomNavigationBar: const MainBottomNav(currentIndex: 2),
        );
      },
    );
  }
}

// Widget para la tarjeta de Pago (CORREGIDO)
class _PagoCard extends StatelessWidget {
  final Pago pago;
  const _PagoCard({required this.pago});

  // --- 4. FUNCIÓN onTap ASÍNCRONA ---
  void _onTapCard(BuildContext context) {
    // Leer todos los providers (listen: false)
    final ventaProvider = context.read<VentaProvider>();
    final alquilerProvider = context.read<AlquilerProvider>();

    try {
      if (pago.tipo == TipoPago.Venta) {
        // Busca la Venta (manejando el 'isLoading')
        if (ventaProvider.isLoading) return; // No hacer nada si está cargando
        final venta = ventaProvider.ventas.firstWhere(
          (v) => v.codigo == pago.transaccionId,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallesVentaScreen(venta: venta),
          ),
        );
      } else if (pago.tipo == TipoPago.Alquiler) {
        // Busca el Alquiler (manejando el 'isLoading')
        if (alquilerProvider.isLoading)
          return; // No hacer nada si está cargando
        final alquiler = alquilerProvider.alquileres.firstWhere(
          (a) => a.codigo == pago.transaccionId,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallesAlquilerScreen(alquiler: alquiler),
          ),
        );
      }
    } catch (e) {
      // Maneja el error si la venta/alquiler no se encuentra
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: Transacción ${pago.transaccionId} no encontrada.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 5. BUSCAR EL NOMBRE DEL CLIENTE ---
    final clienteProvider = context.read<ClienteProvider>();
    String nombreCliente = 'Cliente no encontrado';
    if (!clienteProvider.isLoading) {
      try {
        nombreCliente = clienteProvider.clientes
            .firstWhere((c) => c.id == pago.clienteId)
            .nombre;
      } catch (e) {
        nombreCliente = 'Cliente (ID: ${pago.clienteId})';
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onTapCard(context), // <-- Llamar a la función corregida
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
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(pago.fecha), // <-- CORREGIDO
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.stone600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nombreCliente, // <-- CORREGIDO (mostrar nombre)
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pago.metodo, // <-- CORREGIDO (ya no usa el ícono)
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
