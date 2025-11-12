// lib/models/pago.dart (CORREGIDO)

enum TipoPago { Venta, Alquiler }

enum MetodoPago { Tarjeta, Yape, Efectivo }

class Pago {
  final String id;
  final String fecha;
  final int clienteId; // <-- CAMBIO: De 'String cliente' a 'int clienteId'
  final String monto;
  final TipoPago tipo;
  final MetodoPago metodo;
  final String transaccionId; // (El código de Venta o Alquiler)

  const Pago({
    required this.id,
    required this.fecha,
    required this.clienteId, // <-- CORREGIDO
    required this.monto,
    required this.tipo,
    required this.metodo,
    required this.transaccionId,
  });
}
