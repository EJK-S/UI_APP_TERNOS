import 'package:flutter/foundation.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/services/api_service.dart';

class CitaProvider extends ChangeNotifier {
  final ApiService _api;
  CitaProvider({ApiService? api}) : _api = api ?? ApiService() {
    cargarCitas();
  }

  final List<Cita> _citas = [];
  bool _isLoading = false;
  String? _error;

  List<Cita> get citas => List.unmodifiable(_citas);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ============================
  //      CARGAR CITAS
  // ============================
  Future<void> cargarCitas() async {
    _error = null;
    _setLoading(true);

    try {
      final data = await _api.getCitas(); // GET /api/citas
      _citas
        ..clear()
        ..addAll(
          data.map<Cita>((json) => Cita.fromJson(json as Map<String, dynamic>)),
        );

      if (kDebugMode) {
        print('📥 Citas cargadas: ${_citas.length}');
      }

      notifyListeners();
    } catch (e, st) {
      _error = 'Error cargando citas: $e';
      _citas.clear();
      if (kDebugMode) {
        print('❌ Error en cargarCitas: $e');
        print(st);
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // ============================
  //      CREAR CITA
  // ============================
  Future<bool> agregarCita(Cita cita) async {
    try {
      final res = await _api.createCita({
        'clienteId': cita.clienteId.toString(),
        'fechaHora': cita.fechaHora.toIso8601String(),
        'proposito': cita.proposito.apiValue, // del modelo Cita
        'notas': cita.notas,
      });

      final nueva = Cita.fromJson(res as Map<String, dynamic>);
      _citas.add(nueva);
      notifyListeners();
      return true;
    } catch (e, st) {
      _error = 'Error creando cita: $e';
      if (kDebugMode) {
        print('❌ Error en agregarCita: $e');
        print(st);
      }
      notifyListeners();
      return false;
    }
  }

  // ============================
  //    CAMBIAR ESTADO CITA
  // ============================
  Future<bool> cambiarEstado(Cita cita, CitaEstado nuevoEstado) async {
    if (cita.id == null) return false;

    try {
      final res = await _api.updateEstadoCita(
        cita.id!.toString(),
        nuevoEstado.apiValue,
      );

      final actualizada = Cita.fromJson(res as Map<String, dynamic>);
      final index = _citas.indexWhere((c) => c.id == actualizada.id);
      if (index != -1) {
        _citas[index] = actualizada;
        notifyListeners();
      }

      return true;
    } catch (e, st) {
      _error = 'Error actualizando estado de cita: $e';
      if (kDebugMode) {
        print('❌ Error en cambiarEstado: $e');
        print(st);
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> marcarComoCompletada(Cita cita) =>
      cambiarEstado(cita, CitaEstado.Completada);

  Future<bool> cancelarCita(Cita cita) =>
      cambiarEstado(cita, CitaEstado.Cancelada);

  // ============================
  //        EDITAR CITA
  // ============================
  Future<bool> editarCita(Cita cita) async {
    if (cita.id == null) return false;

    try {
      final res = await _api.updateCita(cita.id!.toString(), {
        'fechaHora': cita.fechaHora.toIso8601String(),
        'proposito': cita.proposito.apiValue,
        'notas': cita.notas,
      });

      final editada = Cita.fromJson(res as Map<String, dynamic>);
      final index = _citas.indexWhere((c) => c.id == editada.id);

      if (index != -1) {
        _citas[index] = editada;
        notifyListeners();
      }

      return true;
    } catch (e, st) {
      _error = 'Error editando cita: $e';
      if (kDebugMode) {
        print('❌ Error en editarCita: $e');
        print(st);
      }
      notifyListeners();
      return false;
    }
  }

  // ============================
  //       ELIMINAR CITA
  // ============================
  Future<bool> eliminarCita(Cita cita) async {
    if (cita.id == null) return false;

    try {
      final ok = await _api.deleteCita(cita.id!.toString());
      if (ok) {
        _citas.removeWhere((c) => c.id == cita.id);
        notifyListeners();
      }
      return ok;
    } catch (e, st) {
      _error = 'Error eliminando cita: $e';
      if (kDebugMode) {
        print('❌ Error en eliminarCita: $e');
        print(st);
      }
      notifyListeners();
      return false;
    }
  }
}
