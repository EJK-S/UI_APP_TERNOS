import 'package:flutter/material.dart';

// El estado de una prenda individual
enum PrendaEstado { Disponible, Alquilado, Mantenimiento }

// Extensión para darle al enum métodos útiles (color y texto)
extension PrendaEstadoExtension on PrendaEstado {
  String get texto {
    switch (this) {
      case PrendaEstado.Disponible:
        return 'Disponible';
      case PrendaEstado.Alquilado:
        return 'Alquilado';
      case PrendaEstado.Mantenimiento:
        return 'Mantenimiento';
    }
  }

  Color get color {
    switch (this) {
      case PrendaEstado.Disponible:
        return Colors.green;
      case PrendaEstado.Alquilado:
        return Colors.orange;
      case PrendaEstado.Mantenimiento:
        return Colors.red;
    }
  }
}

// La clase para una prenda individual
class Prenda {
  final String id;
  final String nombre; // Ej. "Terno Clásico Negro"
  final String talla; // Ej. "M" o "42"
  final String categoria; // Ej. "Traje Clásico"
  final PrendaEstado estado;
  final int usos;

  const Prenda({
    required this.id,
    required this.nombre,
    required this.talla,
    required this.categoria,
    required this.estado,
    this.usos = 0,
  });
}
