// lib/screens/nueva_cita_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';

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
  // El estado en backend SIEMPRE inicia como PENDIENTE
  final CitaEstado _estadoFijo = CitaEstado.Pendiente;

  @override
  void dispose() {
    _clienteCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  // --- 1. Selector de clientes ---
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

  // --- 2. Envío del formulario ---
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

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

    final fechaHoraCompleta = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final nuevaCita = Cita(
      clienteId: _selectedCliente!.id!,
      fechaHora: fechaHoraCompleta,
      proposito: _selectedProposito!,
      estado: CitaEstado.Pendiente,
      notas: _notasCtrl.text.isNotEmpty ? _notasCtrl.text : null,
    );

    final prov = Provider.of<CitaProvider>(context, listen: false);
    final ok = await prov.agregarCita(nuevaCita);

    if (!ok) {
      _showError(prov.error ?? 'No se pudo registrar la cita');
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // --- 3. Pickers de Fecha y Hora ---
  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day), // no fechas pasadas
      lastDate: now.add(const Duration(days: 365)),
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

  // --- 4. UI ---
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
                  // --- Card principal --- //
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Cliente --- //
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
                          validator: (_) {
                            if (_selectedCliente == null) {
                              return 'Seleccione un cliente';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Fecha y Hora en fila --- //
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
                                      hintText: 'dd/MM/yyyy',
                                    ),
                                    validator: (_) {
                                      if (_selectedDate == null) {
                                        return 'Seleccione una fecha';
                                      }
                                      return null;
                                    },
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
                                    validator: (_) {
                                      if (_selectedTime == null) {
                                        return 'Seleccione una hora';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Propósito --- //
                        Text(
                          'Propósito',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<CitaProposito>(
                          value: _selectedProposito,
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
                          validator: (value) {
                            if (value == null) {
                              return 'Seleccione un propósito';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // --- Estado (solo info, siempre Pendiente) --- //
                        Text(
                          'Estado inicial',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _estadoFijo.texto, // "Pendiente"
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Notas --- //
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

                  // --- Botones --- //
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
