// lib/screens/nueva_cita_screen.dart (Actualizado al nuevo diseño)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:intl/intl.dart'; // Necesario para formatear fechas y horas

class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _clienteCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  // Variables para guardar los datos reales
  Cliente? _selectedCliente;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  CitaProposito? _selectedProposito;
  CitaEstado _selectedEstado = CitaEstado.Pendiente; // Valor por defecto

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  // --- 1. Lógica para abrir el selector de clientes ---
  void _abrirSelectorCliente() async {
    final Cliente? clienteSeleccionado =
        await Navigator.pushNamed(context, Routes.seleccionarCliente)
            as Cliente?;
    if (clienteSeleccionado != null) {
      setState(() {
        _selectedCliente = clienteSeleccionado;
        _clienteCtrl.text =
            '${clienteSeleccionado.nombres} ${clienteSeleccionado.apellidos ?? ''}';
      });
    }
  }

  // --- 2. Lógica de envío del formulario ---
  void _submitForm() {
    // Validar el formulario
    if (!_formKey.currentState!.validate()) return;

    // Validar selecciones manuales
    if (_selectedCliente == null) {
      _showError('Por favor, seleccione un cliente.');
      return;
    }
    if (_selectedDate == null) {
      _showError('Por favor, seleccione una fecha.');
      return;
    }
    if (_selectedTime == null) {
      _showError('Por favor, seleccione una hora.');
      return;
    }
    if (_selectedProposito == null) {
      _showError('Por favor, seleccione un propósito.');
      return;
    }

    // ¡CRÍTICO! Combinar fecha y hora en un solo DateTime
    final DateTime fechaHoraCompleta = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Crear el nuevo objeto Cita
    final nuevaCita = Cita(
      // ⚠️ ¡VER ALERTA CRÍTICA ABAJO!
      clienteId: _selectedCliente!.id!, // Asumiendo que 'id' existe
      fechaHora: fechaHoraCompleta,
      proposito: _selectedProposito!,
      estado: _selectedEstado,
      notas: _notasCtrl.text.isNotEmpty ? _notasCtrl.text : null,
    );

    Provider.of<CitaProvider>(context, listen: false).agregarCita(nuevaCita);
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- 3. Pickers de Fecha y Hora ---
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _fechaCtrl.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        // Formatear la hora
        final now = DateTime.now();
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        _horaCtrl.text = DateFormat('hh:mm a').format(dt); // ej. 02:30 PM
      });
    }
  }

  // --- 4. Construcción de la Interfaz ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo gris claro
      appBar: AppBar(
        title: const Text('Nueva Cita'),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Card de Formulario ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Cliente ---
                        Text(
                          'Cliente',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _clienteCtrl,
                          readOnly: true,
                          onTap: _abrirSelectorCliente,
                          decoration: const InputDecoration(
                            hintText: 'Buscar o seleccionar cliente',
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Fecha y Hora en Fila ---
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fecha de la cita',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _fechaCtrl,
                                    readOnly: true,
                                    onTap: _pickDate,
                                    decoration: const InputDecoration(
                                      hintText: 'mm/dd/yyyy',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hora de la cita',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _horaCtrl,
                                    readOnly: true,
                                    onTap: _pickTime,
                                    decoration: const InputDecoration(
                                      hintText: '--:--',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Propósito ---
                        Text(
                          'Propósito',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CitaProposito>(
                          initialValue: _selectedProposito,
                          hint: const Text('Seleccionar propósito'),
                          items: CitaProposito.values.map((proposito) {
                            return DropdownMenuItem(
                              value: proposito,
                              child: Text(proposito.texto),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedProposito = value);
                          },
                          decoration: const InputDecoration(),
                        ),
                        const SizedBox(height: 16),

                        // --- Estado ---
                        Text(
                          'Estado',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CitaEstado>(
                          initialValue: _selectedEstado,
                          hint: const Text('Seleccionar estado'),
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
                          decoration: const InputDecoration(),
                        ),
                        const SizedBox(height: 16),

                        // --- Notas ---
                        Text(
                          'Notas (Opcional)',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notasCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Añadir notas adicionales...',
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  // --- Botones de Acción ---
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Registrar Cita'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
