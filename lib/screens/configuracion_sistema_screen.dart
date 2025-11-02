import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import '../theme/app_theme.dart';

class ConfiguracionSistemaScreen extends StatefulWidget {
  const ConfiguracionSistemaScreen({super.key});

  @override
  State<ConfiguracionSistemaScreen> createState() =>
      _ConfiguracionSistemaScreenState();
}

class _ConfiguracionSistemaScreenState
    extends State<ConfiguracionSistemaScreen> {
  final TextEditingController _nombreNegocioCtrl = TextEditingController(
    text: 'Mi Tienda de Ternos',
  );
  final TextEditingController _rucCtrl = TextEditingController(
    text: '00000000000',
  );
  final TextEditingController _telefonoCtrl = TextEditingController(
    text: '987654321',
  );
  bool _darkMode = false;
  bool _mensajeOk = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Sistema')),
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
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Datos del Negocio',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nombreNegocioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Comercial',
                      prefixIcon: Icon(Icons.store),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _rucCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RUC',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.call),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Preferencias de Interfaz',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _darkMode,
                    onChanged: (v) {
                      setState(() {
                        _darkMode = v;
                      });
                    },
                    title: const Text(
                      'Modo oscuro',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Usar fondo oscuro y texto claro',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.subtleDark
                            : AppColors.subtleLight,
                      ),
                    ),
                  ),
                ],
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
                  setState(() {
                    _mensajeOk = true;
                  });
                },
                child: const Text('Guardar Cambios'),
              ),
            ),
            const SizedBox(height: 12),
            if (_mensajeOk)
              Text(
                'Configuración guardada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.successLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 2),
    );
  }
}
