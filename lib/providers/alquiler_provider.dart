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

  // (En el futuro, aquí también irían los métodos para conectarse al Backend)
  // Future<void> fetchAlquileresFromAPI() { ... }
}
