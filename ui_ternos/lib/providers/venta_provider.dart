// lib/providers/venta_provider.dart (VERSIÓN COMPLETA Y CORRECTA)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/venta_repository.dart';
import 'package:proyecto_tienda_ternos/providers/pago_provider.dart'; // Importa el Provider
import 'package:proyecto_tienda_ternos/models/venta.dart';

class VentaProvider extends ChangeNotifier {
  final VentaRepository _ventaRepository;
  PagoProvider _pagoProvider; // Dependencia del PagoProvider

  List<Venta> _ventas = [];
  bool _isLoading = false;

  List<Venta> get ventas => _ventas;
  bool get isLoading => _isLoading;

  // --- CORRECCIÓN 1: EL CONSTRUCTOR NO DEBE LLAMAR A fetchVentas() ---
  // La llamada se hace desde main.dart
  VentaProvider(this._ventaRepository, this._pagoProvider);

  // Método para que main.dart actualice el PagoProvider (necesario para ProxyProvider)
  void updatePagoProvider(PagoProvider newPagoProvider) {
    _pagoProvider = newPagoProvider;
  }

  // --- CORRECCIÓN 2: IMPLEMENTACIÓN COMPLETA DE LOS MÉTODOS ---

  Future<void> fetchVentas() async {
    // 'Guardia' para evitar cargas múltiples si ya se llamó
    if (_ventas.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    // Usar List.from() para crear una copia (soluciona el bug de duplicados)
    _ventas = List.from(await _ventaRepository.getVentas());

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarVenta(Venta nuevaVenta) async {
    final ventaAgregada = await _ventaRepository.agregarVenta(nuevaVenta);
    _ventas.add(ventaAgregada);
    notifyListeners(); // Notifica a la lista de ventas y al panel de admin
  }

  Future<void> editarVenta(Venta ventaActualizada) async {
    final ventaEditada = await _ventaRepository.editarVenta(ventaActualizada);
    final index = _ventas.indexWhere((v) => v.codigo == ventaEditada.codigo);
    if (index != -1) {
      _ventas[index] = ventaEditada;
      notifyListeners();
    }
  }

  // Esta función ya estaba correcta en tu código
  Future<void> anularVenta(Venta ventaAnular) async {
    // 1. Llama al repositorio de ventas
    await _ventaRepository.anularVenta(ventaAnular.codigo);

    // 2. Llama al MÉTODO del PagoProvider
    await _pagoProvider.eliminarPagoPorTransaccionId(ventaAnular.codigo);

    // 3. Actualiza el estado local
    _ventas.removeWhere((v) => v.codigo == ventaAnular.codigo);
    notifyListeners(); // Notifica a la lista de ventas y al panel de admin
  }
}
