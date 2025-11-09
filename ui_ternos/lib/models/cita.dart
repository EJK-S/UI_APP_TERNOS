// lib/models/cita.dart (Corregido)

// ERROR 1: Se eliminó un punto y coma (;) al final de esta línea
enum CitaTipo { Alquiler, Prueba, Devolucion }

extension CitaTipoExtension on CitaTipo {
  String get tipoTexto {
    switch (this) {
      case CitaTipo.Alquiler:
        return 'Alquiler';
      case CitaTipo.Prueba:
        return 'Prueba';
      case CitaTipo.Devolucion:
        return 'Devolución';
    }
  }
}

// ERROR 2: Se eliminó la línea corrupta "final String {; }"

enum CitaEstado { Pendiente, Completada, Cancelada }

class Cita {
  // Datos de la lista
  final CitaTipo tipo;
  final String clienteId;
  final String prendasResumen;
  final String fecha;
  final String hora;
  final CitaEstado estado;

  // Datos del detalle
  final String prendaDetalleNombre;
  final String prendaDetalleId;

  const Cita({
    required this.tipo,
    required this.clienteId,
    required this.prendasResumen,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.prendaDetalleNombre,
    required this.prendaDetalleId,
  });

  // Helper para obtener el texto del tipo
  String get tipoTexto {
    return tipo.tipoTexto;
  }
}

// ERROR 3: Se eliminó una llave de cierre (}) extra al final del archivo
