// lib/screens/nueva_venta_screen.dart (NUEVO CÓDIGO COMPLETO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _clienteCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '1');
  final _precioCtrl = TextEditingController();

  // Variables de estado
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape-Plin';
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    // Añadimos "listeners" para auto-calcular el total
    _cantidadCtrl.addListener(_calculateTotal);
    _precioCtrl.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  // --- Función para calcular el total ---
  void _calculateTotal() {
    final int cantidad = int.tryParse(_cantidadCtrl.text) ?? 0;
    final double precio = double.tryParse(_precioCtrl.text) ?? 0.0;
    setState(() {
      _total = cantidad * precio;
    });
  }

  // --- Función para enviar el formulario ---
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return; // Formulario no válido
    }

    final nuevaVenta = Venta(
      codigo: 'VEN-${DateTime.now().millisecondsSinceEpoch}',
      cliente: _clienteCtrl.text.isEmpty ? 'Mostrador' : _clienteCtrl.text,
      fecha:
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      producto: _selectedTraje ?? 'Producto no seleccionado',
      cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
      precioUnitario: double.tryParse(_precioCtrl.text) ?? 0.0,
      metodoPago: _selectedPaymentMethod,
      total: _total,
    );

    // Hablamos con el Provider
    Provider.of<VentaProvider>(context, listen: false).agregarVenta(nuevaVenta);

    Navigator.pop(context); // Regresamos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Venta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- FORMULARIO (expandible) ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // --- Cliente ---
                    _buildTextField(
                      controller: _clienteCtrl,
                      label: 'Cliente (opcional)',
                      hint: 'Seleccionar cliente',
                      icon: Icons.person_outline,
                      isRequired: false, // Cliente es opcional
                    ),
                    const SizedBox(height: 16),

                    // --- Tipo de traje ---
                    _buildDropdownField(
                      label: 'Tipo de traje',
                      hint: 'Seleccionar tipo',
                      value: _selectedTraje,
                      items: [
                        'Traje Clásico Negro',
                        'Esmoquin Moderno',
                        'Traje de Lino Beige',
                      ], // Datos de ejemplo
                      onChanged: (value) {
                        setState(() {
                          _selectedTraje = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Fila de Cantidad y Precio ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _cantidadCtrl,
                            label: 'Cantidad',
                            hint: '1',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _precioCtrl,
                            label: 'Precio unitario',
                            hint: '0.00',
                            prefix: 'S/ ',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- Método de pago ---
                    Text(
                      'Método de pago',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPaymentButton('Efectivo'),
                        _buildPaymentButton('Yape-Plin'),
                        _buildPaymentButton('Tarjeta'),
                      ],
                    ),
                  ],
                ),
              ),

              // --- SECCIÓN FIJA INFERIOR (Total y Botón) ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- Total ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'S/ ${_total.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- Botón de Registrar ---
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Registrar Venta'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (Helpers) ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? prefix,
    bool isRequired = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.stone600)
                : null,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Requerido';
            }
            if (keyboardType == TextInputType.number &&
                double.tryParse(value!) == null) {
              return 'Número inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(hint),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String method) {
    final bool isSelected = _selectedPaymentMethod == method;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedPaymentMethod = method;
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
            method,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
