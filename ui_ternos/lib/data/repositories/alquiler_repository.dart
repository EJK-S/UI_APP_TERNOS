// lib/data/repositories/alquiler_repository.dart (CORREGIDO)

import 'package:flutter/foundation.dart'; // <-- CAMBIADO: No se necesita 'material.dart'
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/pieza_item.dart';

class AlquilerRepository {
  // Simula la base de datos de alquileres
  final List<Alquiler> _alquileresDB = List.from(mockAlquileres);

  // MÉTODO 1: Obtener todos los alquileres (Sin cambios)
  Future<List<Alquiler>> getAlquileres() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _alquileresDB;
  }

  // MÉTODO 2: Agregar un alquiler (Sin cambios)
  Future<Alquiler> agregarAlquiler(Alquiler nuevoAlquiler) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _alquileresDB.add(nuevoAlquiler);
    return nuevoAlquiler;
  }

  // MÉTODO 3: Registrar devolución detallada (CORREGIDO)
  Future<Alquiler> registrarDevolucionDetallada({
    required String alquilerCodigo,
    required List<PiezaItem> piezasDevueltas,
    required String observaciones,
    required bool garantiaRetenida,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // (Tu lógica de 'payload' y 'debugPrint' estaba bien)
    final payload = {
      'alquiler_codigo': alquilerCodigo,
      'observaciones': observaciones,
      'garantia_retenida': garantiaRetenida,
      'piezas': piezasDevueltas
          .map(
            (p) => {
              'articulo_id': p.articuloId,
              'estado': p.estado.name.toUpperCase(),
            },
          )
          .toList(),
    };
    debugPrint('POST /devoluciones -> $payload');

    final index = _alquileresDB.indexWhere((a) => a.codigo == alquilerCodigo);
    if (index != -1) {
      final alquilerOriginal = _alquileresDB[index];

      final alquilerActualizado = Alquiler(
        codigo: alquilerOriginal.codigo,
        clienteId: alquilerOriginal.clienteId,
        producto: alquilerOriginal.producto,
        prendaId: alquilerOriginal.prendaId, // <-- CORRECCIÓN: CAMPO AÑADIDO
        fechaInicio: alquilerOriginal.fechaInicio,
        fechaDevolucion: alquilerOriginal.fechaDevolucion,
        metodoPago: alquilerOriginal.metodoPago,
        montoTotal: alquilerOriginal.montoTotal,
        garantia: alquilerOriginal.garantia,
        estado: AlquilerEstado.pendiente, // <-- Estado "Finalizado"
      );

      _alquileresDB[index] = alquilerActualizado;
      return alquilerActualizado;
    } else {
      throw Exception('Alquiler no encontrado');
    }
  }

  // --- MÉTODO 'registrarDevolucion' ANTIGUO ELIMINADO ---
  // (Ya no es necesario, usamos 'registrarDevolucionDetallada')

  // MÉTODO 4: Prolongar alquiler (CORREGIDO)
  Future<Alquiler> prolongarAlquiler({
    required String codigo,
    required DateTime nuevaFechaDevolucion,
    required double montoAdicional,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _alquileresDB.indexWhere((a) => a.codigo == codigo);

    if (index != -1) {
      final alquilerOriginal = _alquileresDB[index];

      final montoActual =
          double.tryParse(alquilerOriginal.montoTotal.replaceAll('S/ ', '')) ??
          0.0;
      final nuevoTotal = montoActual + montoAdicional;

      final alquilerActualizado = Alquiler(
        codigo: alquilerOriginal.codigo,
        clienteId: alquilerOriginal.clienteId,
        producto: alquilerOriginal.producto,
        prendaId: alquilerOriginal.prendaId, // <-- CORRECCIÓN: CAMPO AÑADIDO
        fechaInicio: alquilerOriginal.fechaInicio,
        metodoPago: alquilerOriginal.metodoPago,
        garantia: alquilerOriginal.garantia,
        // --- Datos Actualizados ---
        fechaDevolucion: nuevaFechaDevolucion,
        montoTotal: 'S/ ${nuevoTotal.toStringAsFixed(2)}',
        estado: alquilerOriginal.estado,
      );

      _alquileresDB[index] = alquilerActualizado;
      return alquilerActualizado;
    } else {
      throw Exception('Alquiler no encontrado');
    }
  }

  Future<Alquiler> editarAlquiler(Alquiler alquilerActualizado) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Busca el alquiler por su código
    final index = _alquileresDB.indexWhere(
      (a) => a.codigo == alquilerActualizado.codigo,
    );

    if (index != -1) {
      // Reemplaza el objeto antiguo por el nuevo
      _alquileresDB[index] = alquilerActualizado;
      return alquilerActualizado;
    } else {
      throw Exception('Alquiler no encontrado para editar');
    }
  }
}
