class Cliente {
  int? id;
  String nombre;
  String? apellidos;
  String dni;
  String telefono;
  String? direccion;
  String? fechaNacimiento; // siempre 'YYYY-MM-DD' o null
  bool? vetado;
  String? motivoVeto;

  Cliente({
    this.id,
    required this.nombre,
    this.apellidos,
    required this.dni,
    required this.telefono,
    this.direccion,
    this.fechaNacimiento,
    this.vetado,
    this.motivoVeto,
  });

  static String? _normFecha(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (m != null) return '${m.group(1)}-${m.group(2)}-${m.group(3)}';
    if (RegExp(r'^\d{2}\/\d{2}\/\d{4}$').hasMatch(raw)) {
      final p = raw.split('/');
      return '${p[2]}-${p[1]}-${p[0]}';
    }
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

  factory Cliente.fromJson(Map<String, dynamic> m) => Cliente(
    id: m['id'] as int?,
    nombre: (m['nombres'] ?? m['nombre'] ?? '') as String,
    apellidos: m['apellidos'] as String?,
    dni: (m['dni'] ?? '') as String,
    telefono: (m['celular'] ?? m['telefono'] ?? '') as String,
    direccion: m['direccion'] as String?,
    fechaNacimiento: _normFecha(m['fecha_nac'] as String?),
    vetado: (m['vetado'] == 1 || m['vetado'] == true),
    motivoVeto: m['motivo_veto'] as String?,
  );

  Map<String, dynamic> toJson({bool includeId = false}) => {
    if (includeId && id != null) 'id': id,
    'nombres': nombre,
    'apellidos': apellidos,
    'dni': dni,
    'celular': telefono,
    'direccion': direccion,
    // 👇 siempre 'YYYY-MM-DD' o null
    'fecha_nac': _normFecha(fechaNacimiento),
    'vetado': vetado == true ? 1 : 0,
    'motivo_veto': motivoVeto,
  };
}
