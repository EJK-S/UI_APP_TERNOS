import 'package:flutter/foundation.dart';
import '../models/cliente.dart';
import '../services/api_service.dart';

class ClienteProvider extends ChangeNotifier {
  final List<Cliente> _clientes = [];
  bool _cargando = false;
  String? _error;

  List<Cliente> get clientes => List.unmodifiable(_clientes);
  bool get cargando => _cargando;
  String? get error => _error;

  // Mapear desde/ hacia API
  Cliente _fromApi(Map<String, dynamic> m) => Cliente.fromJson(m);

  Future<void> cargarClientes() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final list = await ApiService.listarClientes();
      _clientes
        ..clear()
        ..addAll(list.map(_fromApi));
    } catch (e) {
      _error = 'No se pudo cargar clientes: $e';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> agregarCliente(Cliente nuevo) async {
    _error = null;
    try {
      final saved = await ApiService.crearCliente(nuevo.toJson()); // sin id
      // si el backend devolvió el creado con id, úsalo; si no, inserta con lo que haya
      final c = saved.isNotEmpty ? _fromApi(saved) : nuevo;
      _clientes.add(c);
      notifyListeners();
    } catch (e) {
      _error = 'No se pudo crear el cliente: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> actualizarCliente(Cliente editado) async {
    if (editado.id == null) throw Exception('Cliente sin id');
    _error = null;
    try {
      // sin 'id' en el body
      final updated = await ApiService.actualizarCliente(
        editado.id!,
        editado.toJson(),
      );
      final idx = _clientes.indexWhere((x) => x.id == editado.id);
      if (idx != -1) {
        // si el backend no devolvió cuerpo (204), actualiza con lo que editaste
        _clientes[idx] = updated != null ? _fromApi(updated) : editado;
      }
      notifyListeners();
    } catch (e) {
      _error = 'No se pudo actualizar el cliente: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminarCliente(Cliente c) async {
    if (c.id == null) throw Exception('Cliente sin id');
    _error = null;
    try {
      await ApiService.eliminarCliente(c.id!);
      _clientes.removeWhere((x) => x.id == c.id);
      notifyListeners();
    } catch (e) {
      _error = 'No se pudo eliminar el cliente: $e';
      notifyListeners();
      rethrow;
    }
  }
}
