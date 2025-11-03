import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/inventario_item.dart';

// ----- LISTA DE ALQUILERES ACTUALIZADA -----
final List<Alquiler> mockAlquileres = [
  const Alquiler(
    codigo: 'ALQ-0015',
    cliente: 'Juan Pérez',
    producto: 'Esmoquin Clásico', // <-- CAMBIO: Añadido
    fechaInicio: '15/07/24', // <-- CAMBIO: Añadido
    fechaDevolucion: '20/07/24',
    estado: AlquilerEstado.activo,
  ),
  const Alquiler(
    codigo: 'ALQ-0016',
    cliente: 'Carlos Sánchez',
    producto: 'Traje de Gala Azul', // <-- CAMBIO: Añadido
    fechaInicio: '10/07/24', // <-- CAMBIO: Añadido
    fechaDevolucion: '14/07/24',
    estado: AlquilerEstado.activo,
  ),
  const Alquiler(
    codigo: 'ALQ-0017',
    cliente: 'Miguel Rodríguez',
    producto: 'Frac Negro', // <-- CAMBIO: Añadido
    fechaInicio: '01/07/24', // <-- CAMBIO: Añadido
    fechaDevolucion: '05/07/24',
    estado: AlquilerEstado.atrasado, // "En Mora" en tu imagen
  ),
];

// ----- LISTA DE VENTAS ACTUALIZADA -----
final List<Venta> mockVentas = [
  const Venta(
    codigo: 'VEN-1021',
    producto: 'Traje Clásico Negro', // <-- CAMBIO: Añadido
    total: 'S/ 250.00',
    cliente: 'Daniel',
    fecha: '26 de Julio, 2024',
  ),
  const Venta(
    codigo: 'VEN-1020',
    producto: 'Esmoquin Moderno', // <-- CAMBIO: Añadido
    total: 'S/ 300.00',
    cliente: 'Sofia',
    fecha: '25 de Julio, 2024',
  ),
  const Venta(
    codigo: 'VEN-1019',
    producto: 'Traje de Lino Beige', // <-- CAMBIO: Añadido
    total: 'S/ 200.00',
    cliente: 'Mateo',
    fecha: '24 de Julio, 2024',
  ),
];

// --- (El resto de tus listas siguen igual) ---
// Datos para gestion_clientes_screen.dart
final List<Cliente> mockClientes = [
  const Cliente(nombre: 'Juan Pérez', dni: '12345678', telefono: '987654321'),
  const Cliente(nombre: 'María López', dni: '87654321', telefono: '912345678'),
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
