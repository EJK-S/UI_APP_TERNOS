// lib/screens/nuevo_alquiler_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORTAMOS PROVIDER
import 'package:proyecto_tienda_ternos/models/alquiler.dart'; // <-- 2. IMPORTAMOS EL MODELO
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart'; // <-- 3. IMPORTAMOS EL CEREBRO
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class NuevoAlquilerScreen extends StatefulWidget {
  const NuevoAlquilerScreen({super.key});

  @override
  State<NuevoAlquilerScreen> createState() => _NuevoAlquilerScreenState();
}

class _NuevoAlquilerScreenState extends State<NuevoAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controladores para capturar el texto de los campos
  final TextEditingController _clienteCtrl = TextEditingController();
  final TextEditingController _fechaDevolucionCtrl = TextEditingController();
  final TextEditingController _garantiaCtrl = TextEditingController();
  final TextEditingController _itemsCtrl = TextEditingController();

  // bool _ok = false; // <-- 4. YA NO NECESITAMOS ESTO

  void _submitForm() {
    // 5. Validamos el formulario
    if (_formKey.currentState!.validate()) {
      // 6. Creamos el nuevo objeto Alquiler con los datos del formulario
      final nuevoAlquiler = Alquiler(
        codigo:
            'ALQ-${DateTime.now().millisecondsSinceEpoch}', // Un ID temporal
        cliente: _clienteCtrl.text,
        producto: _itemsCtrl.text, // Usamos el campo "prendas" como "producto"
        fechaInicio: '2025-11-03', // Deberías añadir un campo para esto
        fechaDevolucion: _fechaDevolucionCtrl.text,
        estado: AlquilerEstado.activo, // Por defecto es "activo"
      );

      // 7. HABLAMOS CON EL CEREBRO
      // Usamos Provider.of para obtener la instancia del provider
      // listen: false es CRUCIAL aquí. Significa "solo quiero llamar un método,
      // no me quiero suscribir a los cambios".
      Provider.of<AlquilerProvider>(
        context,
        listen: false,
      ).agregarAlquiler(nuevoAlquiler);

      // 8. REGRESAMOS A LA PANTALLA ANTERIOR
      // (La lista de alquileres se actualizará sola)
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Limpiamos los controladores
    _clienteCtrl.dispose();
    _fechaDevolucionCtrl.dispose();
    _garantiaCtrl.dispose();
    _itemsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Alquiler')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _FieldBlock(
                    label: 'Cliente',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _clienteCtrl, // <-- Conectado
                      decoration: const InputDecoration(
                        hintText: 'Seleccionar / ingresar cliente',
                        prefixIcon: Icon(Icons.person_search),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldBlock(
                    label: 'Fecha de devolución',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _fechaDevolucionCtrl, // <-- Conectado
                      decoration: const InputDecoration(
                        hintText: 'AAAA-MM-DD',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldBlock(
                    label: 'Garantía (S/)',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _garantiaCtrl, // <-- Conectado
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Monto en garantía',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(v) == null) {
                          return 'Monto inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldBlock(
                    label: 'Prendas alquiladas',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _itemsCtrl, // <-- Conectado
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Ej. Terno negro T42, camisa blanca M...',
                        prefixIcon: Icon(Icons.checklist),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // 9. Conectamos el botón a nuestra nueva función
                      onPressed: _submitForm,
                      child: const Text('Confirmar Alquiler'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 10. YA NO NECESITAMOS MOSTRAR EL MENSAJE DE ÉXITO
                  // if (_ok) ...
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NINGÚN CAMBIO DE AQUÍ PARA ABAJO ---
// (El widget _FieldBlock sigue exactamente igual)

class _FieldBlock extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final Widget child;
  const _FieldBlock({
    required this.label,
    required this.child,
    this.requiredMark = false,
  });
  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.stone700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: labelStyle,
            children: [
              TextSpan(text: label),
              if (requiredMark)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
