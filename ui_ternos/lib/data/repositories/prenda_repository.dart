// lib/data/repositories/prenda_repository.dart

import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';

class PrendaRepository {
  // Simula la base de datos de prendas
  final List<Prenda> _prendasDB = List.from(mockPrendas);

  // MÉTODO 1: Obtener todas las prendas
  Future<List<Prenda>> getPrendas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _prendasDB;
  }

  // MÉTODO 2: Agregar una prenda
  Future<Prenda> agregarPrenda(Prenda nuevaPrenda) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _prendasDB.add(nuevaPrenda);
    return nuevaPrenda;
  }

  // MÉTODO 3: Editar una prenda
  Future<Prenda> editarPrenda(Prenda prendaActualizada) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _prendasDB.indexWhere((p) => p.id == prendaActualizada.id);

    if (index != -1) {
      _prendasDB[index] = prendaActualizada;
      return prendaActualizada;
    } else {
      throw Exception('Prenda no encontrada');
    }
  }

  // MÉTODO 4: Eliminar una prenda
  Future<void> eliminarPrenda(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _prendasDB.removeWhere((p) => p.id == id);
  }
}
