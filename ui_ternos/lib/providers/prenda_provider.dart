// lib/providers/prenda_provider.dart (VERSIÓN COMPLETA Y CORRECTA)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/prenda_repository.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';

class PrendaProvider extends ChangeNotifier {
  // 1. DEPENDENCIA
  final PrendaRepository _repository;

  // 2. ESTADO
  List<Prenda> _prendas = [];
  bool _isLoading = false;

  // 3. GETTERS
  List<Prenda> get prendas => _prendas;
  bool get isLoading => _isLoading;

  // --- CORRECCIÓN 1: EL CONSTRUCTOR NO DEBE LLAMAR A fetchPrendas() ---
  // La llamada se hace desde main.dart
  PrendaProvider(this._repository);

  // --- CORRECCIÓN 2: IMPLEMENTACIÓN COMPLETA DE LOS MÉTODOS ---

  Future<void> fetchPrendas() async {
    // 'Guardia' para evitar cargas múltiples si ya se llamó
    if (_prendas.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    // (Tu 'List.from' ya era correcto para evitar duplicados)
    _prendas = List.from(await _repository.getPrendas());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarPrenda(Prenda nuevaPrenda) async {
    final prendaAgregada = await _repository.agregarPrenda(nuevaPrenda);
    _prendas.add(prendaAgregada);
    notifyListeners(); // Avisa al InventarioProvider y a las pantallas
  }

  Future<void> editarPrenda(Prenda prendaActualizada) async {
    final prendaEditada = await _repository.editarPrenda(prendaActualizada);
    final index = _prendas.indexWhere((p) => p.id == prendaEditada.id);
    if (index != -1) {
      _prendas[index] = prendaEditada;
      notifyListeners(); // Avisa al InventarioProvider y a las pantallas
    }
  }

  Future<void> eliminarPrenda(String id) async {
    await _repository.eliminarPrenda(id);
    _prendas.removeWhere((p) => p.id == id);
    notifyListeners(); // Avisa al InventarioProvider y a las pantallas
  }

  // (Tus métodos de cálculo síncronos ya eran correctos)
  int contarPorCategoriaYEstado(String categoria, PrendaEstado estado) {
    final categoriaTrimmed = categoria.trim();
    return _prendas
        .where(
          (p) => p.categoria.trim() == categoriaTrimmed && p.estado == estado,
        )
        .length;
  }

  List<Prenda> getPrendasPorCategoria(String categoria) {
    final categoriaTrimmed = categoria.trim();
    return _prendas
        .where((p) => p.categoria.trim() == categoriaTrimmed)
        .toList();
  }
}
