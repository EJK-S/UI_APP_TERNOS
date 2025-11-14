/*// lib/data/repositories/cita_repository.dart (CORREGIDO)

import 'package:proyecto_tienda_ternos/models/cita.dart';
// Nota: Ya no dependemos de 'mock_data.dart' directamente,
// el repositorio simula su propia base de datos.

class CitaRepository {
  // --- Simulación de la Base de Datos ---
  // Esta lista ahora usa el NUEVO modelo Cita y simula los datos
  // que vendrían de la API de tu amigo.
  final List<Cita> _citasDB = [
    Cita(
      id: 1,
      clienteId: 1, // Asumimos que el cliente con id=1 es Juan Pérez
      fechaHora: DateTime(2025, 10, 15, 10, 0), // 15 de Oct, 10:00 AM
      proposito: CitaProposito.OTRO, // El antiguo 'Alquiler' ahora es 'OTRO'
      estado: CitaEstado.Pendiente,
      notas: 'Prendas: Terno Negro, Zapatos, Camisa',
    ),
    Cita(
      id: 2,
      clienteId: 2, // Asumimos que el cliente con id=2 es María López
      fechaHora: DateTime(2025, 10, 15, 14, 30), // 15 de Oct, 02:30 PM
      proposito: CitaProposito.PRUEBA,
      estado: CitaEstado.Pendiente,
      notas: 'Prendas: Terno Azul, Corbatín',
    ),
    Cita(
      id: 3,
      clienteId: 3, // Asumimos que el cliente con id=3 es Carlos
      fechaHora: DateTime(2025, 10, 16, 11, 0), // 16 de Oct, 11:00 AM
      proposito: CitaProposito.OTRO, // El antiguo 'Devolucion' ahora es 'OTRO'
      estado: CitaEstado.Pendiente,
      notas: 'Prendas: Terno Gris',
    ),
  ];

  // Simula el AUTO_INCREMENT de la base de datos
  int _nextCitaId = 4;

  // --- Fin de la simulación ---

  // MÉTODO 1: Obtener todas las citas (Corregido)
  Future<List<Cita>> getCitas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _citasDB;
  }

  // MÉTODO 2: Agregar una cita (Corregido)
  Future<Cita> agregarCita(Cita nuevaCita) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Simula el AUTO_INCREMENT asignando el ID
    final citaConId = Cita(
      id: _nextCitaId++,
      clienteId: nuevaCita.clienteId,
      fechaHora: nuevaCita.fechaHora,
      proposito: nuevaCita.proposito,
      estado: nuevaCita.estado,
      notas: nuevaCita.notas,
    );

    _citasDB.add(citaConId);
    return citaConId;
  }

  // MÉTODO 3: Marcar como completada (Corregido)
  // Ahora usa el 'id' (int) en lugar de 'prendaDetalleId' (String)
  Future<Cita> marcarComoCompletada(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _citasDB.indexWhere((c) => c.id == id);

    if (index != -1) {
      final citaOriginal = _citasDB[index];
      final citaActualizada = Cita(
        id: citaOriginal.id, // Mantenemos el ID
        clienteId: citaOriginal.clienteId,
        fechaHora: citaOriginal.fechaHora,
        proposito: citaOriginal.proposito,
        notas: citaOriginal.notas,
        estado: CitaEstado.Completada, // <-- CAMBIO DE ESTADO
      );
      _citasDB[index] = citaActualizada;
      return citaActualizada;
    } else {
      throw Exception('Cita no encontrada');
    }
  }

  // MÉTODO 4: Cancelar cita (Corregido)
  // Ahora usa el 'id' (int)
  Future<Cita> cancelarCita(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _citasDB.indexWhere((c) => c.id == id);

    if (index != -1) {
      final citaOriginal = _citasDB[index];
      final citaActualizada = Cita(
        id: citaOriginal.id,
        clienteId: citaOriginal.clienteId,
        fechaHora: citaOriginal.fechaHora,
        proposito: citaOriginal.proposito,
        notas: citaOriginal.notas,
        estado: CitaEstado.Cancelada, // <-- CAMBIO DE ESTADO
      );
      _citasDB[index] = citaActualizada;
      return citaActualizada;
    } else {
      throw Exception('Cita no encontrada');
    }
  }

  // MÉTODO 5: Editar cita (Corregido)
  // La búsqueda ahora es por 'id'
  Future<Cita> editarCita(Cita citaActualizada) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _citasDB.indexWhere(
      (c) => c.id == citaActualizada.id, // <-- Búsqueda por 'id' (int)
    );

    if (index != -1) {
      _citasDB[index] = citaActualizada;
      return citaActualizada;
    } else {
      throw Exception('Cita no encontrada');
    }
  }
}*/
