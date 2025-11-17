// lib/screens/gestion_alquiler/nuevo_alquiler_screen.dart (CORREGIDO CON GARANTÍA FIJA VISIBLE)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_tienda_ternos/providers/pago_provider.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';

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
  final TextEditingController _montoTotalCtrl = TextEditingController();
  // --- 1. AÑADIR EL CONTROLADOR DE GARANTÍA DE VUELTA ---
  late TextEditingController _garantiaCtrl;

  // Variables de estado
  Cliente? _selectedCliente;
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape - Plin';
  bool _isSaving = false;
  DateTime? _selectedFechaInicio;
  DateTime? _selectedFechaDevolucion;

  // --- 2. AÑADIR initState PARA INICIALIZAR EL CONTROLADOR ---
  @override
  void initState() {
    super.initState();
    _garantiaCtrl = TextEditingController(text: '150.00'); // <-- Valor fijo
  }

  @override
  void dispose() {
    _fechaAlquilerCtrl.dispose();
    _fechaDevolucionCtrl.dispose();
    _montoTotalCtrl.dispose();
    _garantiaCtrl.dispose(); // <-- 3. AÑADIR A DISPOSE
    super.dispose();
  }

  // --- (Función _submitForm ya era correcta) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCliente == null ||
        _selectedFechaInicio == null ||
        _selectedFechaDevolucion == null ||
        _selectedTraje == null) {
      _showError('Por favor, complete todos los campos requeridos.');
      return;
    }
    if (_selectedCliente!.vetado == true) {
      _showError(
        'Error: El cliente seleccionado (${_selectedCliente!.nombre}) está vetado y no puede realizar transacciones.',
      );
      return;
    }

    final prendaProvider = context.read<PrendaProvider>();
    final double monto = double.tryParse(_montoTotalCtrl.text) ?? 0.0;
    final double montoMinimoAlquiler = 50.0; // Define un mínimo (ej. S/ 50)

    if (monto < montoMinimoAlquiler) {
      _showError(
        'El monto (S/ ${monto.toStringAsFixed(2)}) es demasiado bajo. El mínimo es S/ $montoMinimoAlquiler.',
      );
      return; // Detiene el alquiler
    }

    Prenda? prendaAActualizar;
    try {
      prendaAActualizar = prendaProvider.prendas.firstWhere(
        (p) =>
            p.nombre == _selectedTraje && p.estado == PrendaEstado.Disponible,
      );
    } catch (e) {
      prendaAActualizar = null;
    }

    if (prendaAActualizar == null) {
      _showError('¡No hay stock disponible para "$_selectedTraje"!');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String codigoAlquiler =
          'ALQ-${DateTime.now().millisecondsSinceEpoch}';

      final nuevoAlquiler = Alquiler(
        codigo: codigoAlquiler,
        clienteId: _selectedCliente!.id!,
        producto: _selectedTraje!,
        prendaId: prendaAActualizar.id,
        fechaInicio: _selectedFechaInicio!,
        fechaDevolucion: _selectedFechaDevolucion!,
        estado: AlquilerEstado.activo,
        metodoPago: _selectedPaymentMethod,
        montoTotal: 'S/ ${_montoTotalCtrl.text}',
        garantia: 'S/ 150.00', // <-- El valor fijo se sigue usando aquí
      );

      final nuevoPago = Pago(
        id: 'PGO-${DateTime.now().millisecondsSinceEpoch}',
        fecha: _selectedFechaInicio!,
        clienteId: _selectedCliente!.id!,
        monto: 'S/ ${_montoTotalCtrl.text}',
        tipo: TipoPago.Alquiler,
        metodo: _selectedPaymentMethod,
        transaccionId: codigoAlquiler,
      );

      final prendaAlquilada = Prenda(
        id: prendaAActualizar.id,
        nombre: prendaAActualizar.nombre,
        talla: prendaAActualizar.talla,
        categoria: prendaAActualizar.categoria,
        estado: PrendaEstado.Alquilado,
        usos: prendaAActualizar.usos + 1,
      );

      await context.read<AlquilerProvider>().agregarAlquiler(nuevoAlquiler);
      await context.read<PagoProvider>().agregarPago(nuevoPago);
      await prendaProvider.editarPrenda(prendaAlquilada);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _abrirSelectorCliente() async {
    final Cliente? clienteSeleccionado =
        await Navigator.pushNamed(context, Routes.seleccionarCliente)
            as Cliente?;
    if (clienteSeleccionado != null) {
      if (clienteSeleccionado.vetado == true) {
        _showError(
          'Este cliente está vetado y no puede realizar nuevos alquileres.',
        );
        return;
      }
      setState(() {
        _selectedCliente = clienteSeleccionado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              // (Selector de cliente - sin cambios)
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

              // (Dropdown de traje - sin cambios)
              _buildDropdownField(
                label: 'Tipo de traje',
                hint: 'Seleccionar tipo de traje',
                value: _selectedTraje,
                items: productosDeInventario,
                onChanged: (value) {
                  setState(() {
                    _selectedTraje = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // (Fila de Fechas - sin cambios)
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

              // (Método de pago - sin cambios)
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

              // (Monto Total - sin cambios)
              _buildTextField(
                controller: _montoTotalCtrl,
                label: 'Monto Total',
                prefix: 'S/ ',
                hint: '150',
              ),
              const SizedBox(height: 16),

              // --- 4. CAMPO DE GARANTÍA (AHORA FIJO Y NO EDITABLE) ---
              _buildTextField(
                controller:
                    _garantiaCtrl, // <-- Usa el controlador inicializado
                label: 'Monto de garantía (Fijo)',
                prefix: 'S/ ',
                isReadOnly: true, // <-- Lo hace no editable
              ),
              const SizedBox(height: 24),
              // --- FIN DE LA CORRECCIÓN ---

              // (Botón de registrar - sin cambios)
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

  // --- (WIDGETS HELPER) ---

  // (Helper _buildDateField - sin cambios)
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

  // (Helper _buildDropdownField - sin cambios)
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
          validator: (value) =>
              (value == null && items.isNotEmpty) ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  // --- 5. HELPER _buildTextField (ACTUALIZADO) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? hint,
    IconData? icon,
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

  // (Helper _buildPaymentButton - sin cambios)
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
