// lib/providers/alquiler_provider.dart

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';

class AlquilerProvider extends ChangeNotifier {
  // 1. ESTADO: La lista de alquileres.
  // La inicializamos con nuestros datos falsos. La hacemos privada.
  final List<Alquiler> _alquileres = mockAlquileres;

  // 2. GETTER: Una forma "pública" para que las pantallas LEAN la lista.
  List<Alquiler> get alquileres => _alquileres;

  // 3. MÉTODO: La forma en que las pantallas MODIFICAN la lista.
  void agregarAlquiler(Alquiler nuevoAlquiler) {
    // Añadimos el nuevo alquiler a nuestra lista interna.
    _alquileres.add(nuevoAlquiler);

    // ¡Magia! Notificamos a todas las pantallas que están "escuchando"
    // que hubo un cambio, para que se redibujen.
    notifyListeners();
  }

  void registrarDevolucion(
    Alquiler alquilerDevuelto,
    String observaciones,
    bool garantiaRetenida,
  ) {
    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerDevuelto.codigo,
    );

    if (index != -1) {
      final alquilerActualizado = Alquiler(
        // ... (copia todos los campos)
        codigo: alquilerDevuelto.codigo,
        clienteId: alquilerDevuelto.clienteId,
        producto: alquilerDevuelto.producto,
        fechaInicio: alquilerDevuelto.fechaInicio,
        fechaDevolucion: alquilerDevuelto.fechaDevolucion,
        metodoPago: alquilerDevuelto.metodoPago,
        montoTotal: alquilerDevuelto.montoTotal,
        garantia: alquilerDevuelto.garantia,
        estado: AlquilerEstado.pendiente, // Estado "Finalizado"
        // Aquí guardarías las 'observaciones' y 'garantiaRetenida' en el backend
      );

      _alquileres[index] = alquilerActualizado;

      print(
        'Devolución registrada. Observaciones: $observaciones. Garantía retenida: $garantiaRetenida',
      );

      notifyListeners();
    }
  }

  void prolongarAlquiler(
    Alquiler alquiler,
    String nuevaFechaDevolucion,
    double montoAdicional,
  ) {
    final index = _alquileres.indexWhere((a) => a.codigo == alquiler.codigo);

    if (index != -1) {
      // Calculamos el nuevo total (convertimos 'S/ 150' a 150.0)
      final montoActual =
          double.tryParse(alquiler.montoTotal.replaceAll('S/ ', '')) ?? 0.0;
      final nuevoTotal = montoActual + montoAdicional;

      final alquilerActualizado = Alquiler(
        codigo: alquiler.codigo,
        clienteId: alquiler.clienteId,
        producto: alquiler.producto,
        fechaInicio: alquiler.fechaInicio,
        metodoPago: alquiler.metodoPago,
        garantia: alquiler.garantia,

        // --- Datos Actualizados ---
        fechaDevolucion: nuevaFechaDevolucion, // <-- Nueva fecha
        montoTotal: 'S/ ${nuevoTotal.toStringAsFixed(2)}', // <-- Nuevo total
        // El estado sigue 'activo' o 'atrasado'
        estado: alquiler.estado,
      );

      _alquileres[index] = alquilerActualizado;

      print('Alquiler ${alquiler.codigo} prolongado. Nuevo total: $nuevoTotal');

      notifyListeners(); // Avisa a la pantalla de detalle que se actualice
    }
  }

  // (En el futuro, aquí también irían los métodos para conectarse al Backend)
  // Future<void> fetchAlquileresFromAPI() { ... }
}
