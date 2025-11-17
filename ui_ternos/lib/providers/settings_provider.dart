import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // --- Propiedades con valores por defecto ---
  bool _isDarkMode = false;
  String _nombreNegocio = 'Mi Tienda de Ternos';
  String _ruc = '00000000000';
  String _telefono = '987654321';
  String _tipoCambio = '3.80';

  // --- Getters (para que la UI pueda leer los datos) ---
  bool get isDarkMode => _isDarkMode;
  String get nombreNegocio => _nombreNegocio;
  String get ruc => _ruc;
  String get telefono => _telefono;
  String get tipoCambio => _tipoCambio;

  // Constructor
  SettingsProvider() {
    _loadSettings(); // Carga las preferencias guardadas cuando la app inicia
  }

  // --- Cargar datos del teléfono ---
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    _nombreNegocio =
        _prefs?.getString('nombreNegocio') ?? 'Mi Tienda de Ternos';
    _ruc = _prefs?.getString('ruc') ?? '00000000000';
    _telefono = _prefs?.getString('telefono') ?? '987654321';
    _tipoCambio = _prefs?.getString('tipoCambio') ?? '3.80';

    // Notifica a la app que los ajustes se cargaron
    notifyListeners();
  }

  // --- Métodos para cambiar los ajustes ---

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs?.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setNombreNegocio(String value) async {
    _nombreNegocio = value;
    await _prefs?.setString('nombreNegocio', value);
    notifyListeners();
  }

  Future<void> setRuc(String value) async {
    _ruc = value;
    await _prefs?.setString('ruc', value);
    notifyListeners();
  }

  Future<void> setTelefono(String value) async {
    _telefono = value;
    await _prefs?.setString('telefono', value);
    notifyListeners();
  }

  Future<void> setTipoCambio(String value) async {
    _tipoCambio = value;
    await _prefs?.setString('tipoCambio', value);
    notifyListeners();
  }
}
