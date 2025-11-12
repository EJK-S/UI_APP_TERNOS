// lib/models/cita.dart (Actualizado para la Base de Datos)
// 1. El enum CitaEstado [cite: 286] sigue siendo válido
//    para la columna 'estado' de la BD.
enum CitaEstado { Pendiente, Completada, Cancelada }

extension CitaEstadoExtension on CitaEstado {
  String get texto {
    switch (this) {
      case CitaEstado.Pendiente:
        return 'Pendiente';
      case CitaEstado.Completada:
        return 'Completada';
      case CitaEstado.Cancelada:
        return 'Cancelada';
    }
  }
}

// 2. Nuevo enum para la columna 'proposito' de la BD.
//    (El antiguo CitaTipo  queda obsoleto).
enum CitaProposito { PRUEBA, MEDIDAS, ASESORIA, OTRO }

extension CitaPropositoExtension on CitaProposito {
  String get texto {
    switch (this) {
      case CitaProposito.PRUEBA:
        return 'Prueba';
      case CitaProposito.MEDIDAS:
        return 'Toma de Medidas';
      case CitaProposito.ASESORIA:
        return 'Asesoría';
      case CitaProposito.OTRO:
        return 'Otro';
    }
  }
}

// 3. La clase Cita ahora refleja la tabla de la BD
class Cita {
  final int? id; // El ID de la BD (opcional en la creación)
  final int clienteId; // ¡Debe ser int/BigInt, no String! (Ver Alerta abajo)
  final DateTime fechaHora;
  final CitaProposito proposito;
  final CitaEstado estado;
  final String? notas;

  const Cita({
    this.id,
    required this.clienteId,
    required this.fechaHora,
    required this.proposito,
    required this.estado,
    this.notas,
  });

  // (El resto de campos como 'prendasResumen', 'prendaDetalleId' [cite: 287-291]
  //  se eliminan porque no están en la nueva BD ni en la nueva UI)
}
