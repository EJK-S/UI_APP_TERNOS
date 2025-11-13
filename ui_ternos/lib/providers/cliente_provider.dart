import 'package:flutter/foundation.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/services/api_service.dart';

class ClienteProvider extends ChangeNotifier {
  final ApiService _api;
  ClienteProvider({ApiService? api}) : _api = api ?? ApiService();

  final List<Cliente> _clientes = [];
  bool _isLoading = false;
  String _search = '';
  String? _error;

  List<Cliente> get clientes => List.unmodifiable(_clientes);
  bool get isLoading => _isLoading;
  String get search => _search;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // =======================
  //   CARGAR LISTA
  // =======================
  Future<void> cargarClientes({String? search}) async {
    if (search != null) {
      _search = search.trim();
    }

    _error = null;
    _setLoading(true);

    try {
      final data = await _api.getClientes(
        search: _search.isEmpty ? null : _search,
      );

      _clientes
        ..clear()
        ..addAll(
          data.map<Cliente>(
            (json) => Cliente.fromJson(json as Map<String, dynamic>),
          ),
        );

      if (kDebugMode) {
        print(
          '📥 Clientes cargados (${_search.isEmpty ? "sin filtro" : "filtro=$_search"}): ${_clientes.length}',
        );
      }

      notifyListeners();
    } catch (e, st) {
      _error = 'No se pudo cargar clientes: $e';
      if (kDebugMode) {
        print('❌ Error en cargarClientes: $e');
        print(st);
      }
      _clientes.clear();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // =======================
  //   ELIMINAR
  // =======================
  Future<bool> eliminarCliente(String id) async {
    try {
      final ok = await _api.deleteCliente(id);
      if (ok) {
        _clientes.removeWhere((c) => '${c.id}' == id);
        notifyListeners();
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  // =======================
  //   VETO (usando PUT /clientes/:id)
  // =======================
  Future<bool> actualizarVeto(Cliente c, bool vetado, String motivo) async {
    if (c.id == null) return false;

    try {
      // Partimos del cliente actual completo
      final data = c.toJson();

      // Sobrescribimos solo lo relacionado al veto
      data['vetado'] = vetado;
      data['motivo_veto'] = vetado ? motivo : null;

      // Llamamos al mismo endpoint que usa EditarClienteScreen
      final res = await _api.updateCliente('${c.id}', data);
      if (res == null) return false;

      // Parseamos la respuesta del backend
      final actualizado = Cliente.fromJson(res['data'] ?? res);

      // Actualizamos la lista en memoria
      final idx = _clientes.indexWhere((x) => x.id == c.id);
      if (idx != -1) {
        _clientes[idx] = actualizado;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = 'No se pudo actualizar el veto: $e';
      notifyListeners();
      return false;
    }
  }

  // =======================
  //   CREAR
  // =======================
  Future<bool> agregarCliente(Map<String, dynamic> data) async {
    try {
      final res = await _api.createCliente(data);
      if (res != null) {
        final nuevo = Cliente.fromJson(res['data'] ?? res);
        _clientes.add(nuevo);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'No se pudo crear el cliente: $e';
      notifyListeners();
      return false;
    }
  }

  // =======================
  //   ACTUALIZAR
  // =======================
  Future<bool> actualizarCliente(Map<String, dynamic> data) async {
    try {
      final id = data['id']?.toString();
      if (id == null) return false;

      final res = await _api.updateCliente(id, data);
      if (res != null) {
        final actualizado = Cliente.fromJson(res['data'] ?? res);
        final i = _clientes.indexWhere((c) => '${c.id}' == id);
        if (i != -1) _clientes[i] = actualizado;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'No se pudo actualizar el cliente: $e';
      notifyListeners();
      return false;
    }
  }
}
