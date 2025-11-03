enum AlquilerEstado { pendiente, atrasado, activo }

class Alquiler {
  final String codigo;
  final String cliente;
  final String producto;
  final String fechaInicio;
  final String fechaDevolucion;
  final AlquilerEstado estado;

  // --- NUEVOS CAMPOS AÑADIDOS ---
  final String metodoPago;
  final String montoTotal;
  final String garantia;

  const Alquiler({
    required this.codigo,
    required this.cliente,
    required this.producto,
    required this.fechaInicio,
    required this.fechaDevolucion,
    required this.estado,
    // --- NUEVOS CAMPOS AÑADIDOS ---
    required this.metodoPago,
    required this.montoTotal,
    required this.garantia,
  });
}
