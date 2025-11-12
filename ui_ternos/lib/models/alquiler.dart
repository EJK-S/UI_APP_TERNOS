// lib/models/alquiler.dart (CORREGIDO)

enum AlquilerEstado { pendiente, atrasado, activo }

class Alquiler {
  final String codigo;
  final int clienteId; // <-- CAMBIO: De 'String' a 'int'
  final String producto;
  final String fechaInicio;
  final String fechaDevolucion;
  final AlquilerEstado estado;
  final String metodoPago;
  final String montoTotal;
  final String garantia;

  const Alquiler({
    required this.codigo,
    required this.clienteId, // <-- 'int'
    required this.producto,
    required this.fechaInicio,
    required this.fechaDevolucion,
    required this.estado,
    required this.metodoPago,
    required this.montoTotal,
    required this.garantia,
  });
}
