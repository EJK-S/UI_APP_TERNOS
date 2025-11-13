// lib/providers/cita_provider.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/cita_repository.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';

class CitaProvider extends ChangeNotifier {
  // 1. DEPENDENCIA
  final CitaRepository _repository;

  // 2. ESTADO
  List<Cita> _citas = [];
  bool _isLoading = false;

  // 3. GETTERS
  List<Cita> get citas => _citas;
  bool get isLoading => _isLoading;

  // 4. CONSTRUCTOR
  CitaProvider(this._repository) {
    fetchCitas();
  }

  // 5. MÉTODOS

  Future<void> fetchCitas() async {
    _isLoading = true;
    notifyListeners();
    _citas = List.from(await _repository.getCitas());
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarCita(Cita nuevaCita) async {
    final citaAgregada = await _repository.agregarCita(nuevaCita);
    _citas.add(citaAgregada);
    notifyListeners();
  }

  // --- MÉTODOS CORREGIDOS (USAN 'id' numérico) ---

  Future<void> marcarComoCompletada(Cita cita) async {
    // Usamos 'cita.id'. El '!' es seguro porque una cita que
    // se marca como completada DEBE tener un id.
    final citaActualizada = await _repository.marcarComoCompletada(cita.id!);

    // Actualiza el estado local
    final index = _citas.indexWhere(
      (c) => c.id == citaActualizada.id, // <-- Compara por 'id'
    );
    if (index != -1) {
      _citas[index] = citaActualizada;
      notifyListeners();
    }
  }

  Future<void> cancelarCita(Cita cita) async {
    final citaActualizada = await _repository.cancelarCita(cita.id!);

    // Actualiza el estado local
    final index = _citas.indexWhere(
      (c) => c.id == citaActualizada.id, // <-- Compara por 'id'
    );
    if (index != -1) {
      _citas[index] = citaActualizada;
      notifyListeners();
    }
  }

  Future<void> editarCita(Cita citaActualizada) async {
    final citaEditada = await _repository.editarCita(citaActualizada);

    // Actualiza el estado local
    final index = _citas.indexWhere(
      (c) => c.id == citaEditada.id, // <-- Compara por 'id'
    );
    if (index != -1) {
      _citas[index] = citaEditada;
      notifyListeners();
    }
  }
}
