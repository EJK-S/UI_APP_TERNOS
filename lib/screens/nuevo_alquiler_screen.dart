// lib/screens/nuevo_alquiler_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class NuevoAlquilerScreen extends StatefulWidget {
  const NuevoAlquilerScreen({super.key});

  @override
  State<NuevoAlquilerScreen> createState() => _NuevoAlquilerScreenState();
}

class _NuevoAlquilerScreenState extends State<NuevoAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController _fechaAlquilerCtrl = TextEditingController();
  final TextEditingController _fechaDevolucionCtrl = TextEditingController();
  final TextEditingController _garantiaCtrl = TextEditingController();

  // --- CAMBIO: AÑADIDO CONTROLADOR PARA MONTO TOTAL ---
  final TextEditingController _montoTotalCtrl = TextEditingController();

  // Variables de estado
  String? _selectedCliente;
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape - Plin';

  @override
  void dispose() {
    _fechaAlquilerCtrl.dispose();
    _fechaDevolucionCtrl.dispose();
    _garantiaCtrl.dispose();
    _montoTotalCtrl.dispose(); // <-- CAMBIO: Limpiar
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // --- CAMBIO: CONSTRUCTOR CORREGIDO CON TODOS LOS PARÁMETROS ---
      final nuevoAlquiler = Alquiler(
        codigo: 'ALQ-${DateTime.now().millisecondsSinceEpoch}',
        cliente: _selectedCliente ?? 'Cliente (No seleccionado)',
        producto: _selectedTraje ?? 'Traje (No seleccionado)',
        fechaInicio: _fechaAlquilerCtrl.text,
        fechaDevolucion: _fechaDevolucionCtrl.text,
        estado: AlquilerEstado.activo,

        // --- Datos requeridos añadidos ---
        metodoPago: _selectedPaymentMethod,
        montoTotal: 'S/ ${_montoTotalCtrl.text}',
        garantia: 'S/ ${_garantiaCtrl.text}',
      );

      Provider.of<AlquilerProvider>(
        context,
        listen: false,
      ).agregarAlquiler(nuevoAlquiler);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Alquiler')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Nombre del cliente (Dropdown) ---
              _buildDropdownField(
                label: 'Nombre del cliente',
                hint: 'Seleccionar cliente',
                value: _selectedCliente,
                items: [
                  'Juan Pérez',
                  'María López',
                  'Carlos Sánchez',
                  'Miguel Rodríguez',
                ], // Datos de ejemplo
                onChanged: (value) {
                  setState(() {
                    _selectedCliente = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Tipo de traje (Dropdown) ---
              _buildDropdownField(
                label: 'Tipo de traje',
                hint: 'Seleccionar tipo de traje',
                value: _selectedTraje,
                items: [
                  'Esmoquin Clásico',
                  'Traje de Gala',
                  'Frac Negro',
                ], // Datos de ejemplo
                onChanged: (value) {
                  setState(() {
                    _selectedTraje = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Fila de Fechas ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: _fechaAlquilerCtrl,
                      label: 'Fecha de alquiler',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      controller: _fechaDevolucionCtrl,
                      label: 'Fecha de devolución',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Método de pago (Botones) ---
              Text(
                'Método de pago',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentButton('Efectivo'),
                  _buildPaymentButton('Yape - Plin'),
                  _buildPaymentButton('Tarjeta'),
                ],
              ),
              const SizedBox(height: 16),

              // --- CAMBIO: AÑADIDO CAMPO "MONTO TOTAL" ---
              _buildTextField(
                controller: _montoTotalCtrl,
                label: 'Monto Total',
                prefix: 'S/ ',
                hint: '150',
              ),
              const SizedBox(height: 16),

              // --- Monto de garantía (TextField) ---
              _buildTextField(
                controller: _garantiaCtrl,
                label: 'Monto de garantía',
                prefix: 'S/ ',
                hint: '50',
              ),
              const SizedBox(height: 24),

              // --- Botón de Registrar ---
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Registrar Alquiler'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES PARA CONSTRUIR EL FORMULARIO ---

  // Widget para los campos de Dropdown
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
          value: value,
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

  // Widget para los campos de Fecha
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
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
          readOnly: true, // Importante para que no se abra el teclado
          decoration: const InputDecoration(
            hintText: 'mm/dd/yyyy',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Requerido' : null,
          onTap: () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              // Formateamos la fecha (puedes cambiar el formato)
              controller.text =
                  "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
      ],
    );
  }

  // Widget para los campos de texto (Monto Total, Garantía)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? hint,
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: prefix,
            hintText: hint,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo requerido';
            }
            if (double.tryParse(value) == null) {
              return 'Monto inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Widget para los botones de Método de Pago
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
