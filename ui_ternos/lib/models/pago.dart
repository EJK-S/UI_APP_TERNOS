// lib/models/pago.dart (CORREGIDO)

enum TipoPago { Venta, Alquiler }
// (El enum MetodoPago ya no es necesario)

class Pago {
  final String id;
  final DateTime fecha; // <-- CAMBIO: De 'String' a 'DateTime'
  final int clienteId;
  final String monto;
  final TipoPago tipo;
  final String metodo; // <-- CAMBIO: De 'Enum' a 'String'
  final String transaccionId;

  const Pago({
    required this.id,
    required this.fecha,
    required this.clienteId,
    required this.monto,
    required this.tipo,
    required this.metodo,
    required this.transaccionId,
  });
}
