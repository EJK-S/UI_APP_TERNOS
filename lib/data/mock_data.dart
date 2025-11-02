// lib/data/mock_data.dart
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/inventario_item.dart';

// Datos para gestion_alquileres_screen.dart
final List<Alquiler> mockAlquileres = [
  const Alquiler(
    codigo: 'ALQ-0015',
    cliente: 'Juan Pérez',
    fechaDevolucion: '2025-10-30',
    estado: AlquilerEstado.pendiente, // <-- Usamos el enum
  ),
  const Alquiler(
    codigo: 'ALQ-0016',
    cliente: 'María López',
    fechaDevolucion: '2025-10-29',
    estado: AlquilerEstado.atrasado, // <-- Usamos el enum
  ),
];

// Datos para gestion_clientes_screen.dart
final List<Cliente> mockClientes = [
  const Cliente(nombre: 'Juan Pérez', dni: '12345678', telefono: '987654321'),
  const Cliente(nombre: 'María López', dni: '87654321', telefono: '912345678'),
];

// Datos para gestion_ventas_screen.dart
final List<Venta> mockVentas = [
  const Venta(
    codigo: 'VEN-1021',
    total: 'S/ 480.00',
    cliente: 'Mostrador',
    fecha: '2025-10-27',
  ),
  const Venta(
    codigo: 'VEN-1020',
    total: 'S/ 320.00',
    cliente: 'Juan Pérez',
    fecha: '2025-10-27',
  ),
];

// Datos para inventario_ternos_screen.dart
final List<InventarioItem> mockStock = [
  const InventarioItem(
    prenda: 'Terno negro T42',
    estado: InventarioEstado.disponible, // <-- Usamos el enum
    usos: '5',
  ),
  const InventarioItem(
    prenda: 'Terno azul T40',
    estado: InventarioEstado.alquilado, // <-- Usamos el enum
    usos: '3',
  ),
  const InventarioItem(
    prenda: 'Saco gris T44',
    estado: InventarioEstado.mantenimiento, // <-- Usamos el enum
    usos: '12',
  ),
];

// Datos para devolucion_ternos_screen.dart
// (Esta lista necesita ser una variable de clase en un StatefulWidget,
// así que la dejaremos donde está por ahora, ya que el estado (daño, entregado) cambia.
// Si solo fuera para mostrar, la moveríamos aquí.)
