// lib/models/venta.dart (CORREGIDO)

class Venta {
  final String codigo;
  final int clienteId;
  final DateTime fecha; // <-- CAMBIO: De 'String' a 'DateTime'
  final String producto;
  final int cantidad;
  final double precioUnitario;
  final String metodoPago;
  final double total;

  const Venta({
    required this.codigo,
    required this.clienteId,
    required this.fecha, // <-- 'DateTime'
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.metodoPago,
    required this.total,
  });
}
