import 'package:flutter/material.dart';
import 'theme.dart';

class NuevoClienteScreen extends StatefulWidget {
  const NuevoClienteScreen({super.key});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _telCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _notasCtrl = TextEditingController();
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Nuevo Cliente'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _LabeledField(
                    label: 'Nombre completo',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ingresar nombre completo',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'DNI',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _dniCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Ingresar DNI',
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Este campo es obligatorio.';
                        if (v.length != 8 || int.tryParse(v) == null) {
                          return 'El DNI debe tener 8 dígitos.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Teléfono',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _telCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Ingresar teléfono',
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Este campo es obligatorio.';
                        if (v.length != 9 || int.tryParse(v) == null) {
                          return 'El teléfono debe tener 9 dígitos.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Correo (opcional)',
                    child: TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Ingresar correo',
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return null;
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(v)) {
                          return 'Formato de correo inválido.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _LabeledField(
                    label: 'Notas (opcional)',
                    child: TextFormField(
                      controller: _notasCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ingresar notas',
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
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
                                _success = true;
                              });
                            }
                          },
                          child: const Text('Guardar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).maybePop();
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_success)
                    Text(
                      'Cliente registrado correctamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.successLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final Widget child;
  const _LabeledField({
    required this.label,
    this.requiredMark = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.stone700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: baseStyle,
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
