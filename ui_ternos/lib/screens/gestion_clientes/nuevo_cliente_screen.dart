import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';

class NuevoClienteScreen extends StatefulWidget {
  const NuevoClienteScreen({super.key});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();

  bool _vetado = false;
  Cliente? _editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (_editing == null && arg is Cliente) {
      _editing = arg;
      _nombresCtrl.text = arg.nombres;
      _apellidosCtrl.text = arg.apellidos;
      _dniCtrl.text = arg.dni;
      _celularCtrl.text = arg.celular;
      _direccionCtrl.text = arg.direccion ?? '';
      _fechaCtrl.text = arg.fechaNac ?? '';
      _vetado = arg.vetado;
      _motivoCtrl.text = arg.motivoVeto ?? '';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _celularCtrl.dispose();
    _direccionCtrl.dispose();
    _fechaCtrl.dispose();
    _motivoCtrl.dispose();
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
      _fechaCtrl.text = picked.toIso8601String().split('T').first;
      setState(() {});
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = context.read<ClienteProvider>();

    // Construimos MAP → 100% compatible con tu API
    final data = {
      if (_editing != null) 'id': _editing!.id,
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
      'motivo_veto': _vetado ? _motivoCtrl.text.trim() : null,
    };

    bool ok;

    if (_editing == null) {
      ok = await prov.agregarCliente(data);
    } else {
      ok = await prov.actualizarCliente(data);
    }

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    } else {
      final msg = prov.error ?? "Ocurrió un error";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Editar Cliente" : "Nuevo Cliente")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombresCtrl,
              decoration: const InputDecoration(labelText: 'Nombres *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _apellidosCtrl,
              decoration: const InputDecoration(labelText: 'Apellidos *'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _dniCtrl,
              decoration: const InputDecoration(labelText: 'DNI (8 dígitos) *'),
              keyboardType: TextInputType.number,
              maxLength: 8,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.length != 8 || int.tryParse(s) == null) {
                  return 'DNI inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _celularCtrl,
              decoration: const InputDecoration(
                labelText: 'Celular (9 dígitos) *',
              ),
              keyboardType: TextInputType.number,
              maxLength: 9,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.length != 9 || int.tryParse(s) == null) {
                  return 'Celular inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(labelText: 'Dirección'),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _fechaCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _pickFecha,
                ),
              ),
            ),

            const SizedBox(height: 12),
            SwitchListTile(
              value: _vetado,
              onChanged: (v) => setState(() => _vetado = v),
              title: const Text('Vetado'),
            ),

            if (_vetado) ...[
              TextFormField(
                controller: _motivoCtrl,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Motivo del veto *',
                ),
                validator: (v) {
                  if (_vetado && (v == null || v.trim().isEmpty)) {
                    return 'Requerido cuando vetado = true';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Guardar cambios' : 'Crear cliente'),
            ),
          ],
        ),
      ),
    );
  }
}
