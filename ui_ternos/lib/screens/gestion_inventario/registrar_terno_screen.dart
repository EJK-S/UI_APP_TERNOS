// lib/screens/registrar_terno_screen.dart (Refactorizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class RegistrarTernoScreen extends StatefulWidget {
  const RegistrarTernoScreen({super.key});

  @override
  State<RegistrarTernoScreen> createState() => _RegistrarTernoScreenState();
}

class _RegistrarTernoScreenState extends State<RegistrarTernoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para la PRENDA
  final _idCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _tallaCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  // Estado inicial
  PrendaEstado _estado = PrendaEstado.Disponible;

  @override
  void dispose() {
    _idCtrl.dispose();
    _nombreCtrl.dispose();
    _tallaCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return; // Formulario no válido
    }

    // Creamos la nueva Prenda
    final nuevaPrenda = Prenda(
      id: _idCtrl.text,
      nombre: _nombreCtrl.text,
      talla: _tallaCtrl.text,
      categoria: _categoriaCtrl.text,
      estado: _estado,
      usos: 0, // Una prenda nueva tiene 0 usos
    );

    // Hablamos con el Provider de PRENDAS
    Provider.of<PrendaProvider>(
      context,
      listen: false,
    ).agregarPrenda(nuevaPrenda);

    Navigator.pop(context); // Regresamos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Terno')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTextField(
                controller: _idCtrl,
                label: 'ID Único / Código',
                hint: 'Ej. TC-023',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nombreCtrl,
                label: 'Nombre de la prenda',
                hint: 'Ej. Terno Clásico Negro',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _tallaCtrl,
                label: 'Talla',
                hint: 'Ej. M, L, 42, 44',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _categoriaCtrl,
                label: 'Categoría',
                hint: 'Ej. Traje Clásico, Traje de Gala',
              ),
              const SizedBox(height: 16),
              // Dropdown para el Estado
              DropdownButtonFormField<PrendaEstado>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado Inicial',
                  border: OutlineInputBorder(),
                ),
                items: PrendaEstado.values.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado.texto), // Usa el helper del enum
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _estado = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Prenda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Requerido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
