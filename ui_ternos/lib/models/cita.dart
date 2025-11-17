// lib/models/cita.dart (Actualizado)

import 'package:flutter/material.dart';

// (CitaEstado no cambia)
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

// --- 1. ENUM CORREGIDO ---
// (Cambiado 'ASESORIA' por 'ALQUILER')
enum CitaProposito { PRUEBA, MEDIDAS, ALQUILER, OTRO }

// --- 2. EXTENSIÓN CORREGIDA ---
extension CitaPropositoExtension on CitaProposito {
  String get texto {
    switch (this) {
      case CitaProposito.PRUEBA:
        return 'Prueba';
      case CitaProposito.MEDIDAS:
        return 'Toma de Medidas';
      case CitaProposito.ALQUILER: // <-- CORREGIDO
        return 'Alquiler'; // <-- CORREGIDO
      case CitaProposito.OTRO:
        return 'Otro';
    }
  }
}

// (La clase Cita no cambia)
class Cita {
  final int? id;
  final int clienteId;
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
}
