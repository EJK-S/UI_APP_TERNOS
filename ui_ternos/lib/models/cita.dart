// lib/models/cita.dart (adaptado al backend Node + Prisma)

// =======================
//   ESTADO DE LA CITA
// =======================
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

  /// Valor que espera / devuelve el backend (ENUM EstadoCita)
  String get apiValue {
    switch (this) {
      case CitaEstado.Pendiente:
        return 'PENDIENTE';
      case CitaEstado.Completada:
        return 'COMPLETADA';
      case CitaEstado.Cancelada:
        return 'CANCELADA';
    }
  }

  /// Parsear desde string devuelto por la API
  static CitaEstado fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'COMPLETADA':
        return CitaEstado.Completada;
      case 'CANCELADA':
        return CitaEstado.Cancelada;
      case 'PENDIENTE':
      default:
        return CitaEstado.Pendiente;
    }
  }
}

// =======================
//   PROPÓSITO DE LA CITA
// =======================
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

  /// Valor que espera / devuelve el backend (ENUM PropositoCita)
  String get apiValue {
    switch (this) {
      case CitaProposito.PRUEBA:
        return 'PRUEBA';
      case CitaProposito.MEDIDAS:
        return 'MEDIDAS';
      case CitaProposito.ASESORIA:
        return 'ASESORIA';
      case CitaProposito.OTRO:
        return 'OTRO';
    }
  }

  /// Parsear desde string devuelto por la API
  static CitaProposito fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'MEDIDAS':
        return CitaProposito.MEDIDAS;
      case 'ASESORIA':
        return CitaProposito.ASESORIA;
      case 'OTRO':
        return CitaProposito.OTRO;
      case 'PRUEBA':
      default:
        return CitaProposito.PRUEBA;
    }
  }
}

// =======================
//        MODELO CITA
// =======================
class Cita {
  final int? id; // ID de la BD (string en API, int aquí)
  final int clienteId; // ID del cliente (string en API, int aquí)
  final DateTime fechaHora;
  final CitaProposito proposito;
  final CitaEstado estado;
  final String? notas;
  final DateTime? createdAt; // opcional, por si quieres mostrarlo luego

  const Cita({
    this.id,
    required this.clienteId,
    required this.fechaHora,
    required this.proposito,
    required this.estado,
    this.notas,
    this.createdAt,
  });

  // Helper para convertir valores dinámicos (String/int/num) a int
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // =======================
  //       FROM JSON
  // =======================
  /// Compatible con el map que devuelve tu backend:
  /// {
  ///   "id": "1",
  ///   "clienteId": "2",
  ///   "fechaHora": "2025-11-20T16:30:00.000Z",
  ///   "proposito": "PRUEBA",
  ///   "estado": "PENDIENTE",
  ///   "notas": "algo",
  ///   "createdAt": "2025-11-14T..."
  /// }
  factory Cita.fromJson(Map<String, dynamic> json) {
    final id = _parseInt(json['id']);
    final clienteId = _parseInt(json['clienteId']);

    final fechaStr = json['fechaHora'] as String?;
    final fecha = fechaStr != null ? DateTime.parse(fechaStr) : DateTime.now();

    final propositoStr = (json['proposito'] as String?) ?? 'PRUEBA';
    final estadoStr = (json['estado'] as String?) ?? 'PENDIENTE';

    final createdAtStr = json['createdAt'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr)
        : null;

    return Cita(
      id: id,
      clienteId: clienteId ?? 0, // si viniera null, evitamos reventar
      fechaHora: fecha,
      proposito: CitaPropositoExtension.fromApi(propositoStr),
      estado: CitaEstadoExtension.fromApi(estadoStr),
      notas: json['notas'] as String?,
      createdAt: createdAt,
    );
  }

  // =======================
  //         TO JSON
  // =======================
  /// Útil si en algún momento quieres enviar la cita completa.
  /// Para crear/actualizar estamos armando el body manualmente en el provider.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'fechaHora': fechaHora.toIso8601String(),
      'proposito': proposito.apiValue,
      'estado': estado.apiValue,
      'notas': notas,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // =======================
  //   COPIA CON CAMBIOS
  // =======================
  Cita copyWith({
    int? id,
    int? clienteId,
    DateTime? fechaHora,
    CitaProposito? proposito,
    CitaEstado? estado,
    String? notas,
    DateTime? createdAt,
  }) {
    return Cita(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fechaHora: fechaHora ?? this.fechaHora,
      proposito: proposito ?? this.proposito,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
