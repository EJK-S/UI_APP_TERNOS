// lib/models/venta.dart (CORREGIDO)

class Venta {
  final String codigo;
  final int clienteId; // <-- CAMBIO: De 'String' a 'int'
  final String fecha;
  final String producto;
  final int cantidad;
  final double precioUnitario;
  final String metodoPago;
  final double total;

  const Venta({
    required this.codigo,
    required this.clienteId, // <-- 'int'
    required this.fecha,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.metodoPago,
    required this.total,
  });
}
