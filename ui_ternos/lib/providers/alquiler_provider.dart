// lib/providers/alquiler_provider.dart (VERSIÓN COMPLETA Y CORRECTA)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/alquiler_repository.dart';
import 'package:proyecto_tienda_ternos/providers/pago_provider.dart'; // Importa el Provider
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/pieza_item.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';

class AlquilerProvider extends ChangeNotifier {
  final AlquilerRepository _alquilerRepository;
  PagoProvider _pagoProvider; // Dependencia del PagoProvider

  List<Alquiler> _alquileres = [];
  bool _isLoading = false;

  List<Alquiler> get alquileres => _alquileres;
  bool get isLoading => _isLoading;

  // --- CORRECCIÓN 1: EL CONSTRUCTOR NO DEBE LLAMAR A fetchAlquileres() ---
  // La llamada se hace desde main.dart
  AlquilerProvider(this._alquilerRepository, this._pagoProvider);

  // Método para que main.dart actualice el PagoProvider (necesario para ProxyProvider)
  void updatePagoProvider(PagoProvider newPagoProvider) {
    _pagoProvider = newPagoProvider;
  }

  // --- CORRECCIÓN 2: IMPLEMENTACIÓN COMPLETA DE LOS MÉTODOS ---

  Future<void> fetchAlquileres() async {
    // 'Guardia' para evitar cargas múltiples si ya se llamó
    if (_alquileres.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    // --- CORRECCIÓN 3: Usar List.from() para crear una copia ---
    // (Esto soluciona el bug de duplicados)
    _alquileres = List.from(await _alquilerRepository.getAlquileres());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarAlquiler(Alquiler nuevoAlquiler) async {
    final alquilerAgregado = await _alquilerRepository.agregarAlquiler(
      nuevoAlquiler,
    );
    _alquileres.add(alquilerAgregado);
    notifyListeners(); // Notifica a la lista de alquileres y al panel de admin
  }

  // (Este método ya estaba bien en tu código)
  Future<void> registrarDevolucionDetallada({
    required Alquiler alquiler,
    required List<PiezaItem> piezasDevueltas,
    required String observaciones,
    required bool garantiaRetenida,
  }) async {
    final alquilerActualizado = await _alquilerRepository
        .registrarDevolucionDetallada(
          alquilerCodigo: alquiler.codigo,
          piezasDevueltas: piezasDevueltas,
          observaciones: observaciones,
          garantiaRetenida: garantiaRetenida,
        );
    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerActualizado.codigo,
    );
    if (index != -1) {
      _alquileres[index] = alquilerActualizado;
      notifyListeners();
    }
  }

  // (Este método ya estaba bien en tu código)
  Future<void> prolongarAlquiler({
    required Alquiler alquiler,
    required DateTime nuevaFechaDevolucion,
    required double montoAdicional,
  }) async {
    final alquilerActualizado = await _alquilerRepository.prolongarAlquiler(
      codigo: alquiler.codigo,
      nuevaFechaDevolucion: nuevaFechaDevolucion,
      montoAdicional: montoAdicional,
    );

    final pagoAdicional = Pago(
      id: 'PGO-${DateTime.now().millisecondsSinceEpoch}',
      fecha: DateTime.now(),
      clienteId: alquiler.clienteId,
      monto: 'S/ ${montoAdicional.toStringAsFixed(2)}',
      tipo: TipoPago.Alquiler,
      metodo: 'Extensión',
      transaccionId: alquiler.codigo,
    );

    // Llama al MÉTODO del Provider
    await _pagoProvider.agregarPago(pagoAdicional);

    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerActualizado.codigo,
    );
    if (index != -1) {
      _alquileres[index] = alquilerActualizado;
      notifyListeners();
    }
  }

  Future<void> editarAlquiler(Alquiler alquilerActualizado) async {
    // 1. Llama al repositorio (API)
    final alquilerEditado = await _alquilerRepository.editarAlquiler(
      alquilerActualizado,
    );

    // 2. Actualiza el estado local
    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerEditado.codigo,
    );
    if (index != -1) {
      _alquileres[index] = alquilerEditado;
      notifyListeners();
    }
  }
}
