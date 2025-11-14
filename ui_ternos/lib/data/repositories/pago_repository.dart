// lib/data/repositories/pago_repository.dart

import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';

class PagoRepository {
  final List<Pago> _pagosDB = List.from(mockPagos);

  Future<List<Pago>> getPagos() async {
    // Simula una llamada a la API
    await Future.delayed(const Duration(milliseconds: 600));
    return _pagosDB;
  }

  Future<Pago> agregarPago(Pago nuevoPago) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _pagosDB.add(nuevoPago);
    return nuevoPago;
  }
}
