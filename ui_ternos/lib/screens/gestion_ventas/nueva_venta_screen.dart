// lib/screens/gestion_ventas/nueva_venta_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/providers/pago_provider.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';

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
  bool _isSaving = false;

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

  // --- FUNCIÓN _submitForm (CORREGIDA) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que se seleccionó un traje
    if (_selectedTraje == null) {
      _showError('Por favor, seleccione un tipo de traje.');
      return;
    }

    final prendaProvider = context.read<PrendaProvider>();
    final double precio = double.tryParse(_precioCtrl.text) ?? 0.0;
    final double precioMinimoVenta = 100.0; // Define un mínimo (ej. S/ 100)

    if (precio < precioMinimoVenta) {
      _showError(
        'El precio (S/ ${precio.toStringAsFixed(2)}) es demasiado bajo. El mínimo es S/ $precioMinimoVenta.',
      );
      return; // Detiene la venta
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
      final int clienteId = _selectedCliente?.id ?? 1;
      final String codigoVenta = 'VEN-${DateTime.now().millisecondsSinceEpoch}';
      final DateTime fechaActual = DateTime.now();

      final nuevaVenta = Venta(
        codigo: codigoVenta,
        clienteId: clienteId,
        fecha: fechaActual,
        producto: _selectedTraje!,
        prendaId: prendaAActualizar.id, // <-- ¡CORRECCIÓN! CAMPO AÑADIDO
        cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
        precioUnitario: double.tryParse(_precioCtrl.text) ?? 0.0,
        metodoPago: _selectedPaymentMethod,
        total: _total,
      );

      final nuevoPago = Pago(
        id: 'PGO-${DateTime.now().millisecondsSinceEpoch}',
        fecha: fechaActual,
        clienteId: clienteId,
        monto: 'S/ ${_total.toStringAsFixed(2)}',
        tipo: TipoPago.Venta,
        metodo: _selectedPaymentMethod,
        transaccionId: codigoVenta,
      );

      final prendaVendida = Prenda(
        id: prendaAActualizar.id,
        nombre: prendaAActualizar.nombre,
        talla: prendaAActualizar.talla,
        categoria: prendaAActualizar.categoria,
        estado: PrendaEstado.Vendido,
        usos: prendaAActualizar.usos,
      );

      await context.read<VentaProvider>().agregarVenta(nuevaVenta);
      await context.read<PagoProvider>().agregarPago(nuevoPago);
      await prendaProvider.editarPrenda(prendaVendida);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Helper para mostrar errores
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (Tu método 'build' y tus 'helpers' ya eran correctos)
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
                    // Campo de Cliente
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

                    // Dropdown de Traje
                    _buildDropdownField(
                      label: 'Tipo de traje',
                      hint: 'Seleccionar tipo',
                      value: _selectedTraje,
                      items: productosDeInventario,
                      onChanged: (value) {
                        setState(() {
                          _selectedTraje = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cantidad y Precio
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

                    // Método de pago
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
                    // Total
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

                    // Botón de Registrar
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

  // --- (WIDGETS HELPER) ---

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
          validator: (value) =>
              (value == null && items.isNotEmpty) ? 'Campo requerido' : null,
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
