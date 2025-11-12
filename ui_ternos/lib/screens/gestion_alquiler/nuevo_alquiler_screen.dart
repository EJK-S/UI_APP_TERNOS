// lib/screens/gestion_alquileres/nuevo_alquiler_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
// --- 1. IMPORTAR PROVIDER DE PRENDA ---
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';

class NuevoAlquilerScreen extends StatefulWidget {
  const NuevoAlquilerScreen({super.key});

  @override
  State<NuevoAlquilerScreen> createState() => _NuevoAlquilerScreenState();
}

class _NuevoAlquilerScreenState extends State<NuevoAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController _fechaAlquilerCtrl = TextEditingController();
  final TextEditingController _fechaDevolucionCtrl = TextEditingController();
  final TextEditingController _garantiaCtrl = TextEditingController();
  final TextEditingController _montoTotalCtrl = TextEditingController();

  // Variables de estado
  Cliente? _selectedCliente;
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape - Plin';
  bool _isSaving = false; // <-- 2. AÑADIR ESTADO DE CARGA

  @override
  void dispose() {
    _fechaAlquilerCtrl.dispose();
    _fechaDevolucionCtrl.dispose();
    _garantiaCtrl.dispose();
    _montoTotalCtrl.dispose();
    super.dispose();
  }

  // --- 3. FUNCIÓN '_submitForm' (CORREGIDA CON ASYNC/AWAIT) ---
  Future<void> _submitForm() async {
    // Validar formulario y cliente
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione un cliente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nuevoAlquiler = Alquiler(
        codigo: 'ALQ-${DateTime.now().millisecondsSinceEpoch}',
        clienteId:
            _selectedCliente!.id!, // (Tu corrección '!.id!' ya era correcta)
        producto: _selectedTraje ?? 'Traje (No seleccionado)',
        fechaInicio: _fechaAlquilerCtrl.text,
        fechaDevolucion: _fechaDevolucionCtrl.text,
        estado: AlquilerEstado.activo,
        metodoPago: _selectedPaymentMethod,
        montoTotal: 'S/ ${_montoTotalCtrl.text}',
        garantia: 'S/ ${_garantiaCtrl.text}',
      );

      // Llamar al provider (CON AWAIT)
      await context.read<AlquilerProvider>().agregarAlquiler(nuevoAlquiler);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // (Tu función _abrirSelectorCliente ya es correcta)
  void _abrirSelectorCliente() async {
    final Cliente? clienteSeleccionado =
        await Navigator.pushNamed(context, Routes.seleccionarCliente)
            as Cliente?;
    if (clienteSeleccionado != null) {
      setState(() {
        _selectedCliente = clienteSeleccionado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 4. CONECTARSE AL PRENDA PROVIDER (CON 'watch') ---
    final prendaProvider = context.watch<PrendaProvider>();
    final List<String> productosDeInventario = prendaProvider.prendas
        .map((prenda) => prenda.nombre)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Alquiler')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Campo de Cliente (Tu lógica ya era correcta) ---
              Text(
                'Nombre del cliente *',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _abrirSelectorCliente,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCliente == null
                            ? 'Seleccionar cliente'
                            : '${_selectedCliente!.nombre} ${_selectedCliente!.apellidos ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedCliente == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.search, color: AppColors.stone600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- 5. DROPDOWN CORREGIDO (CONECTADO AL INVENTARIO) ---
              _buildDropdownField(
                label: 'Tipo de traje',
                hint: 'Seleccionar tipo de traje',
                value: _selectedTraje,
                items: productosDeInventario, // <-- USA LA LISTA DINÁMICA
                onChanged: (value) {
                  setState(() {
                    _selectedTraje = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // (Resto del formulario sin cambios)
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
              _buildTextField(
                controller: _montoTotalCtrl,
                label: 'Monto Total',
                prefix: 'S/ ',
                hint: '150',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _garantiaCtrl,
                label: 'Monto de garantía',
                prefix: 'S/ ',
                hint: '50',
              ),
              const SizedBox(height: 24),

              // --- 6. BOTÓN DE REGISTRAR (CORREGIDO) ---
              ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
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
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Registrar Alquiler'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- (Tus 4 widgets helper no necesitan cambios) ---
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // ... (Tu código es correcto)
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

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
  }) {
    // ... (Tu código es correcto)
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
            FocusScope.of(context).requestFocus(new FocusNode());
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? hint,
    IconData? icon,
  }) {
    // ... (Tu código es correcto)
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
            if (icon == null && double.tryParse(value) == null) {
              return 'Monto inválido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentButton(String method) {
    // ... (Tu código es correcto)
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
