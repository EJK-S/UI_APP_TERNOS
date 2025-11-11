import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GenerarReportesScreen extends StatefulWidget {
  const GenerarReportesScreen({super.key});

  @override
  State<GenerarReportesScreen> createState() => _GenerarReportesScreenState();
}

class _GenerarReportesScreenState extends State<GenerarReportesScreen> {
  final _formKey = GlobalKey<FormState>();
  String _tipo = 'Ventas';
  final TextEditingController _desdeCtrl = TextEditingController();
  final TextEditingController _hastaCtrl = TextEditingController();
  bool _listo = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tipo de Reporte',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _tipo,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Ventas',
                          child: Text('Ventas'),
                        ),
                        DropdownMenuItem(
                          value: 'Alquileres',
                          child: Text('Alquileres'),
                        ),
                        DropdownMenuItem(
                          value: 'Inventario',
                          child: Text('Inventario'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _tipo = v;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rango de Fechas',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _desdeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Desde (AAAA-MM-DD)',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _hastaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Hasta (AAAA-MM-DD)',
                        prefixIcon: Icon(Icons.date_range),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Requerido';
                        }
                        return null;
                      },
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
                              _listo = true;
                            });
                          }
                        },
                        child: const Text('Generar Reporte'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_listo)
                      Text(
                        'Reporte generado',
                        style: TextStyle(
                          color: AppColors.successLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Resultados',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                _listo
                    ? 'Aquí mostrarías métricas y tabla detallada del reporte de $_tipo.'
                    : 'No hay datos aún. Genera un reporte.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
