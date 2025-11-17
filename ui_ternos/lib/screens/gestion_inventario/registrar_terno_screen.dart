// lib/screens/gestion_inventario/registrar_terno_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';
import 'package:proyecto_tienda_ternos/providers/prenda_provider.dart';
// 1. IMPORTAR EL INVENTARIO PROVIDER
import 'package:proyecto_tienda_ternos/providers/inventario_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class RegistrarTernoScreen extends StatefulWidget {
  final String? categoriaPreseleccionada;

  const RegistrarTernoScreen({super.key, this.categoriaPreseleccionada});
  @override
  State<RegistrarTernoScreen> createState() => _RegistrarTernoScreenState();
}

class _RegistrarTernoScreenState extends State<RegistrarTernoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreCtrl = TextEditingController();
  final _tallaCtrl = TextEditingController();
  // final _categoriaCtrl = TextEditingController(); // <-- 2. ELIMINADO

  // 3. AÑADIR NUEVAS VARIABLES DE ESTADO
  String? _selectedCategoria; // Para el dropdown
  PrendaEstado _estado = PrendaEstado.Disponible;
  bool _isSaving = false;
  bool _mantenerEnPantalla = false;

  @override
  void initState() {
    super.initState();
    // --- 3. PRE-SELECCIONAR LA CATEGORÍA SI SE PASÓ ---
    if (widget.categoriaPreseleccionada != null) {
      _selectedCategoria = widget.categoriaPreseleccionada;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _tallaCtrl.dispose();
    // _categoriaCtrl.dispose(); // <-- ELIMINADO
    super.dispose();
  }

  // 4. CORREGIR _submitForm
  Future<void> _submitForm() async {
    if (_selectedCategoria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione una categoría.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // --- ¡AQUÍ ESTÁ LA CORRECCIÓN! ---
      // 1. Genera un ID único basado en la hora actual
      final String nuevoId = 'P-${DateTime.now().millisecondsSinceEpoch}';

      // 2. Crea la nueva prenda
      final nuevaPrenda = Prenda(
        id: nuevoId, // <-- Usa el ID autogenerado
        nombre: _nombreCtrl.text.trim(),
        talla: _tallaCtrl.text.trim(),
        categoria: _selectedCategoria!,
        estado: _estado,
        usos: 0,
      );

      await context.read<PrendaProvider>().agregarPrenda(nuevaPrenda);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prenda ${nuevaPrenda.id} guardada con éxito.'),
            backgroundColor: Colors.green,
          ),
        );

        if (_mantenerEnPantalla) {
          // Limpia los campos (¡pero ya no necesitamos limpiar _idCtrl!)
          setState(() {
            _tallaCtrl.clear();
            // Mantenemos el nombre y la categoría
          });
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. OBTENER LA LISTA DE CATEGORÍAS
    final categorias = context
        .watch<InventarioProvider>()
        .categorias
        .map((cat) => cat.nombre)
        .toList();

    if (widget.categoriaPreseleccionada != null &&
        !categorias.contains(widget.categoriaPreseleccionada!)) {
      categorias.add(widget.categoriaPreseleccionada!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Nuevo Terno')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
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

              // 6. REEMPLAZAR TEXTFIELD CON DROPDOWN
              DropdownButtonFormField<PrendaEstado>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado Inicial',
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

              // --- 6. CHECKBOX PARA PROBLEMA #2 ---
              CheckboxListTile(
                title: const Text('Añadir otro terno de este modelo'),
                subtitle: const Text(
                  'Mantiene la pantalla abierta y guarda el nombre/categoría.',
                ),
                value: _mantenerEnPantalla,
                onChanged: (value) {
                  setState(() {
                    _mantenerEnPantalla = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Guardar Prenda'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Helper _buildTextField - sin cambios)
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

  // 8. AÑADIR HELPER DE DROPDOWN (copiado de nueva_venta)
  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?>? onChanged, // <-- Acepta nulo
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
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint),
          // --- LÓGICA DE UI DESHABILITADA ---
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            // Color gris si está deshabilitado
            filled: onChanged == null,
            fillColor: onChanged == null ? Colors.grey.shade100 : null,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged, // <-- Pasa el onChanged (que puede ser nulo)
          validator: (value) => value == null ? 'Campo requerido' : null,
        ),
      ],
    );
  }

  Widget _buildEstadoDropdown({
    required String label,
    required PrendaEstado value,
    required ValueChanged<PrendaEstado?> onChanged,
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
        DropdownButtonFormField<PrendaEstado>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: PrendaEstado.values.map((estado) {
            return DropdownMenuItem(value: estado, child: Text(estado.texto));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
