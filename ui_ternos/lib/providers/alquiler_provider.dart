// lib/providers/alquiler_provider.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/alquiler_repository.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/pieza_item.dart'; // <-- Import del paso anterior

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
    _alquileres = List.from(await _repository.getAlquileres());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarAlquiler(Alquiler nuevoAlquiler) async {
    final alquilerAgregado = await _repository.agregarAlquiler(nuevoAlquiler);
    _alquileres.add(alquilerAgregado);
    notifyListeners();
  }

  // (Este es el método de devolución detallada que añadimos antes)
  Future<void> registrarDevolucionDetallada({
    required Alquiler alquiler,
    required List<PiezaItem> piezasDevueltas,
    required String observaciones,
    required bool garantiaRetenida,
  }) async {
    final alquilerActualizado = await _repository.registrarDevolucionDetallada(
      alquilerCodigo: alquiler.codigo,
      piezasDevueltas: piezasDevueltas,
      observaciones: observaciones,
      garantiaRetenida: garantiaRetenida,
    );

    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerActualizado.codigo,
    );
    if (index != -1) {
      _alquileres[index] = alquilerActualizado;
      notifyListeners();
    }
  }

  // --- MÉTODO CORREGIDO (AHORA ACEPTA DATETIME) ---
  Future<void> prolongarAlquiler({
    required Alquiler alquiler,
    required DateTime
    nuevaFechaDevolucion, // <-- CAMBIO: De 'String' a 'DateTime'
    required double montoAdicional,
  }) async {
    final alquilerActualizado = await _repository.prolongarAlquiler(
      codigo: alquiler.codigo,
      nuevaFechaDevolucion: nuevaFechaDevolucion, // <-- Pasa el DateTime
      montoAdicional: montoAdicional,
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
