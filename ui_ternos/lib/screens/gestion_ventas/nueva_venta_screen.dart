// lib/screens/nueva_venta_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart'; // <-- 1. IMPORTA EL MODELO CLIENTE
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
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
  // --- 2. CAMBIAMOS EL CONTROLADOR DE TEXTO POR UN OBJETO CLIENTE ---
  Cliente? _selectedCliente;
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape-Plin';
  double _total = 0.0;

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

  // --- 3. FUNCIÓN PARA ABRIR EL SELECTOR DE CLIENTES ---
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

  // --- 4. FUNCIÓN '_submitForm' CORREGIDA ---
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Si no se seleccionó cliente, usamos 'Mostrador' (ID '00000000')
    final String clienteId =
        _selectedCliente?.dni ?? '00000000'; // ID por defecto

    final nuevaVenta = Venta(
      codigo: 'VEN-${DateTime.now().millisecondsSinceEpoch}',
      clienteId: clienteId, // <-- USA EL ID
      fecha:
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      producto: _selectedTraje ?? 'Producto no seleccionado',
      cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
      precioUnitario: double.tryParse(_precioCtrl.text) ?? 0.0,
      metodoPago: _selectedPaymentMethod,
      total: _total,
    );

    Provider.of<VentaProvider>(context, listen: false).agregarVenta(nuevaVenta);

    Navigator.pop(context); // Regresamos
  }

  @override
  Widget build(BuildContext context) {
    final prendaProvider = Provider.of<PrendaProvider>(context, listen: false);
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
                    // --- 5. CAMPO DE CLIENTE REEMPLAZADO ---
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
                                  : '${_selectedCliente!.nombre} ${_selectedCliente!.apellidos ?? ''}',
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

                    // --- FIN DEL REEMPLAZO ---
                    _buildDropdownField(
                      label: 'Tipo de traje',
                      hint: 'Seleccionar tipo',
                      value: _selectedTraje,
                      items: [
                        'Traje Clásico Negro',
                        'Esmoquin Moderno',
                        'Traje de Lino Beige',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTraje = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
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
    bool isReadOnly = false,
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
