// lib/providers/pago_provider.dart

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/pago_repository.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';

class PagoProvider extends ChangeNotifier {
  final PagoRepository _repository;
  List<Pago> _pagos = [];
  bool _isLoading = false;

  List<Pago> get pagos => _pagos;
  bool get isLoading => _isLoading;

  PagoProvider(this._repository) {
    fetchPagos();
  }

  Future<void> fetchPagos() async {
    _isLoading = true;
    notifyListeners();
    _pagos = await _repository.getPagos();
    _isLoading = false;
    notifyListeners();
  }
}
