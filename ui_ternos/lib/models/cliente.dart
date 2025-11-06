class Cliente {
  final String nombre;
  final String? apellidos;
  final String dni;
  final String telefono;
  final String? correo;
  final String? direccion;
  final String? fechaNacimiento;
  final bool? vetado;
  final String? motivoVeto;

  const Cliente({
    required this.nombre,
    this.apellidos,
    required this.dni,
    required this.telefono,
    this.correo,
    this.direccion,
    this.fechaNacimiento,
    this.vetado,
    this.motivoVeto,
  });
}
