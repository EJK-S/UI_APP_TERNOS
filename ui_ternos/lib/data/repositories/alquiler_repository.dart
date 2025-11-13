// lib/data/repositories/alquiler_repository.dart

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/pieza_item.dart';

class AlquilerRepository {
  // Simula la base de datos de alquileres
  final List<Alquiler> _alquileresDB = List.from(mockAlquileres);

  // MÉTODO 1: Obtener todos los alquileres
  Future<List<Alquiler>> getAlquileres() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _alquileresDB;
  }

  // MÉTODO 2: Agregar un alquiler
  Future<Alquiler> agregarAlquiler(Alquiler nuevoAlquiler) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _alquileresDB.add(nuevoAlquiler);
    return nuevoAlquiler;
  }

  Future<Alquiler> registrarDevolucionDetallada({
    required String alquilerCodigo,
    required List<PiezaItem> piezasDevueltas,
    required String observaciones,
    required bool garantiaRetenida,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
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
    // --- Fin de la simulación ---

    // Buscamos el alquiler en nuestra BD simulada
    final index = _alquileresDB.indexWhere((a) => a.codigo == alquilerCodigo);
    if (index != -1) {
      final alquilerOriginal = _alquileresDB[index];
      // Creamos la copia actualizada con estado 'pendiente'
      final alquilerActualizado = Alquiler(
        codigo: alquilerOriginal.codigo,
        clienteId: alquilerOriginal.clienteId,
        producto: alquilerOriginal.producto,
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

  // MÉTODO 3: Registrar devolución (simula la lógica del provider [cite: 507-511])
  Future<Alquiler> registrarDevolucion(
    String codigo,
    String observaciones,
    bool garantiaRetenida,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _alquileresDB.indexWhere((a) => a.codigo == codigo);

    if (index != -1) {
      final alquilerOriginal = _alquileresDB[index];
      final alquilerActualizado = Alquiler(
        codigo: alquilerOriginal.codigo,
        clienteId: alquilerOriginal.clienteId,
        producto: alquilerOriginal.producto,
        fechaInicio: alquilerOriginal.fechaInicio,
        fechaDevolucion: alquilerOriginal.fechaDevolucion,
        metodoPago: alquilerOriginal.metodoPago,
        montoTotal: alquilerOriginal.montoTotal,
        garantia: alquilerOriginal.garantia,
        estado: AlquilerEstado.pendiente, // Estado "Finalizado"
      );

      _alquileresDB[index] = alquilerActualizado;

      // En una API real, aquí guardarías las observaciones y la garantía
      print(
        'Repo: Devolución registrada para $codigo. Obs: $observaciones. Garantía Retenida: $garantiaRetenida',
      );

      return alquilerActualizado;
    } else {
      throw Exception('Alquiler no encontrado');
    }
  }

  // MÉTODO 4: Prolongar alquiler (simula la lógica del provider [cite: 511-516])
  Future<Alquiler> prolongarAlquiler({
    required String codigo,
    required DateTime
    nuevaFechaDevolucion, // <-- CAMBIO: De 'String' a 'DateTime'
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
        fechaInicio: alquilerOriginal.fechaInicio,
        metodoPago: alquilerOriginal.metodoPago,
        garantia: alquilerOriginal.garantia,

        // --- Datos Actualizados ---
        fechaDevolucion: nuevaFechaDevolucion, // <-- CAMBIO: Acepta el DateTime
        montoTotal: 'S/ ${nuevoTotal.toStringAsFixed(2)}',
        estado: alquilerOriginal.estado,
      );

      _alquileresDB[index] = alquilerActualizado;
      return alquilerActualizado;
    } else {
      throw Exception('Alquiler no encontrado');
    }
  }
}
