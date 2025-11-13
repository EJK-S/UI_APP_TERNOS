import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
// --- 1. IMPORTA LO QUE NECESITAMOS ---
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
// ---
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class RegistrarDevolucionScreen extends StatefulWidget {
  final Alquiler alquiler;

  const RegistrarDevolucionScreen({super.key, required this.alquiler});

  @override
  State<RegistrarDevolucionScreen> createState() =>
      _RegistrarDevolucionScreenState();
}

class _RegistrarDevolucionScreenState extends State<RegistrarDevolucionScreen> {
  String _estadoTraje = 'Completo';
  final TextEditingController _observacionesCtrl = TextEditingController();

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  // (Esta función no necesita cambios, ya está correcta)
  void _registrarDevolucion(
    AlquilerProvider alquilerProvider,
    bool garantiaRetenida,
  ) {
    alquilerProvider.registrarDevolucion(
      widget.alquiler,
      _observacionesCtrl.text,
      garantiaRetenida,
    );
    Navigator.pop(context); // Cierra este
    Navigator.pop(context); // Cierra el detalle
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los providers
    final alquilerProvider = Provider.of<AlquilerProvider>(
      context,
      listen: false,
    );
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );

    // --- 2. BUSCAMOS AL CLIENTE USANDO EL ID ---
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.dni == widget.alquiler.clienteId,
      );
    } catch (e) {
      cliente = null; // No se encontró
    }
    final String nombreCliente = cliente != null
        ? '${cliente.nombres} ${cliente.apellidos ?? ''}'
        : 'Cliente (ID: ${widget.alquiler.clienteId})';
    // --- FIN DE LA BÚSQUEDA ---

    return Scaffold(
      appBar: AppBar(title: const Text('Devolución de Terno')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- 3. INFORMACIÓN DEL ALQUILER (CORREGIDA) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registrando devolución para:',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.stone600),
                  ),
                  Text(
                    widget.alquiler.producto,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cliente: $nombreCliente', // <-- USA EL NOMBRE ENCONTRADO
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.stone700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Estado del traje ---
            Text(
              'Estado del traje',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildEstadoButton('Completo'),
                _buildEstadoButton('Incompleto'),
                _buildEstadoButton('Dañado'),
              ],
            ),
            const SizedBox(height: 24),

            // --- Observaciones ---
            Text(
              'Observaciones',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _observacionesCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Añadir observaciones...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // --- Botones de Acción (Corregidos) ---
            _buildActionButton(
              label: 'Finalizar y Devolver Garantía',
              color: AppColors.primary,
              textColor: Colors.white,
              onPressed: () {
                _registrarDevolucion(
                  alquilerProvider,
                  false,
                ); // false = no retenida
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Finalizar y Retener Garantía',
              color: Colors.red.shade100,
              textColor: Colors.red.shade800,
              onPressed: () {
                _registrarDevolucion(
                  alquilerProvider,
                  true,
                ); // true = sí retenida
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- (Helpers _buildEstadoButton y _buildActionButton no cambian) ---

  Widget _buildEstadoButton(String label) {
    final bool isSelected = _estadoTraje == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _estadoTraje = label;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primary : Colors.white,
            foregroundColor: isSelected ? Colors.white : AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

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
}
