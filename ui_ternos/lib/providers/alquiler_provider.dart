// lib/providers/alquiler_provider.dart

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/alquiler_repository.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';

class AlquilerProvider extends ChangeNotifier {
  // 1. DEPENDENCIA
  final AlquilerRepository _repository;

  // 2. ESTADO
  List<Alquiler> _alquileres = [];
  bool _isLoading = false;

  // 3. GETTERS
  List<Alquiler> get alquileres => _alquileres;
  bool get isLoading => _isLoading;

  // 4. CONSTRUCTOR
  AlquilerProvider(this._repository) {
    fetchAlquileres();
  }

  // 5. MÉTODOS

  Future<void> fetchAlquileres() async {
    _isLoading = true;
    notifyListeners();
    _alquileres = await _repository.getAlquileres();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarAlquiler(Alquiler nuevoAlquiler) async {
    final alquilerAgregado = await _repository.agregarAlquiler(nuevoAlquiler);
    _alquileres.add(alquilerAgregado);
    notifyListeners();
  }

  Future<void> registrarDevolucion(
    Alquiler alquilerDevuelto,
    String observaciones,
    bool garantiaRetenida,
  ) async {
    final alquilerActualizado = await _repository.registrarDevolucion(
      alquilerDevuelto.codigo,
      observaciones,
      garantiaRetenida,
    );

    // Actualiza el estado local
    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerActualizado.codigo,
    );
    if (index != -1) {
      _alquileres[index] = alquilerActualizado;
      notifyListeners();
    }
  }

  Future<void> prolongarAlquiler(
    Alquiler alquiler,
    String nuevaFechaDevolucion,
    double montoAdicional,
  ) async {
    final alquilerActualizado = await _repository.prolongarAlquiler(
      alquiler.codigo,
      nuevaFechaDevolucion,
      montoAdicional,
    );

    // Actualiza el estado local
    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerActualizado.codigo,
    );
    if (index != -1) {
      _alquileres[index] = alquilerActualizado;
      notifyListeners();
    }
  }
}
