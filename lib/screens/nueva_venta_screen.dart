import 'package:flutter/material.dart';
import 'theme.dart';

class NuevaVentaScreen extends StatefulWidget {
  const NuevaVentaScreen({super.key});

  @override
  State<NuevaVentaScreen> createState() => _NuevaVentaScreenState();
}

class _NuevaVentaScreenState extends State<NuevaVentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clienteCtrl = TextEditingController(text: 'Mostrador');
  final TextEditingController _itemsCtrl = TextEditingController();
  final TextEditingController _totalCtrl = TextEditingController();
  bool _ok = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _Block(
                    label: 'Cliente (opcional)',
                    child: TextFormField(
                      controller: _clienteCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Nombre Cliente / Mostrador',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Block(
                    label: 'Ítems vendidos',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _itemsCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ej. Camisa blanca M x2, Corbata azul x1...',
                        prefixIcon: Icon(Icons.shopping_bag),
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
                  _Block(
                    label: 'Total (S/)',
                    requiredMark: true,
                    child: TextFormField(
                      controller: _totalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
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
                      child: const Text('Registrar Venta'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_ok)
                    Text(
                      'Venta registrado exitosamente',
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

class _Block extends StatelessWidget {
  final String label;
  final bool requiredMark;
  final Widget child;
  const _Block({
    required this.label,
    required this.child,
    this.requiredMark = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.stone700,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: style,
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
