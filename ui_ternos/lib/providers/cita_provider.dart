// lib/providers/cita_provider.dart (VERSIÓN COMPLETA Y CORRECTA)

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

  // --- CORRECCIÓN 1: EL CONSTRUCTOR NO DEBE LLAMAR A fetchCitas() ---
  // La llamada se hace desde main.dart
  CitaProvider(this._repository);

  // --- CORRECCIÓN 2: IMPLEMENTACIÓN COMPLETA DE LOS MÉTODOS ---

  Future<void> fetchCitas() async {
    // 'Guardia' para evitar cargas múltiples si ya se llamó
    if (_citas.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    // (Tu 'List.from' ya era correcto para evitar duplicados)
    _citas = List.from(await _repository.getCitas());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarCita(Cita nuevaCita) async {
    final citaAgregada = await _repository.agregarCita(nuevaCita);
    _citas.add(citaAgregada);
    notifyListeners();
  }

  // (Tus métodos de 'marcarComoCompletada', 'cancelarCita' y 'editarCita'
  // ya eran correctos y usaban 'id')

  Future<void> marcarComoCompletada(Cita cita) async {
    final citaActualizada = await _repository.marcarComoCompletada(cita.id!);

    final index = _citas.indexWhere((c) => c.id == citaActualizada.id);
    if (index != -1) {
      _citas[index] = citaActualizada;
      notifyListeners();
    }
  }

  Future<void> cancelarCita(Cita cita) async {
    final citaActualizada = await _repository.cancelarCita(cita.id!);

    final index = _citas.indexWhere((c) => c.id == citaActualizada.id);
    if (index != -1) {
      _citas[index] = citaActualizada;
      notifyListeners();
    }
  }

  Future<void> editarCita(Cita citaActualizada) async {
    final citaEditada = await _repository.editarCita(citaActualizada);

    final index = _citas.indexWhere((c) => c.id == citaEditada.id);
    if (index != -1) {
      _citas[index] = citaEditada;
      notifyListeners();
    }
  }
}
