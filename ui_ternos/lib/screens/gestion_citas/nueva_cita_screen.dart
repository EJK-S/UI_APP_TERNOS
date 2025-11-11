// lib/screens/nueva_cita_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart'; // <-- 1. IMPORTA EL MODELO CLIENTE

class NuevaCitaScreen extends StatefulWidget {
  const NuevaCitaScreen({super.key});

  @override
  State<NuevaCitaScreen> createState() => _NuevaCitaScreenState();
}

class _NuevaCitaScreenState extends State<NuevaCitaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final _prendasCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();

  Cliente? _selectedCliente;
  // Valor inicial para el Dropdown
  CitaTipo _tipoCita = CitaTipo.Prueba;

  @override
  void dispose() {
    // Limpiamos los controladores
    _prendasCtrl.dispose();
    _fechaCtrl.dispose();
    _horaCtrl.dispose();
    super.dispose();
  }

  void _abrirSelectorCliente() async {
    final Cliente? clienteSeleccionado =
        await Navigator.pushNamed(context, Routes.seleccionarCliente)
            as Cliente?;

    if (clienteSeleccionado != null) {
      setState(() {
        _selectedCliente = clienteSeleccionado;
      });
    }
  }

  // --- 2. LÓGICA PARA ENVIAR EL FORMULARIO ---
  void _submitForm() {
    // Valida el formulario Y el cliente
    if (!_formKey.currentState!.validate() || _selectedCliente == null) {
      if (_selectedCliente == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, seleccione un cliente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    // Crea el nuevo objeto Cita con el constructor corregido
    final nuevaCita = Cita(
      clienteId: _selectedCliente!.dni, // <-- USA EL ID
      tipo: _tipoCita,
      prendasResumen: _prendasCtrl.text,
      fecha: _fechaCtrl.text,
      hora: _horaCtrl.text,
      estado: CitaEstado.Pendiente,
      prendaDetalleNombre: _prendasCtrl.text.split(',').first,
      prendaDetalleId: 'T-${DateTime.now().millisecondsSinceEpoch}',
    );

    Provider.of<CitaProvider>(context, listen: false).agregarCita(nuevaCita);

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
              // --- Tipo de Cita (Dropdown) ---
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

              // --- 6. CAMPO DE CLIENTE REEMPLAZADO ---
              Text(
                'Cliente *',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _abrirSelectorCliente,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCliente == null
                            ? 'Seleccionar cliente'
                            : '${_selectedCliente!.nombre} ${_selectedCliente!.apellidos ?? ''}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedCliente == null
                              ? AppColors.stone600
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.search, color: AppColors.stone600),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- FIN DEL REEMPLAZO ---

              // (Los campos de Teléfono y Email se eliminan
              //  porque ya están en el selector de cliente)
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
