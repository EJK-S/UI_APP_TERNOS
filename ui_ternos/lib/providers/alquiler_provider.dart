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

  void registrarDevolucion(Alquiler alquilerDevuelto, String observaciones) {
    // Busca el alquiler por su código
    final index = _alquileres.indexWhere(
      (a) => a.codigo == alquilerDevuelto.codigo,
    );

    if (index != -1) {
      // Crea una copia del alquiler pero con el estado cambiado
      final alquilerActualizado = Alquiler(
        codigo: alquilerDevuelto.codigo,
        cliente: alquilerDevuelto.cliente,
        producto: alquilerDevuelto.producto,
        fechaInicio: alquilerDevuelto.fechaInicio,
        fechaDevolucion: alquilerDevuelto.fechaDevolucion,
        metodoPago: alquilerDevuelto.metodoPago,
        montoTotal: alquilerDevuelto.montoTotal,
        garantia: alquilerDevuelto.garantia,
        estado: AlquilerEstado
            .pendiente, // <-- CAMBIA EL ESTADO A "PENDIENTE" (FINALIZADO)
        // Aquí también guardarías las 'observaciones' si tu modelo las tuviera
      );

      // Reemplaza el alquiler antiguo por el actualizado
      _alquileres[index] = alquilerActualizado;

      // Notifica a la lista de alquileres que se actualice
      notifyListeners();
    }
  }

  // (En el futuro, aquí también irían los métodos para conectarse al Backend)
  // Future<void> fetchAlquileresFromAPI() { ... }
}
