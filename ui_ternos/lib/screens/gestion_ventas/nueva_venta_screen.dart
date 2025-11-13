// lib/screens/gestion_ventas/nueva_venta_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart'; // <-- Importado
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
  final _cantidadCtrl = TextEditingController(text: '1');
  final _precioCtrl = TextEditingController();

  // Variables de estado
  Cliente? _selectedCliente;
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape-Plin';
  double _total = 0.0;
  bool _isSaving = false; // <-- 1. AÑADIR ESTADO DE CARGA

  @override
  void initState() {
    super.initState();
    _cantidadCtrl.addListener(_calculateTotal);
    _precioCtrl.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final int cantidad = int.tryParse(_cantidadCtrl.text) ?? 0;
    final double precio = double.tryParse(_precioCtrl.text) ?? 0.0;
    setState(() {
      _total = cantidad * precio;
    });
  }

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

  // --- 2. FUNCIÓN '_submitForm' (CORREGIDA CON ASYNC/AWAIT) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // (Tu lógica de ID de cliente ya era correcta)
      // Asumimos que el cliente 'Mostrador' tiene el id 1 en la BD
      final int clienteId = _selectedCliente?.id ?? 1; // ID por defecto (int)

      final nuevaVenta = Venta(
        codigo: 'VEN-${DateTime.now().millisecondsSinceEpoch}',
        clienteId: clienteId,
        fecha:
            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        producto: _selectedTraje ?? 'Producto no seleccionado',
        cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
        precioUnitario: double.tryParse(_precioCtrl.text) ?? 0.0,
        metodoPago: _selectedPaymentMethod,
        total: _total,
      );

      // Llamada al provider (CON AWAIT)
      await context.read<VentaProvider>().agregarVenta(nuevaVenta);

      if (mounted) {
        Navigator.pop(context); // Regresamos
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

  @override
  Widget build(BuildContext context) {
    // --- 3. CONECTARSE AL PRENDA PROVIDER (CON 'watch') ---
    // Usamos 'watch' para que la pantalla se actualice si las prendas
    // estaban cargando y terminan de cargar.
    final prendaProvider = context.watch<PrendaProvider>();
    final List<String> productosDeInventario = prendaProvider.prendas
        .map((prenda) => prenda.nombre)
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Venta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // --- Campo de Cliente (Tu lógica ya era correcta) ---
                    Text(
                      'Cliente (opcional)',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                                  ? 'Seleccionar cliente (por defecto: Mostrador)'
                                  : '${_selectedCliente!.nombres} ${_selectedCliente!.apellidos ?? ''}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedCliente == null
                                    ? AppColors.stone600
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.search, color: AppColors.stone600),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- 4. DROPDOWN CORREGIDO ---
                    _buildDropdownField(
                      label: 'Tipo de traje',
                      hint: 'Seleccionar tipo',
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

                    // --- 5. BOTÓN DE GUARDAR CORREGIDO ---
                    ElevatedButton(
                      onPressed: _isSaving ? null : _submitForm,
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
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Registrar Venta'),
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

  // --- (Tus 3 widgets helper no necesitan cambios) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? prefix,
    bool isRequired = true,
    TextInputType? keyboardType,
    bool isReadOnly = false,
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
          keyboardType: keyboardType,
          readOnly: isReadOnly,
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
            fillColor: isReadOnly
                ? AppColors.borderLight.withOpacity(0.3)
                : null,
            filled: isReadOnly,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Requerido';
            }
            if (keyboardType == TextInputType.number &&
                (value != null && value.isNotEmpty) &&
                double.tryParse(value) == null) {
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
