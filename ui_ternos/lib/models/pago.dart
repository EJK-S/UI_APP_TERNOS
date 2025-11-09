enum TipoPago { Venta, Alquiler }

enum MetodoPago { Tarjeta, Yape, Efectivo }

class Pago {
  final String id;
  final String fecha;
  final String cliente;
  final String monto;
  final TipoPago tipo;
  final MetodoPago metodo;
  final String transaccionId;

  const Pago({
    required this.id,
    required this.fecha,
    required this.cliente,
    required this.monto,
    required this.tipo,
    required this.metodo,
    required this.transaccionId,
  });
}
