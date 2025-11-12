// lib/providers/venta_provider.dart

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/venta_repository.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';

class VentaProvider extends ChangeNotifier {
  // 1. DEPENDENCIA
  final VentaRepository _repository;

  // 2. ESTADO
  List<Venta> _ventas = [];
  bool _isLoading = false;

  // 3. GETTERS
  List<Venta> get ventas => _ventas;
  bool get isLoading => _isLoading;

  // 4. CONSTRUCTOR
  VentaProvider(this._repository) {
    fetchVentas();
  }

  // 5. MÉTODOS

  Future<void> fetchVentas() async {
    _isLoading = true;
    notifyListeners();

    _ventas = await _repository.getVentas();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarVenta(Venta nuevaVenta) async {
    final ventaAgregada = await _repository.agregarVenta(nuevaVenta);
    _ventas.add(ventaAgregada);
    notifyListeners();
  }

  Future<void> editarVenta(Venta ventaActualizada) async {
    final ventaEditada = await _repository.editarVenta(ventaActualizada);
    final index = _ventas.indexWhere((v) => v.codigo == ventaEditada.codigo);
    if (index != -1) {
      _ventas[index] = ventaEditada;
      notifyListeners();
    }
  }

  Future<void> anularVenta(Venta ventaAnular) async {
    await _repository.anularVenta(ventaAnular.codigo);
    _ventas.removeWhere((v) => v.codigo == ventaAnular.codigo);
    notifyListeners();
  }
}
