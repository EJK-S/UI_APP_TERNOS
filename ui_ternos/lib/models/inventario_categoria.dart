// lib/models/inventario_categoria.dart (CORREGIDO)

class InventarioCategoria {
  final String nombre;
  final int disponibles;
  final int alquilados;
  final int mantenimiento;
  final int vendidos; // <-- AÑADIDO

  const InventarioCategoria({
    required this.nombre,
    required this.disponibles,
    required this.alquilados,
    required this.mantenimiento,
    required this.vendidos, // <-- AÑADIDO
  });
}
