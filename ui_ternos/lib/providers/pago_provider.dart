// lib/providers/pago_provider.dart (VERSIÓN COMPLETA Y CORRECTA)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/pago_repository.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';

class PagoProvider extends ChangeNotifier {
  final PagoRepository _repository;
  List<Pago> _pagos = [];
  bool _isLoading = false;

  List<Pago> get pagos => _pagos;
  bool get isLoading => _isLoading;

  // --- CORRECCIÓN 1: EL CONSTRUCTOR NO DEBE LLAMAR A fetchPagos() ---
  // La llamada se hace desde main.dart
  PagoProvider(this._repository);

  // --- CORRECCIÓN 2: IMPLEMENTACIÓN COMPLETA DE LOS MÉTODOS ---

  Future<void> fetchPagos() async {
    // 'Guardia' para evitar cargas múltiples si ya se llamó
    if (_pagos.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    // (Tu 'List.from' ya era correcto para evitar duplicados)
    _pagos = List.from(await _repository.getPagos());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarPago(Pago nuevoPago) async {
    final pagoAgregado = await _repository.agregarPago(nuevoPago);
    _pagos.add(pagoAgregado);
    notifyListeners(); // Notifica a la lista de pagos
  }

  // (Tu método 'eliminarPagoPorTransaccionId' ya era correcto)
  Future<void> eliminarPagoPorTransaccionId(String transaccionId) async {
    // 1. Llama al repositorio (API)
    await _repository.eliminarPagoPorTransaccionId(transaccionId);

    // 2. Actualiza el estado local
    _pagos.removeWhere((p) => p.transaccionId == transaccionId);
    notifyListeners(); // Notifica a la lista de pagos
  }
}
