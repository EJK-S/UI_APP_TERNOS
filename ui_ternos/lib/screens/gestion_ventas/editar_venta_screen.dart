// lib/screens/gestion_ventas/editar_venta_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart'; // <-- 1. IMPORTAR PRENDA
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart'; // <-- 1. IMPORTAR PRENDA_PROVIDER
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes/seleccionar_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';

class EditarVentaScreen extends StatefulWidget {
  final Venta venta;
  const EditarVentaScreen({super.key, required this.venta});

  @override
  State<EditarVentaScreen> createState() => _EditarVentaScreenState();
}

class _EditarVentaScreenState extends State<EditarVentaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _clienteCtrl;
  late TextEditingController _cantidadCtrl;
  late TextEditingController _precioCtrl;

  // --- 2. ELIMINAR LISTA ESTÁTICA ---
  // final List<String> _tiposDeTraje = [ ... ]; // <-- ELIMINADO

  // Variables de estado
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape-Plin';
  double _total = 0.0;
  bool _isSaving = false; // <-- 3. AÑADIR ESTADO DE CARGA

  Cliente? _clienteDeEstaVenta;
  // (El _clienteSeleccionado no se usa en 'editar', se puede quitar)

  @override
  void initState() {
    super.initState();

    final venta = widget.venta;

    // --- 4. CORREGIR LÓGICA DE 'initState' ---
    try {
      // (Usamos context.read para estar seguros fuera de 'build')
      _clienteDeEstaVenta = context.read<ClienteProvider>().clientes.firstWhere(
        (c) => c.id == venta.clienteId, // <-- CORREGIDO: Compara int con int
      );
    } catch (e) {
      _clienteDeEstaVenta = null;
    }

    // Pre-rellenamos campos
    _clienteCtrl = TextEditingController(
      text: _clienteDeEstaVenta != null
          ? '${_clienteDeEstaVenta!.nombres} ${_clienteDeEstaVenta!.apellidos ?? ''}'
          : 'Cliente (ID: ${venta.clienteId})',
    );
    _cantidadCtrl = TextEditingController(text: venta.cantidad.toString());
    _precioCtrl = TextEditingController(text: venta.precioUnitario.toString());

    // Asignar el producto de la venta
    // (La validación de si existe se hará en el 'build' contra la lista del provider)
    _selectedTraje = venta.producto;
    _selectedPaymentMethod = venta.metodoPago;
    _total = venta.total;

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

  void _calculateTotal() {
    final int cantidad = int.tryParse(_cantidadCtrl.text) ?? 0;
    final double precio = double.tryParse(_precioCtrl.text) ?? 0.0;
    setState(() {
      _total = cantidad * precio;
    });
  }

  // --- 5. FUNCIÓN '_submitForm' (CORREGIDA CON ASYNC/AWAIT) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ventaActualizada = Venta(
        codigo: widget.venta.codigo,
        clienteId: widget.venta.clienteId, // Mantenemos el ID original
        fecha: widget.venta.fecha,
        producto: _selectedTraje ?? 'Producto no seleccionado',
        cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
        precioUnitario: double.tryParse(_precioCtrl.text) ?? 0.0,
        metodoPago: _selectedPaymentMethod,
        total: _total,
      );

      // Llamar al provider (CON AWAIT)
      await context.read<VentaProvider>().editarVenta(ventaActualizada);

      if (mounted) {
        Navigator.pop(context); // Regresamos al detalle
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

  // (La función _abrirSelectorCliente no se usa, la dejamos pero no se llama)
  void _abrirSelectorCliente() async {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    // --- 6. OBTENER LISTA DE PRODUCTOS DEL INVENTARIO ---
    final List<String> productosDeInventario = context
        .watch<PrendaProvider>()
        .prendas
        .map((prenda) => prenda.nombre)
        .toSet() // Eliminar duplicados
        .toList();

    // Validar si el traje seleccionado todavía existe en el inventario
    if (!productosDeInventario.contains(_selectedTraje)) {
      _selectedTraje = null; // Si no existe, mostrar el hint
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Venta')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Campo de Cliente (Solo lectura, ya estaba bien)
                    _buildTextField(
                      controller: _clienteCtrl,
                      label: 'Cliente',
                      hint: null,
                      icon: null,
                      isRequired: false,
                      isReadOnly: true,
                    ),
                    const SizedBox(height: 16),

                    // --- 7. DROPDOWN CONECTADO AL INVENTARIO ---
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

                    // (El resto del formulario no cambia)
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
                  // ... (shadow)
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

                    // --- 8. BOTÓN DE GUARDAR CORREGIDO ---
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
                          : const Text('Guardar Cambios'),
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
