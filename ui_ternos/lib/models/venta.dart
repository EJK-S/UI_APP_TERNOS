// lib/models/venta.dart (Actualizado)

class Venta {
  final String codigo;
  final String clienteId;
  final String fecha;

  // --- Campos actualizados ---
  final String producto; // Era 'tipo de traje' en el form
  final int cantidad;
  final double precioUnitario;
  final String metodoPago;
  final double total;

  const Venta({
    required this.codigo,
    required this.clienteId,
    required this.fecha,
    required this.producto,
    required this.cantidad,
    required this.precioUnitario,
    required this.metodoPago,
    required this.total,
  });
}
