import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/screens/seleccionar_cliente_screen.dart';
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

  final List<String> _tiposDeTraje = [
    'Traje Clásico Negro',
    'Esmoquin Moderno',
    'Traje de Lino Beige',
    'Frac de Gala',
    'Traje a Rayas',
    'Traje de Lino Marrón', // <-- El que causaba el crash
  ];

  // Variables de estado
  String? _selectedTraje;
  String _selectedPaymentMethod = 'Yape-Plin';
  double _total = 0.0;

  // Guardaremos el cliente para no tener que buscarlo de nuevo
  Cliente? _clienteDeEstaVenta;
  Cliente? _clienteSeleccionado;

  @override
  void initState() {
    super.initState();

    // --- 3. LÓGICA DE 'initState' CORREGIDA ---
    final venta = widget.venta;
    // Buscamos al cliente en el ClienteProvider
    try {
      _clienteDeEstaVenta = Provider.of<ClienteProvider>(
        context,
        listen: false,
      ).clientes.firstWhere((c) => c.dni == venta.clienteId);
      _clienteSeleccionado = _clienteDeEstaVenta;
    } catch (e) {
      _clienteDeEstaVenta = null;
      _clienteSeleccionado = null;
    }

    // --- Pre-rellenamos TODOS los campos ---

    // 1. Cliente (Sin la línea duplicada)
    _clienteCtrl = TextEditingController(
      text: _clienteDeEstaVenta != null
          ? '${_clienteDeEstaVenta!.nombre} ${_clienteDeEstaVenta!.apellidos ?? ''}'
          : 'Cliente (ID: ${venta.clienteId})',
    );

    // 2. Cantidad (Línea de )
    _cantidadCtrl = TextEditingController(text: venta.cantidad.toString());

    // 3. Precio (¡Esta es la línea que faltaba!)
    _precioCtrl = TextEditingController(text: venta.precioUnitario.toString());

    // --- LÓGICA DE DROPDOWN CORREGIDA ---
    // Comprueba si el producto de la venta está en nuestra lista de opciones
    if (_tiposDeTraje.contains(venta.producto)) {
      _selectedTraje = venta.producto;
    } else {
      _selectedTraje = null;
    }
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

  // --- 4. FUNCIÓN '_submitForm' CORREGIDA ---
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ventaActualizada = Venta(
      codigo: widget.venta.codigo, // Mantenemos el código original
      clienteId: widget.venta.clienteId, // Mantenemos el ID de cliente original
      fecha: widget.venta.fecha, // Mantenemos la fecha original
      producto: _selectedTraje ?? 'Producto no seleccionado',
      cantidad: int.tryParse(_cantidadCtrl.text) ?? 0,
      precioUnitario: double.tryParse(_precioCtrl.text) ?? 0.0,
      metodoPago: _selectedPaymentMethod,
      total: _total,
    );

    Provider.of<VentaProvider>(
      context,
      listen: false,
    ).editarVenta(ventaActualizada);

    Navigator.pop(context); // Regresamos al detalle
  }

  void _abrirSelectorCliente() async {
    final Cliente? clienteSeleccionado =
        await Navigator.pushNamed(context, Routes.seleccionarCliente)
            as Cliente?;

    if (clienteSeleccionado != null) {
      setState(() {
        _clienteSeleccionado = clienteSeleccionado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    // --- 5. CAMPO CLIENTE (AHORA SOLO LECTURA) ---
                    _buildTextField(
                      controller: _clienteCtrl,
                      label: 'Cliente',
                      hint: null, // <-- Eliminamos el hint confuso
                      icon: null, // <-- Eliminamos el ícono de "selección"
                      isRequired: false,
                      isReadOnly: true, // Lo hacemos de solo lectura
                    ),
                    const SizedBox(height: 16),

                    // --- FIN DEL CAMBIO ---
                    _buildDropdownField(
                      label: 'Tipo de traje',
                      hint: 'Seleccionar tipo',
                      value: _selectedTraje,
                      items: _tiposDeTraje, // <-- USA LA LISTA MAESTRA
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
                      child: const Text('Guardar Cambios'),
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

  // --- (Los widgets auxiliares _buildTextField, _buildDropdownField,
  // --- y _buildPaymentButton son idénticos al archivo nueva_venta_screen.dart,
  // --- así que los copio aquí por completitud) ---

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
