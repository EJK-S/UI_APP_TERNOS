import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/providers/settings_provider.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';

class ConfiguracionSistemaScreen extends StatefulWidget {
  const ConfiguracionSistemaScreen({super.key});
  @override
  State<ConfiguracionSistemaScreen> createState() =>
      _ConfiguracionSistemaScreenState();
}

class _ConfiguracionSistemaScreenState
    extends State<ConfiguracionSistemaScreen> {
  // Controladores
  late TextEditingController _nombreNegocioCtrl;
  late TextEditingController _rucCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _tipoCambioCtrl;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializamos los controladores con los datos del Provider
    if (!_isInitialized) {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      _nombreNegocioCtrl = TextEditingController(text: settings.nombreNegocio);
      _rucCtrl = TextEditingController(text: settings.ruc);
      _telefonoCtrl = TextEditingController(text: settings.telefono);
      _tipoCambioCtrl = TextEditingController(text: settings.tipoCambio);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nombreNegocioCtrl.dispose();
    _rucCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
    _tipoCambioCtrl.dispose();
  }

  void _guardarCambios() {
    // Obtenemos el provider (sin escuchar)
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Llamamos a los métodos para guardar
    settings.setNombreNegocio(_nombreNegocioCtrl.text);
    settings.setRuc(_rucCtrl.text);
    settings.setTelefono(_telefonoCtrl.text);
    settings.setTipoCambio(_tipoCambioCtrl.text);

    // Mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider (escuchando) para el switch del tema
    final settings = Provider.of<SettingsProvider>(context);

    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Sistema')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // --- Tarjeta de Datos del Negocio ---
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

                  const SizedBox(height: 12),
                  TextField(
                    controller: _tipoCambioCtrl,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Cambio (USD a S/)',
                      hintText: 'Ej. 3.80',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Tarjeta de Preferencias de Interfaz ---
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
                    value: settings.isDarkMode, // <-- Lee del provider
                    onChanged: (v) {
                      // Llama al método del provider para cambiar el tema
                      settings.setDarkMode(v);
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

            // --- Botón de Guardar ---
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
                onPressed: _guardarCambios, // <-- Llama a la función de guardar
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 3), // Índice 3
    );
  }
}
