// lib/screens/gestion_clientes/editar_cliente_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class EditarClienteScreen extends StatefulWidget {
  final Cliente cliente;
  const EditarClienteScreen({super.key, required this.cliente});

  @override
  State<EditarClienteScreen> createState() => _EditarClienteScreenState();
}

class _EditarClienteScreenState extends State<EditarClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombresCtrl;
  late TextEditingController _apellidosCtrl;
  late TextEditingController _dniCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _correoCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _fechaNacimientoCtrl;
  late TextEditingController _motivoVetoCtrl;
  late bool _vetado;

  // --- 1. AÑADIR ESTADO DE CARGA ---
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // (Tu initState ya era correcto [cite: 618-624])
    _nombresCtrl = TextEditingController(text: widget.cliente.nombre);
    _apellidosCtrl = TextEditingController(
      text: widget.cliente.apellidos ?? '',
    );
    _dniCtrl = TextEditingController(text: widget.cliente.dni);
    _telefonoCtrl = TextEditingController(text: widget.cliente.telefono);
    _correoCtrl = TextEditingController(text: widget.cliente.correo ?? '');
    _direccionCtrl = TextEditingController(
      text: widget.cliente.direccion ?? '',
    );
    _fechaNacimientoCtrl = TextEditingController(
      text: widget.cliente.fechaNacimiento ?? '',
    );
    _motivoVetoCtrl = TextEditingController(
      text: widget.cliente.motivoVeto ?? '',
    );
    _vetado = widget.cliente.vetado ?? false;
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaNacimientoCtrl.dispose();
    _motivoVetoCtrl.dispose();
    super.dispose();
  }

  // --- 2. ACTUALIZAR FUNCIÓN DE GUARDAR (AHORA ASÍNCRONA) ---
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Crea el objeto Cliente actualizado
      final clienteActualizado = Cliente(
        id: widget.cliente.id, // <-- CORRECCIÓN: Pasar el ID original
        nombre: _nombresCtrl.text,
        apellidos: _apellidosCtrl.text,
        dni: _dniCtrl.text,
        telefono: _telefonoCtrl.text,
        correo: _correoCtrl.text,
        direccion: _direccionCtrl.text,
        fechaNacimiento: _fechaNacimientoCtrl.text,
        vetado: _vetado,
        motivoVeto: _motivoVetoCtrl.text,
      );

      // "Habla" con el cerebro (CON AWAIT)
      await context.read<ClienteProvider>().editarCliente(clienteActualizado);

      // Cierra la pantalla (solo si el widget sigue "montado")
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            // (El contenido del ListView no necesita cambios)
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _nombresCtrl,
                      label: 'Nombres',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _apellidosCtrl,
                      label: 'Apellidos',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dniCtrl,
                label: 'DNI',
                keyboardType: TextInputType.number,
                // Nota: Idealmente, el DNI no debería ser editable
                // consideren hacerlo 'readOnly: true'
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _telefonoCtrl,
                label: 'Teléfono',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _correoCtrl,
                label: 'Correo',
                keyboardType: TextInputType.emailAddress,
                isRequired: false,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionCtrl,
                label: 'Dirección',
                isRequired: false,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                controller: _fechaNacimientoCtrl,
                label: 'Fecha de Nacimiento',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Vetado'),
                value: _vetado,
                onChanged: (bool? value) {
                  setState(() {
                    _vetado = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              if (_vetado)
                _buildTextField(
                  controller: _motivoVetoCtrl,
                  label: 'Motivo de veto',
                  hint: 'Ingresar motivo',
                  isRequired: false,
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                // --- 3. CORREGIR BOTÓN DE CANCELAR ---
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                // --- 4. CORREGIR BOTÓN DE GUARDAR ---
                onPressed: _isSaving ? null : _guardarCambios, // Conectado
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
            ),
          ],
        ),
      ),
    );
  }

  // --- (Tus widgets helper _buildTextField y _buildDateField
  //      no necesitan cambios [cite: 649-660]) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Requerido';
            }
            return null;
          },
        ),
      ],
    );
  }

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
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onTap: () async {
            FocusScope.of(context).requestFocus(new FocusNode());
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
        ),
      ],
    );
  }
}
