import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';

class RegistrarDevolucionScreen extends StatefulWidget {
  // Acepta el alquiler que se está devolviendo
  final Alquiler alquiler;

  const RegistrarDevolucionScreen({super.key, required this.alquiler});

  @override
  State<RegistrarDevolucionScreen> createState() =>
      _RegistrarDevolucionScreenState();
}

class _RegistrarDevolucionScreenState extends State<RegistrarDevolucionScreen> {
  // Variable de estado para los botones de "Estado del traje"
  String _estadoTraje = 'Completo'; // Valor por defecto
  final TextEditingController _observacionesCtrl = TextEditingController();

  @override
  void dispose() {
    _observacionesCtrl.dispose();
    super.dispose();
  }

  void _registrarDevolucion() {
    // Obtenemos la instancia del provider
    final alquilerProvider = Provider.of<AlquilerProvider>(
      context,
      listen: false,
    );

    // Llamamos al método del provider, pasándole el alquiler y las observaciones
    alquilerProvider.registrarDevolucion(
      widget.alquiler,
      _observacionesCtrl.text,
    );

    // Cerramos la pantalla
    Navigator.pop(context);
    // Y cerramos también la pantalla de "Detalle" para volver a la lista
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devolución de Terno')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Información del Alquiler (reemplaza el dropdown) ---
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
                    widget.alquiler.producto, // Muestra el producto
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Cliente: ${widget.alquiler.cliente}', // Muestra el cliente
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

            // --- Botones de Acción ---
            _buildActionButton(
              label: 'Registrar Devolución',
              color: AppColors.primary,
              textColor: Colors.white,
              onPressed: _registrarDevolucion,
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Devolver Garantía',
              color: AppColors.borderLight, // Gris claro
              textColor: AppColors.stone800, // Texto oscuro
              onPressed: () {
                // Lógica para devolver garantía
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Retener Garantía',
              color: Colors.red.shade100, // Rojo claro
              textColor: Colors.red.shade800, // Texto rojo oscuro
              onPressed: () {
                // Lógica para retener garantía
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para los botones de estado
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

  // Widget auxiliar para los botones de acción
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
