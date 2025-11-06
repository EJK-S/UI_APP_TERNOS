enum CitaTipo { Alquiler, Prueba, Devolucion }

enum CitaEstado { Pendiente, Completada, Cancelada }

class Cita {
  // Datos de la lista
  final CitaTipo tipo;
  final String clienteNombre;
  final String prendasResumen;
  final String fecha;
  final String hora;
  final CitaEstado estado;

  // Datos del detalle
  final String clienteTelefono;
  final String clienteEmail;
  final String prendaDetalleNombre;
  final String prendaDetalleId;

  const Cita({
    required this.tipo,
    required this.clienteNombre,
    required this.prendasResumen,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.clienteTelefono,
    required this.clienteEmail,
    required this.prendaDetalleNombre,
    required this.prendaDetalleId,
  });

  // Helper para obtener el texto del tipo
  String get tipoTexto {
    switch (tipo) {
      case CitaTipo.Alquiler:
        return 'Alquiler';
      case CitaTipo.Prueba:
        return 'Prueba';
      case CitaTipo.Devolucion:
        return 'Devolución';
    }
  }
}
