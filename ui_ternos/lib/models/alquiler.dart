// lib/models/alquiler.dart (CORREGIDO)

enum AlquilerEstado { pendiente, atrasado, activo }

class Alquiler {
  final String codigo;
  final int clienteId;
  final String producto;
  final String prendaId;
  final DateTime fechaInicio; // <-- CAMBIO: De 'String' a 'DateTime'
  final DateTime fechaDevolucion; // <-- CAMBIO: De 'String' a 'DateTime'
  final AlquilerEstado estado;
  final String metodoPago;
  final String montoTotal;
  final String garantia;

  const Alquiler({
    required this.codigo,
    required this.clienteId,
    required this.producto,
    required this.prendaId,
    required this.fechaInicio, // <-- 'DateTime'
    required this.fechaDevolucion, // <-- 'DateTime'
    required this.estado,
    required this.metodoPago,
    required this.montoTotal,
    required this.garantia,
  });
}
