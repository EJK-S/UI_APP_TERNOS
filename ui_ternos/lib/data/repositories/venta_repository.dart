// lib/data/repositories/venta_repository.dart

import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';

class VentaRepository {
  // Simula la base de datos de ventas, copiando los datos mock
  final List<Venta> _ventasDB = List.from(mockVentas);

  // MÉTODO 1: Obtener todas las ventas
  Future<List<Venta>> getVentas() async {
    // Simula una llamada a la API
    await Future.delayed(const Duration(milliseconds: 500));
    return _ventasDB;
  }

  // MÉTODO 2: Agregar una venta
  Future<Venta> agregarVenta(Venta nuevaVenta) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ventasDB.add(nuevaVenta);
    return nuevaVenta;
  }

  // MÉTODO 3: Editar una venta
  Future<Venta> editarVenta(Venta ventaActualizada) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _ventasDB.indexWhere(
      (v) => v.codigo == ventaActualizada.codigo,
    );

    if (index != -1) {
      _ventasDB[index] = ventaActualizada;
      return ventaActualizada;
    } else {
      throw Exception('Venta no encontrada');
    }
  }

  // MÉTODO 4: Anular una venta (eliminar)
  Future<void> anularVenta(String codigoVenta) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ventasDB.removeWhere((v) => v.codigo == codigoVenta);
  }
}
