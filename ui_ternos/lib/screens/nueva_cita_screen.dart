// lib/screens/nueva_cita_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final _clienteCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _prendasCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();

  // Valor inicial para el Dropdown
  CitaTipo _tipoCita = CitaTipo.Prueba;

  @override
  void dispose() {
    // Limpiamos los controladores
    _clienteCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    _prendasCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }

  // --- 2. LÓGICA PARA ENVIAR EL FORMULARIO ---
  void _submitForm() {
    // Validamos que el formulario esté correcto
    if (!_formKey.currentState!.validate()) {
      return; // Si no es válido, no hacemos nada
    }

    // Creamos el nuevo objeto Cita con los datos del formulario
    final nuevaCita = Cita(
      tipo: _tipoCita,
      clienteNombre: _clienteCtrl.text,
      prendasResumen: _prendasCtrl.text,
      fecha: _fechaCtrl.text,
      hora: _horaCtrl.text,
      estado: CitaEstado.Pendiente, // Las nuevas citas siempre están pendientes
      clienteTelefono: _telefonoCtrl.text,
      clienteEmail: _emailCtrl.text,
      // (Datos de detalle que podemos inferir o dejar por defecto)
      prendaDetalleNombre: _prendasCtrl.text
          .split(',')
          .first, // Pone la primera prenda
      prendaDetalleId:
          'T-${DateTime.now().millisecondsSinceEpoch}', // ID temporal
    );

    // --- 3. HABLAMOS CON EL "CEREBRO" ---
    // Obtenemos la instancia del CitaProvider y llamamos al método
    Provider.of<CitaProvider>(context, listen: false).agregarCita(nuevaCita);

    // --- 4. REGRESAMOS A LA LISTA ---
    // (La lista se actualizará sola gracias al Consumer)
    Navigator.pop(context);
  }

  // --- 1. CONSTRUIMOS EL FORMULARIO ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nueva Cita')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- Tipo de Cita ---
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
              // --- Cliente ---
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
              // --- Teléfono ---
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
              // --- Email ---
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
              // --- Prendas ---
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
              // --- Fila de Fecha y Hora ---
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
                      onTap: _pickDate, // Helper para DatePicker
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
                      onTap: _pickTime, // Helper para TimePicker
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // --- Botón de Guardar ---
              ElevatedButton(
                onPressed: _submitForm, // <-- CONECTADO
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Cita'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper para mostrar el DatePicker ---
  Future<void> _pickDate() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      // Formateamos la fecha
      _fechaCtrl.text =
          "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
    }
  }

  // --- Helper para mostrar el TimePicker ---
  Future<void> _pickTime() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Formateamos la hora
      _horaCtrl.text = pickedTime.format(context);
    }
  }
}
