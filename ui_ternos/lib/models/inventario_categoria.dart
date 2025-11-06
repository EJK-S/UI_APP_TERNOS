class InventarioCategoria {
  final String nombre;
  final int disponibles;
  final int alquilados;
  final int mantenimiento;

  const InventarioCategoria({
    required this.nombre,
    required this.disponibles,
    required this.alquilados,
    required this.mantenimiento,
  });
}
