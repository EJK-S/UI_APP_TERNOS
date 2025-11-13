class Cliente {
  final int? id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String celular;
  final String? direccion;
  final String? fechaNac; // String o Date, como lo manejes
  final bool vetado;
  final String? motivoVeto;

  const Cliente({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.celular,
    this.direccion,
    this.fechaNac,
    this.vetado = false,
    this.motivoVeto,
  });

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
    nombres: j['nombres'] ?? '',
    apellidos: j['apellidos'] ?? '',
    dni: j['dni'] ?? '',
    celular: j['celular'] ?? '',
    direccion: j['direccion'],
    fechaNac: j['fecha_nac']?.toString(),
    vetado: (j['vetado'] is bool) ? j['vetado'] : (j['vetado'] == 1),
    motivoVeto: j['motivo_veto'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombres': nombres,
    'apellidos': apellidos,
    'dni': dni,
    'celular': celular,
    'direccion': direccion,
    'fecha_nac': fechaNac,
    'vetado': vetado,
    'motivo_veto': motivoVeto,
  };
}
