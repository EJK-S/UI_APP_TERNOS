import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
// --- Importa lo necesario para buscar al cliente ---
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
// ---
import 'package:proyecto_tienda_ternos/screens/detalles_venta_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class GestionVentasScreen extends StatelessWidget {
  final String? filtroClienteNombre;

  const GestionVentasScreen({super.key, this.filtroClienteNombre});

  @override
  Widget build(BuildContext context) {
    final bool enModoFiltro = (filtroClienteNombre != null);

    return Consumer<VentaProvider>(
      builder: (context, ventaProvider, child) {
        List<Venta> ventas;
        if (enModoFiltro) {
          final clienteProvider = Provider.of<ClienteProvider>(
            context,
            listen: false,
          );
          String clienteId = '';
          try {
            final cliente = clienteProvider.clientes.firstWhere(
              (c) => '${c.nombre} ${c.apellidos ?? ''}' == filtroClienteNombre,
            );
            clienteId = cliente.dni;
          } catch (e) {
            // Cliente no encontrado
          }

          ventas = ventaProvider.ventas
              .where((v) => v.clienteId == clienteId) // Filtra por ID
              .toList();
        } else {
          ventas = ventaProvider.ventas;
        }

        return Scaffold(
          appBar: AppBar(
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
          bottomNavigationBar: enModoFiltro
              ? null
              : const MainBottomNav(currentIndex: 0),
        );
      },
    );
  }
}

// --- WIDGET _VentaCard CORREGIDO (Buscará el nombre del cliente) ---
class _VentaCard extends StatelessWidget {
  final Venta venta;
  const _VentaCard({required this.venta});

  @override
  Widget build(BuildContext context) {
    // --- BÚSQUEDA DEL CLIENTE ---
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
      cliente = null; // No se encontró
    }
    // Si no es un cliente real (ID '00000000'), asumimos que es 'Mostrador'
    final String nombreCliente = venta.clienteId == '00000000'
        ? 'Mostrador'
        : (cliente != null
              ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
              : 'Cliente no encontrado');
    // --- FIN DE LA BÚSQUEDA ---

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
                      'Cliente: $nombreCliente', // <-- USAMOS EL NOMBRE ENCONTRADO
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.stone700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'S/ ${venta.total.toStringAsFixed(2)}',
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
