// lib/screens/gestion_citas/editar_cita_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORTAR INTL

class EditarCitaScreen extends StatefulWidget {
  final Cita cita;
  const EditarCitaScreen({super.key, required this.cita});

  @override
  State<EditarCitaScreen> createState() => _EditarCitaScreenState();
}

class _EditarCitaScreenState extends State<EditarCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- 2. CONTROLADORES Y ESTADO ACTUALIZADOS ---
  late TextEditingController _clienteCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _notasCtrl; // Reemplaza a _prendasCtrl
  late TextEditingController _fechaDisplayCtrl; // Para el texto de la fecha
  late TextEditingController _horaDisplayCtrl; // Para el texto de la hora

  late CitaProposito _selectedProposito; // Reemplaza a _tipoCita
  late CitaEstado _selectedEstado;
  late DateTime _selectedFechaHora; // El estado real de la fecha/hora

  Cliente? _clienteSeleccionado;
  bool _isSaving = false; // Para el botón de guardar

  @override
  void initState() {
    super.initState();

    final cita = widget.cita;

    // --- 3. LÓGICA DE 'initState' CORREGIDA ---

    // Buscar cliente (esto ya estaba bien)
    try {
      _clienteSeleccionado = context
          .read<ClienteProvider>()
          .clientes
          .firstWhere((c) => c.id == cita.clienteId);
    } catch (e) {
      _clienteSeleccionado = null;
    }

    // Pre-rellenar campos de texto
    _clienteCtrl = TextEditingController(
      text: _clienteSeleccionado != null
          ? '${_clienteSeleccionado!.nombre} ${_clienteSeleccionado!.apellidos ?? ''}'
          : 'Cliente no encontrado',
    );
    _telefonoCtrl = TextEditingController(
      text: _clienteSeleccionado?.telefono ?? '',
    );
    _notasCtrl = TextEditingController(text: cita.notas ?? '');

    // Inicializar los nuevos estados
    _selectedProposito = cita.proposito;
    _selectedEstado = cita.estado;
    _selectedFechaHora = cita.fechaHora;

    // Inicializar los controladores de display de fecha/hora
    _fechaDisplayCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_selectedFechaHora),
    );
    _horaDisplayCtrl = TextEditingController(
      text: DateFormat('hh:mm a').format(_selectedFechaHora),
    );
  }

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _telefonoCtrl.dispose();
    _notasCtrl.dispose();
    _fechaDisplayCtrl.dispose();
    _horaDisplayCtrl.dispose();
    super.dispose();
  }

  // --- 4. FUNCIÓN _submitForm (CORREGIDA CON ASYNC/AWAIT) ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Crear el objeto Cita actualizado con el NUEVO modelo
      final citaActualizada = Cita(
        id: widget.cita.id, // <-- Mantenemos el ID original
        clienteId: widget.cita.clienteId, // El cliente no se puede cambiar
        fechaHora: _selectedFechaHora, // <-- El nuevo DateTime
        proposito: _selectedProposito, // <-- El nuevo Proposito
        estado: _selectedEstado, // <-- El nuevo Estado
        notas: _notasCtrl.text.isNotEmpty ? _notasCtrl.text : null,
      );

      // Llamamos al provider para editar (CON AWAIT)
      await context.read<CitaProvider>().editarCita(citaActualizada);

      if (mounted) {
        Navigator.pop(context); // Cierra la pantalla de edición
        Navigator.pop(context); // Cierra la pantalla de detalle
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar la cita: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- 5. PICKERS (CORREGIDOS PARA MANEJAR UN SOLO 'DateTime') ---

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedFechaHora,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        // Combina la nueva fecha con la hora existente
        _selectedFechaHora = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedFechaHora.hour,
          _selectedFechaHora.minute,
        );
        // Actualiza el texto del controlador
        _fechaDisplayCtrl.text = DateFormat(
          'dd/MM/yyyy',
        ).format(_selectedFechaHora);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedFechaHora),
    );

    if (pickedTime != null) {
      setState(() {
        // Combina la fecha existente con la nueva hora
        _selectedFechaHora = DateTime(
          _selectedFechaHora.year,
          _selectedFechaHora.month,
          _selectedFechaHora.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        // Actualiza el texto del controlador
        _horaDisplayCtrl.text = DateFormat(
          'hh:mm a',
        ).format(_selectedFechaHora);
      });
    }
  }

  // --- 6. BUILD (CORREGIDO) ---
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
              // --- Propósito (Corregido) ---
              DropdownButtonFormField<CitaProposito>(
                value: _selectedProposito,
                decoration: const InputDecoration(
                  labelText: 'Propósito',
                  border: OutlineInputBorder(),
                ),
                items: CitaProposito.values.map((proposito) {
                  return DropdownMenuItem(
                    value: proposito,
                    child: Text(proposito.texto),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedProposito = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // --- Estado (Añadido) ---
              DropdownButtonFormField<CitaEstado>(
                value: _selectedEstado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: CitaEstado.values.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado.texto),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedEstado = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // --- Campos de Cliente (Solo lectura, ya estaban bien) ---
              TextFormField(
                controller: _clienteCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Cliente',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonoCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // --- Notas (Corregido) ---
              TextFormField(
                controller: _notasCtrl, // <-- CORREGIDO
                decoration: const InputDecoration(
                  labelText: 'Notas (Opcional)', // <-- CORREGIDO
                  hintText: 'Añadir notas adicionales...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 4,
                // (Validator ya no es necesario si es opcional)
              ),
              const SizedBox(height: 16),

              // --- Fecha y Hora (Corregido) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fechaDisplayCtrl, // <-- CORREGIDO
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
                      controller: _horaDisplayCtrl, // <-- CORREGIDO
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

              // --- Botón de Guardar (Corregido) ---
              ElevatedButton(
                onPressed: _isSaving ? null : _submitForm, // <-- CORREGIDO
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    _isSaving // <-- CORREGIDO
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
            ],
          ),
        ),
      ),
    );
  }
}
