import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class EditarPrendaScreen extends StatefulWidget {
  final Prenda prenda;
  const EditarPrendaScreen({super.key, required this.prenda});

  @override
  State<EditarPrendaScreen> createState() => _EditarPrendaScreenState();
}

class _EditarPrendaScreenState extends State<EditarPrendaScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  late TextEditingController _idCtrl;
  late TextEditingController _nombreCtrl;
  late TextEditingController _tallaCtrl;
  late TextEditingController _categoriaCtrl;
  late PrendaEstado _estado;

  @override
  void initState() {
    super.initState();
    // Pre-rellenamos los campos con los datos de la prenda
    _idCtrl = TextEditingController(text: widget.prenda.id);
    _nombreCtrl = TextEditingController(text: widget.prenda.nombre);
    _tallaCtrl = TextEditingController(text: widget.prenda.talla);
    _categoriaCtrl = TextEditingController(text: widget.prenda.categoria);
    _estado = widget.prenda.estado;
  }

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
      return;
    }

    // Creamos la Prenda actualizada
    final prendaActualizada = Prenda(
      id: _idCtrl
          .text, // El ID no debería ser editable, pero lo mantenemos simple
      nombre: _nombreCtrl.text,
      talla: _tallaCtrl.text,
      categoria: _categoriaCtrl.text,
      estado: _estado,
      usos: widget.prenda.usos, // Mantenemos los usos originales
    );

    // Hablamos con el Provider de PRENDAS
    Provider.of<PrendaProvider>(
      context,
      listen: false,
    ).editarPrenda(prendaActualizada);

    Navigator.pop(context); // Regresamos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Prenda')),
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
                // Hacemos el ID de solo lectura, no se debería cambiar
                isReadOnly: true,
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
                initialValue: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: PrendaEstado.values.map((estado) {
                  return DropdownMenuItem(
                    value: estado,
                    child: Text(estado.texto),
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
                child: const Text('Guardar Cambios'),
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
    bool isReadOnly = false,
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
          readOnly: isReadOnly,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            fillColor: isReadOnly
                ? AppColors.borderLight.withOpacity(0.3)
                : null,
            filled: isReadOnly,
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
