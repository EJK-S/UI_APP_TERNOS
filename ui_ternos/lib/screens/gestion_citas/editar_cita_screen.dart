// lib/screens/editar_cita_screen.dart (REEMPLAZAR)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';

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

  // Guardamos el cliente encontrado
  Cliente? _clienteSeleccionado;

  @override
  void initState() {
    super.initState();

    // --- 3. LÓGICA DE 'initState' CORREGIDA ---
    final cita = widget.cita;

    // Buscamos al cliente en el ClienteProvider
    try {
      _clienteSeleccionado = Provider.of<ClienteProvider>(
        context,
        listen: false,
      ).clientes.firstWhere((c) => c.dni == cita.clienteId);
    } catch (e) {
      _clienteSeleccionado = null;
    }

    // Pre-rellenamos los campos
    _clienteCtrl = TextEditingController(
      text: _clienteSeleccionado != null
          ? '${_clienteSeleccionado!.nombre} ${_clienteSeleccionado!.apellidos ?? ''}'
          : 'Cliente no encontrado',
    );
    _telefonoCtrl = TextEditingController(
      text: _clienteSeleccionado?.telefono ?? '',
    );
    _emailCtrl = TextEditingController(
      text: _clienteSeleccionado?.correo ?? '',
    );
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
      clienteId: widget.cita.clienteId, // Mantenemos el ID del cliente original
      tipo: _tipoCita,
      prendasResumen: _prendasCtrl.text,
      fecha: _fechaCtrl.text,
      hora: _horaCtrl.text,
      estado: widget.cita.estado, // Mantenemos el estado original
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
                value: _tipoCita,
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

              // --- 5. CAMPOS DE CLIENTE (AHORA DE SOLO LECTURA) ---
              // Editar el cliente debería hacerse desde 'editar_cliente_screen.dart'
              // Aquí solo mostramos quién es.
              TextFormField(
                controller: _clienteCtrl,
                readOnly: true, // No dejamos editar el nombre aquí
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                readOnly: true, // No dejamos editar el teléfono aquí
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // --- FIN DE CAMPOS DE SOLO LECTURA ---
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
