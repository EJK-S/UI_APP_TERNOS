enum AlquilerEstado { pendiente, atrasado }

class Alquiler {
  final String codigo;
  final String cliente;
  final String fechaDevolucion;
  final AlquilerEstado estado;

  const Alquiler({
    required this.codigo,
    required this.cliente,
    required this.fechaDevolucion,
    required this.estado,
  });
}
