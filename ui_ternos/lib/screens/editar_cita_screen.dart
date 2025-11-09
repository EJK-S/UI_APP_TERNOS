// lib/screens/editar_cita_screen.dart (REEMPLAZAR)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class EditarCitaScreen extends StatefulWidget {
  final Cita cita;
  const EditarCitaScreen({super.key, required this.cita});

  @override
  State<EditarCitaScreen> createState() => _EditarCitaScreenState();
}

class _EditarCitaScreenState extends State<EditarCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _clienteCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _prendasCtrl;
  late TextEditingController _fechaCtrl;
  late TextEditingController _horaCtrl;
  late CitaTipo _tipoCita;

  @override
  void initState() {
    super.initState();
    // Pre-rellenamos los campos con los datos de la cita
    final cita = widget.cita;
    _clienteCtrl = TextEditingController(text: cita.clienteNombre);
    _telefonoCtrl = TextEditingController(text: cita.clienteTelefono);
    _emailCtrl = TextEditingController(text: cita.clienteEmail);
    _prendasCtrl = TextEditingController(text: cita.prendasResumen);
    _fechaCtrl = TextEditingController(text: cita.fecha);
    _horaCtrl = TextEditingController(text: cita.hora);
    _tipoCita = cita.tipo;
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _prendasCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final citaActualizada = Cita(
      tipo: _tipoCita,
      clienteNombre: _clienteCtrl.text,
      prendasResumen: _prendasCtrl.text,
      fecha: _fechaCtrl.text,
      hora: _horaCtrl.text,
      estado: widget.cita.estado, // Mantenemos el estado original
      clienteTelefono: _telefonoCtrl.text,
      clienteEmail: _emailCtrl.text,
      prendaDetalleNombre: _prendasCtrl.text.split(',').first,
      prendaDetalleId: widget.cita.prendaDetalleId, // Mantenemos el ID original
    );

    // Llamamos al provider para editar
    Provider.of<CitaProvider>(
      context,
      listen: false,
    ).editarCita(citaActualizada);

    Navigator.pop(context); // Cierra la pantalla de edición
    Navigator.pop(context); // Cierra la pantalla de detalle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cita')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              DropdownButtonFormField<CitaTipo>(
                initialValue: _tipoCita,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cita',
                  border: OutlineInputBorder(),
                ),
                items: CitaTipo.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.tipoTexto),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _tipoCita = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clienteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prendasCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prendas',
                  hintText: 'Ej. Terno Negro, Camisa Blanca...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.checkroom),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fechaCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Requerido' : null,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _horaCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Hora',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? 'Requerido' : null,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      _fechaCtrl.text =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
    }
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      _horaCtrl.text = pickedTime.format(context);
    }
  }
}
