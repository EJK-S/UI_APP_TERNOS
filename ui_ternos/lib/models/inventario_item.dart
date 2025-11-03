enum InventarioEstado { disponible, alquilado, mantenimiento }

class InventarioItem {
  final String prenda;
  final InventarioEstado estado;
  final String usos;

  const InventarioItem({
    required this.prenda,
    required this.estado,
    required this.usos,
  });
}
