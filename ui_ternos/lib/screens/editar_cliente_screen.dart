import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import '../utils/date_utils.dart';

class EditarClienteScreen extends StatefulWidget {
  final Cliente cliente;
  const EditarClienteScreen({super.key, required this.cliente});

  @override
  State<EditarClienteScreen> createState() => _EditarClienteScreenState();
}

class _EditarClienteScreenState extends State<EditarClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombresCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _dniCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _fechaNacimientoCtrl;
  bool _vetado = false;
  late final TextEditingController _motivoVetoCtrl;

  /*String? _normFecha(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (m != null) return '${m.group(1)}-${m.group(2)}-${m.group(3)}';
    if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(raw)) {
      final p = raw.split('/');
      return '${p[2]}-${p[1]}-${p[0]}';
    }
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }*/

  @override
  void initState() {
    super.initState();
    final c = widget.cliente; // ← aquí sí puedes usar widget
    _nombresCtrl = TextEditingController(text: c.nombre);
    _apellidosCtrl = TextEditingController(text: c.apellidos ?? '');
    _dniCtrl = TextEditingController(text: c.dni);
    _telefonoCtrl = TextEditingController(text: c.telefono);
    _direccionCtrl = TextEditingController(text: c.direccion ?? '');
    _fechaNacimientoCtrl = TextEditingController(
      text: normalizeFecha(c.fechaNacimiento) ?? '',
    );
    _vetado = c.vetado == true;
    _motivoVetoCtrl = TextEditingController(text: c.motivoVeto ?? '');
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaNacimientoCtrl.dispose();
    _motivoVetoCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final editado = Cliente(
      id: widget.cliente.id,
      nombre: _nombresCtrl.text.trim(),
      apellidos: _apellidosCtrl.text.trim().isEmpty
          ? null
          : _apellidosCtrl.text.trim(),
      dni: _dniCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim(),
      fechaNacimiento: normalizeFecha(
        _fechaNacimientoCtrl.text.trim(),
      ), // normalizado
      vetado: _vetado,
      motivoVeto: _vetado
          ? (_motivoVetoCtrl.text.trim().isEmpty
                ? 'Vetado'
                : _motivoVetoCtrl.text.trim())
          : null,
    );
    Navigator.pop(context, editado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(_nombresCtrl, 'Nombres', required: true),
              _input(_apellidosCtrl, 'Apellidos'),
              _input(
                _dniCtrl,
                'DNI',
                required: true,
                keyboard: TextInputType.number,
              ),
              _input(
                _telefonoCtrl,
                'Teléfono',
                required: true,
                keyboard: TextInputType.phone,
              ),
              _input(_direccionCtrl, 'Dirección'),
              _fechaInput(_fechaNacimientoCtrl, 'Fecha de nacimiento'),
              SwitchListTile(
                value: _vetado,
                onChanged: (v) => setState(() => _vetado = v),
                title: const Text('Vetado'),
              ),
              if (_vetado)
                _input(_motivoVetoCtrl, 'Motivo de veto', required: true),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    bool required = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        keyboardType: keyboard,
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return 'Requerido';
          return null;
        },
      ),
    );
  }

  Widget _fechaInput(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(c.text) ?? DateTime(2000, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                c.text =
                    "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              }
            },
            icon: const Icon(Icons.date_range),
          ),
        ),
      ),
    );
  }
}
