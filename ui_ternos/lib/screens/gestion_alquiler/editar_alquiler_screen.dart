// lib/screens/gestion_alquiler/editar_alquiler_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:intl/intl.dart';

class EditarAlquilerScreen extends StatefulWidget {
  final Alquiler alquiler;
  const EditarAlquilerScreen({super.key, required this.alquiler});

  @override
  State<EditarAlquilerScreen> createState() => _EditarAlquilerScreenState();
}

class _EditarAlquilerScreenState extends State<EditarAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _clienteCtrl;
  late TextEditingController _trajeCtrl;
  late TextEditingController _fechaAlquilerCtrl;
  late TextEditingController _fechaDevolucionCtrl;
  late TextEditingController _montoTotalCtrl;
  late TextEditingController _garantiaCtrl;

  // Variables de estado
  late DateTime _selectedFechaInicio;
  late DateTime _selectedFechaDevolucion;
  late String _selectedPaymentMethod;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final alquiler = widget.alquiler;

    // --- Cargar Cliente ---
    String nombreCliente = 'Cliente no encontrado';
    try {
      final cliente = context.read<ClienteProvider>().clientes.firstWhere(
        (c) => c.id == alquiler.clienteId,
      );
      nombreCliente = '${cliente.nombre} ${cliente.apellidos ?? ''}';
    } catch (e) {
      nombreCliente = 'Cliente (ID: ${alquiler.clienteId})';
    }

    // --- Cargar Monto ---
    // (Quitamos "S/ " y espacios)
    final montoParseado = alquiler.montoTotal.replaceAll('S/ ', '').trim();

    // --- Inicializar Controladores ---
    _clienteCtrl = TextEditingController(text: nombreCliente);
    _trajeCtrl = TextEditingController(text: alquiler.producto);
    _fechaAlquilerCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(alquiler.fechaInicio),
    );
    _fechaDevolucionCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(alquiler.fechaDevolucion),
    );
    _montoTotalCtrl = TextEditingController(text: montoParseado);
    _garantiaCtrl = TextEditingController(text: '150.00'); // Fijo

    // --- Inicializar Estado ---
    _selectedFechaInicio = alquiler.fechaInicio;
    _selectedFechaDevolucion = alquiler.fechaDevolucion;
    _selectedPaymentMethod = alquiler.metodoPago;
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _trajeCtrl.dispose();
    _fechaAlquilerCtrl.dispose();
    _fechaDevolucionCtrl.dispose();
    _montoTotalCtrl.dispose();
    _garantiaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final alquilerActualizado = Alquiler(
        // --- Campos Originales (Fijos) ---
        codigo: widget.alquiler.codigo,
        clienteId: widget.alquiler.clienteId,
        producto: widget.alquiler.producto,
        prendaId: widget.alquiler.prendaId,
        garantia: 'S/ 150.00', // (RN-10)
        estado: widget.alquiler.estado, // El estado no se edita aquí
        // --- Campos Actualizados (Editables) ---
        fechaInicio: _selectedFechaInicio,
        fechaDevolucion: _selectedFechaDevolucion,
        metodoPago: _selectedPaymentMethod,
        montoTotal: 'S/ ${_montoTotalCtrl.text}',
      );

      await context.read<AlquilerProvider>().editarAlquiler(
        alquilerActualizado,
      );

      if (mounted) {
        Navigator.pop(context); // Cierra esta
        Navigator.pop(context); // Cierra la de detalles
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Alquiler')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- CAMPOS FIJOS (NO EDITABLES) ---
              _buildTextField(
                controller: _clienteCtrl,
                label: 'Cliente',
                isReadOnly: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _trajeCtrl,
                label: 'Traje',
                isReadOnly: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _garantiaCtrl,
                label: 'Monto de garantía (Fijo)',
                prefix: 'S/ ',
                isReadOnly: true,
              ),
              const SizedBox(height: 16),

              const Divider(),
              const SizedBox(height: 16),

              // --- CAMPOS EDITABLES ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDateField(
                      controller: _fechaAlquilerCtrl,
                      label: 'Fecha de alquiler',
                      onDateSelected: (date) {
                        setState(() => _selectedFechaInicio = date);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateField(
                      controller: _fechaDevolucionCtrl,
                      label: 'Fecha de devolución',
                      onDateSelected: (date) {
                        setState(() => _selectedFechaDevolucion = date);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _montoTotalCtrl,
                label: 'Monto Total',
                prefix: 'S/ ',
                hint: '150',
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 24),
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
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- (COPIAR LOS 4 HELPERS DE 'nuevo_alquiler_screen.dart') ---

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<DateTime> onDateSelected,
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
            hintText: 'dd/MM/yyyy',
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
              onDateSelected(picked);
              controller.text = DateFormat('dd/MM/yyyy').format(picked);
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
    TextInputType? keyboardType,
    bool isReadOnly = false, // <-- AÑADIDO
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
          readOnly: isReadOnly, // <-- AÑADIDO
          keyboardType:
              (icon != null || isReadOnly) // <-- MODIFICADO
              ? TextInputType.text
              : TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: (icon != null)
                ? Icon(icon, color: AppColors.stone600)
                : null,
            prefixText: prefix,
            hintText: hint,
            border: const OutlineInputBorder(),
            // --- AÑADIDO: Lógica visual para 'solo lectura' ---
            filled: isReadOnly,
            fillColor: isReadOnly
                ? Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight.withOpacity(0.5)
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Campo requerido';
            }
            // No validar como número si es readOnly
            if (icon == null && !isReadOnly && double.tryParse(value) == null) {
              return 'Monto inválido';
            }
            return null;
          },
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

// (Pega los 3 helpers aquí fuera de la clase si prefieres, 
// o dentro de la clase como en el código de ejemplo)