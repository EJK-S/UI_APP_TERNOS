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
  late TextEditingController _celularCtrl;
  late TextEditingController _direccionCtrl;
  late TextEditingController _fechaCtrl;
  late TextEditingController _motivoVetoCtrl;
  late bool _vetado;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;

    _nombresCtrl = TextEditingController(text: c.nombres);
    _apellidosCtrl = TextEditingController(text: c.apellidos);
    _dniCtrl = TextEditingController(text: c.dni);
    _celularCtrl = TextEditingController(text: c.celular);
    _direccionCtrl = TextEditingController(text: c.direccion ?? '');
    _fechaCtrl = TextEditingController(text: c.fechaNac ?? '');
    _vetado = c.vetado;
    _motivoVetoCtrl = TextEditingController(text: c.motivoVeto ?? '');
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _celularCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaCtrl.dispose();
    _motivoVetoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final initial = _fechaCtrl.text.isNotEmpty
        ? DateTime.tryParse(_fechaCtrl.text) ?? DateTime(now.year - 18)
        : DateTime(now.year - 18);

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: initial,
    );

    if (picked != null) {
      // mismo formato que en NuevoCliente (YYYY-MM-DD)
      _fechaCtrl.text = picked.toIso8601String().split('T').first;
      setState(() {});
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final prov = context.read<ClienteProvider>();

    final data = <String, dynamic>{
      'id': widget.cliente.id,
      'nombres': _nombresCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'dni': _dniCtrl.text.trim(),
      'celular': _celularCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim(),
      'fecha_nac': _fechaCtrl.text.trim().isEmpty
          ? null
          : _fechaCtrl.text.trim(),
      'vetado': _vetado,
      'motivo_veto': _vetado ? _motivoVetoCtrl.text.trim() : null,
    };

    try {
      final ok = await prov.actualizarCliente(data);

      if (!mounted) return;

      if (ok) {
        Navigator.pop(context, true); // volvemos avisando que hubo cambios
      } else {
        final msg = prov.error ?? 'No se pudo guardar los cambios';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isSaving ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
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
                label: 'DNI (8 dígitos)',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.length != 8 || int.tryParse(s) == null) {
                    return 'DNI inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _celularCtrl,
                label: 'Celular (9 dígitos)',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.length != 9 || int.tryParse(s) == null) {
                    return 'Celular inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _direccionCtrl,
                label: 'Dirección',
                isRequired: false,
              ),
              const SizedBox(height: 16),
              _buildDateField(
                controller: _fechaCtrl,
                label: 'Fecha de nacimiento',
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
                  isRequired: true,
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
                onPressed: _isSaving ? null : _guardarCambios,
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
                    : const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
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
          validator:
              validator ??
              (value) {
                if (isRequired && (value == null || value.trim().isEmpty)) {
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
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
          onTap: _pickFecha,
        ),
      ],
    );
  }
}
