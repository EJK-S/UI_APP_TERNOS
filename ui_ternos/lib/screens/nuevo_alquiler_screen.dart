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

//
// -----------------------------------------------------------------
// TODO COMIENZA DENTRO DE ESTA CLASE
// -----------------------------------------------------------------
//
class _NuevoAlquilerScreenState extends State<NuevoAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _fechaAlquilerCtrl = TextEditingController();
  final TextEditingController _fechaDevolucionCtrl = TextEditingController();
  final TextEditingController _garantiaCtrl = TextEditingController();
  final TextEditingController _montoTotalCtrl = TextEditingController();
  final TextEditingController _clienteCtrl =
      TextEditingController(); // Para el nombre

  // Variables de estado
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape - Plin'; // Valor inicial

  @override
  void dispose() {
    // Limpiamos los controladores
    _fechaAlquilerCtrl.dispose();
    _fechaDevolucionCtrl.dispose();
    _garantiaCtrl.dispose();
    _montoTotalCtrl.dispose();
    _clienteCtrl.dispose(); // Limpiamos el de cliente
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final nuevoAlquiler = Alquiler(
        codigo: 'ALQ-${DateTime.now().millisecondsSinceEpoch}',
        cliente: _clienteCtrl.text, // Usamos el texto del controlador
        producto: _selectedTraje ?? 'Traje (No seleccionado)',
        fechaInicio: _fechaAlquilerCtrl.text,
        fechaDevolucion: _fechaDevolucionCtrl.text,
        estado: AlquilerEstado.activo,
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

  // -----------------------------------------------------------------
  // MÉTODO build() (La interfaz)
  // -----------------------------------------------------------------
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
              // --- Nombre del cliente (TextField) ---
              _buildTextField(
                // Reemplazado
                controller: _clienteCtrl,
                label: 'Nombre del cliente',
                hint: 'Seleccionar / ingresar cliente',
                icon: Icons.person_outline, // Con ícono
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

              // --- Monto Total ---
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
  // -----------------------------------------------------------------
  // FIN DEL MÉTODO build()
  // -----------------------------------------------------------------

  //
  // --- FUNCIONES AUXILIARES (Helpers) ---
  // (Deben estar DENTRO de la clase _NuevoAlquilerScreenState
  // pero FUERA del método build())
  //

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
          readOnly: true,
          decoration: const InputDecoration(
            hintText: 'mm/dd/yyyy',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Requerido' : null,
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) {
              controller.text =
                  "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
      ],
    );
  }

  // Widget para los campos de texto (Cliente, Monto Total, Garantía)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? hint,
    IconData? icon, // Acepta un ícono opcional
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
          keyboardType: (icon != null)
              ? TextInputType.text
              : TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: (icon != null)
                ? Icon(icon, color: AppColors.stone600)
                : null,
            prefixText: prefix,
            hintText: hint,
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo requerido';
            }
            // Solo valida como número si NO tiene ícono
            if (icon == null && double.tryParse(value) == null) {
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

  // -----------------------------------------------------------------
  // ESTA ES LA ÚLTIMA LLAVE. CIERRA LA CLASE _NuevoAlquilerScreenState
  // -----------------------------------------------------------------
}
