import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import '../utils/date_utils.dart';

class NuevoClienteScreen extends StatefulWidget {
  const NuevoClienteScreen({super.key});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombresCtrl;
  late final TextEditingController _apellidosCtrl;
  late final TextEditingController _dniCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _fechaNacimientoCtrl;
  bool _vetado = false;
  late final TextEditingController _motivoVetoCtrl;

  @override
  void initState() {
    super.initState();
    _nombresCtrl = TextEditingController();
    _apellidosCtrl = TextEditingController();
    _dniCtrl = TextEditingController();
    _telefonoCtrl = TextEditingController();
    _direccionCtrl = TextEditingController();
    _fechaNacimientoCtrl = TextEditingController(); // ← NO uses widget aquí
    _motivoVetoCtrl = TextEditingController();
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
    final nuevo = Cliente(
      nombre: _nombresCtrl.text.trim(),
      apellidos: _apellidosCtrl.text.trim().isEmpty
          ? null
          : _apellidosCtrl.text.trim(),
      dni: _dniCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim().isEmpty
          ? null
          : _direccionCtrl.text.trim(),
      fechaNacimiento: normalizeFecha(_fechaNacimientoCtrl.text.trim()),
      vetado: _vetado,
      motivoVeto: _vetado
          ? (_motivoVetoCtrl.text.trim().isEmpty
                ? 'Vetado'
                : _motivoVetoCtrl.text.trim())
          : null,
    );
    Navigator.pop(context, nuevo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo cliente')),
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
                label: const Text('Guardar'),
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
                initialDate: DateTime(2000, 1, 1),
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
