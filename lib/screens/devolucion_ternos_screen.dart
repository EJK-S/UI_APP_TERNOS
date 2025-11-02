import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DevolucionTernosScreen extends StatefulWidget {
  const DevolucionTernosScreen({super.key});

  @override
  State<DevolucionTernosScreen> createState() => _DevolucionTernosScreenState();
}

class _DevolucionTernosScreenState extends State<DevolucionTernosScreen> {
  final List<Map<String, dynamic>> _pendientes = [
    {
      'codigo': 'ALQ-0016',
      'cliente': 'María López',
      'pieza': 'Terno azul T40',
      'fechaLimite': '2025-10-29',
      'entregado': false,
      'daño': false,
    },
    {
      'codigo': 'ALQ-0015',
      'cliente': 'Juan Pérez',
      'pieza': 'Camisa blanca M',
      'fechaLimite': '2025-10-30',
      'entregado': false,
      'daño': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Devolución de Ternos')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _pendientes.length,
          itemBuilder: (context, index) {
            final p = _pendientes[index];
            return Container(
              margin: EdgeInsets.only(
                bottom: index == _pendientes.length - 1 ? 0 : 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['codigo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p['cliente']} • Limite: ${p['fechaLimite']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.subtleDark
                            : AppColors.subtleLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p['pieza'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: p['entregado'],
                                onChanged: (v) {
                                  setState(() {
                                    _pendientes[index]['entregado'] =
                                        v ?? false;
                                  });
                                },
                              ),
                              const Text('Devuelto'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(
                                value: p['daño'],
                                onChanged: (v) {
                                  setState(() {
                                    _pendientes[index]['daño'] = v ?? false;
                                  });
                                },
                              ),
                              const Text('Con daño'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Registrar Devolución'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
