// lib/models/pieza_item.dart

// Estado de una pieza individual
enum PiezaEstado { completa, daniado, perdido }

extension PiezaEstadoLabel on PiezaEstado {
  String get label => switch (this) {
    PiezaEstado.completa => 'Completa',
    PiezaEstado.daniado => 'Dañado',
    PiezaEstado.perdido => 'Perdido',
  };
}

// Estado agregado (calculado) de todo el traje
enum EstadoTraje { completo, incompleto, daniado }

extension EstadoTrajeLabel on EstadoTraje {
  String get label => switch (this) {
    EstadoTraje.completo => 'Completo',
    EstadoTraje.incompleto => 'Incompleto',
    EstadoTraje.daniado => 'Dañado',
  };
}

// Modelo para la lista de piezas
class PiezaItem {
  final String nombre;
  final String articuloId; // <- El ID de la prenda/artículo en tu BD
  bool selected;
  PiezaEstado estado;

  PiezaItem({
    required this.nombre,
    required this.articuloId,
    this.selected = false,
    this.estado = PiezaEstado.completa,
  });
}
