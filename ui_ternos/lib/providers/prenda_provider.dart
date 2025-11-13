// lib/providers/prenda_provider.dart

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

  // 4. CONSTRUCTOR
  PrendaProvider(this._repository) {
    fetchPrendas();
  }

  // 5. MÉTODOS (ASÍNCRONOS)

  Future<void> fetchPrendas() async {
    _isLoading = true;
    notifyListeners();
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

  // --- MÉTODOS DE CÁLCULO (SÍNCRONOS) ---
  // Estos métodos leen el ESTADO LOCAL (_prendas), no la base de datos.
  // El InventarioProvider depende de ellos.

  int contarPorCategoriaYEstado(String categoria, PrendaEstado estado) {
    return _prendas
        .where((p) => p.categoria == categoria && p.estado == estado)
        .length;
  }

  List<Prenda> getPrendasPorCategoria(String categoria) {
    return _prendas.where((p) => p.categoria == categoria).toList();
  }
}
