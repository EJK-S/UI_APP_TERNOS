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
    // Busca la cita por su ID (usaremos prendaDetalleId como ID único)
    final index = _citas.indexWhere(
      (c) => c.prendaDetalleId == cita.prendaDetalleId,
    );
    if (index == -1) return; // No se encontró

    // Crea una copia actualizada de la cita
    _citas[index] = Cita(
      tipo: cita.tipo,
      clienteId: cita.clienteId,
      prendasResumen: cita.prendasResumen,
      fecha: cita.fecha,
      hora: cita.hora,
      prendaDetalleNombre: cita.prendaDetalleNombre,
      prendaDetalleId: cita.prendaDetalleId,
      estado: CitaEstado.Completada, // <-- CAMBIO DE ESTADO
    );
    notifyListeners(); // Avisa a las pantallas que se redibujen
  }

  void cancelarCita(Cita cita) {
    // Busca la cita por su ID
    final index = _citas.indexWhere(
      (c) => c.prendaDetalleId == cita.prendaDetalleId,
    );
    if (index == -1) return;

    // Crea una copia actualizada de la cita
    _citas[index] = Cita(
      tipo: cita.tipo,
      clienteId: cita.clienteId,
      prendasResumen: cita.prendasResumen,
      fecha: cita.fecha,
      hora: cita.hora,
      prendaDetalleNombre: cita.prendaDetalleNombre,
      prendaDetalleId: cita.prendaDetalleId,
      estado: CitaEstado.Cancelada, // <-- CAMBIO DE ESTADO
    );
    notifyListeners(); // Avisa a las pantallas que se redibujen
  }

  void editarCita(Cita citaActualizada) {
    // Buscamos la cita. Necesitaremos un ID único.
    // Usaremos el 'prendaDetalleId' como ID único por ahora.
    final index = _citas.indexWhere(
      (c) => c.prendaDetalleId == citaActualizada.prendaDetalleId,
    );

    if (index != -1) {
      _citas[index] = citaActualizada;
      notifyListeners();
    }
  }
}
