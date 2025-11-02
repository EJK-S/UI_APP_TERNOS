import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NuevoAlquilerScreen extends StatefulWidget {
  const NuevoAlquilerScreen({super.key});

  @override
  State<NuevoAlquilerScreen> createState() => _NuevoAlquilerScreenState();
}

class _NuevoAlquilerScreenState extends State<NuevoAlquilerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteCtrl = TextEditingController();
  final TextEditingController _fechaDevolucionCtrl = TextEditingController();
  final TextEditingController _garantiaCtrl = TextEditingController();
  final TextEditingController _itemsCtrl = TextEditingController();
  bool _ok = false;

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
                      controller: _clienteCtrl,
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
                      controller: _fechaDevolucionCtrl,
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
                      controller: _garantiaCtrl,
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
                      controller: _itemsCtrl,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _ok = true;
                          });
                        }
                      },
                      child: const Text('Confirmar Alquiler'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_ok)
                    Text(
                      'Alquiler registrado exitosamente',
                      style: TextStyle(
                        color: AppColors.successLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
