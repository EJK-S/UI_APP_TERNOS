import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';

class VentaProvider extends ChangeNotifier {
  // 1. ESTADO: La lista de ventas (publica)
  final List<Venta> _ventas = List.from(mockVentas);

  // 2. GETTER: La forma pública de LEER la lista
  List<Venta> get ventas => _ventas;

  // 3. MÉTODO: La forma pública de MODIFICAR la lista
  void agregarVenta(Venta nuevaVenta) {
    _ventas.add(nuevaVenta);

    // Notificamos a los "oyentes" (como la pantalla de lista) que hay un cambio
    notifyListeners();
  }

  void editarVenta(Venta ventaActualizada) {
    // Buscamos la venta por su código (ID único)
    final index = _ventas.indexWhere(
      (v) => v.codigo == ventaActualizada.codigo,
    );

    if (index != -1) {
      // Si la encontramos, la reemplazamos
      _ventas[index] = ventaActualizada;
      notifyListeners();
    }
  }

  // (En el futuro, aquí irían métodos como 'anularVenta', etc.)
}
