import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';

class CitaProvider extends ChangeNotifier {
  // 1. ESTADO: La lista de citas (privada)
  final List<Cita> _citas = mockCitas;

  // 2. GETTER: La forma pública de LEER la lista
  List<Cita> get citas => _citas;

  // 3. MÉTODOS: Las formas públicas de MODIFICAR la lista

  void agregarCita(Cita nuevaCita) {
    _citas.add(nuevaCita);
    // Notificamos a los "oyentes" (como la pantalla de lista) que hay un cambio
    notifyListeners();
  }

  void marcarComoCompletada(Cita cita) {
    // (Esta lógica es un ejemplo, no podemos modificar un 'const Cita')
    // En un futuro, aquí llamarías a tu API (Backend)
    // Por ahora, solo imprimimos en consola:
    // ignore: avoid_print
    print('Cita de ${cita.clienteNombre} marcada como completada.');

    // Si quisieras cambiar el estado, necesitarías que la lista _citas
    // no sea de 'const Cita' y tendrías que encontrar y reemplazar el objeto.

    // notifyListeners(); // (No notificamos porque no hicimos un cambio real)
  }

  void cancelarCita(Cita cita) {
    // ignore: avoid_print
    print('Cita de ${cita.clienteNombre} cancelada.');
    // Lógica similar a la de arriba
  }
}
