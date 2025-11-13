// lib/data/mock_data.dart (CORREGIDO)

import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';
// import 'package:proyecto_tienda_ternos/models/inventario_categoria.dart'; // Ya no se usa
// import 'package:proyecto_tienda_ternos/models/cita.dart'; // Ya no se usa
import 'package:proyecto_tienda_ternos/models/prenda.dart';

// ----- LISTA DE CLIENTES ACTUALIZADA (CON ID) -----
// (Estos datos ahora son la ÚNICA fuente simulada para los repositorios)

final List<Cliente> mockClientes = [
  const Cliente(
    id: 1, // <-- ID NUMÉRICO
    nombre: 'Juan',
    apellidos: 'Pérez',
    dni: '12345678',
    telefono: '987654321',
    correo: 'juan@correo.com',
    direccion: 'Av. Siempre Viva 123',
    fechaNacimiento: '15/05/1990',
    vetado: false,
    motivoVeto: '',
  ),
  const Cliente(
    id: 2, // <-- ID NUMÉRICO
    nombre: 'María',
    apellidos: 'López',
    dni: '87654321',
    telefono: '912345678',
    correo: 'maria@correo.com',
    direccion: 'Calle Falsa 456',
    fechaNacimiento: '20/10/1995',
    vetado: true,
    motivoVeto: 'No devolvió el traje a tiempo.',
  ),
  const Cliente(
    id: 3, // <-- ID NUMÉRICO
    nombre: 'Miguel',
    apellidos: 'Rodríguez',
    dni: '651354189',
    telefono: '958471236',
    correo: 'miguel@correo.com',
    direccion: 'Jr. Falso 789',
    fechaNacimiento: '01/02/1988',
    vetado: false,
    motivoVeto: '',
  ),
  const Cliente(
    id: 4, // <-- ID NUMÉRICO
    nombre: 'Alexander',
    apellidos: 'Tapia',
    dni: '28964165',
    telefono: '932165498',
    correo: 'otro@correo.com',
    direccion: 'Av. Inventada 101',
    fechaNacimiento: '10/11/2000',
    vetado: false,
    motivoVeto: '',
  ),
];

// ----- LISTA DE ALQUILERES ACTUALIZADA (CON clienteId numérico) -----
final List<Alquiler> mockAlquileres = [
  Alquiler(
    codigo: 'ALQ-0015',
    clienteId: 1, // Juan Pérez
    producto: 'Esmoquin Clásico',
    fechaInicio: DateTime(2024, 7, 15), // <-- CAMBIO: DateTime(YYYY, MM, DD)
    fechaDevolucion: DateTime(2024, 7, 20), // <-- CAMBIO
    estado: AlquilerEstado.activo,
    metodoPago: 'Tarjeta de Crédito',
    montoTotal: 'S/ 150',
    garantia: 'S/ 50',
  ),
  Alquiler(
    codigo: 'ALQ-0016',
    clienteId: 2, // María López
    producto: 'Traje de Gala Azul',
    fechaInicio: DateTime(2024, 7, 10), // <-- CAMBIO
    fechaDevolucion: DateTime(2024, 7, 14), // <-- CAMBIO
    estado: AlquilerEstado.activo,
    metodoPago: 'Yape - Plin',
    montoTotal: 'S/ 280',
    garantia: 'S/ 100',
  ),
  Alquiler(
    codigo: 'ALQ-0017',
    clienteId: 3, // Miguel Rodríguez
    producto: 'Frac Negro',
    fechaInicio: DateTime(2024, 7, 1), // <-- CAMBIO
    fechaDevolucion: DateTime(2024, 7, 5), // <-- CAMBIO
    estado: AlquilerEstado.atrasado,
    metodoPago: 'Efectivo',
    montoTotal: 'S/ 180',
    garantia: 'S/ 50',
  ),
];

// ----- LISTA DE VENTAS ACTUALIZADA (CON clienteId numérico) -----
final List<Venta> mockVentas = [
  Venta(
    codigo: 'VEN-1021',
    clienteId: 1, // Juan Pérez
    fecha: DateTime(2024, 7, 26), // <-- CAMBIO
    producto: 'Traje Clásico Negro',
    cantidad: 1,
    precioUnitario: 250.00,
    metodoPago: 'Tarjeta',
    total: 250.00,
  ),
  Venta(
    codigo: 'VEN-1020',
    clienteId: 2, // María López
    fecha: DateTime.now(), // <-- CAMBIO
    producto: 'Esmoquin Moderno',
    cantidad: 1,
    precioUnitario: 300.00,
    metodoPago: 'Yape-Plin',
    total: 300.00,
  ),
  Venta(
    codigo: 'VEN-1019',
    clienteId: 4, // Alexander Tapia
    fecha: DateTime(2024, 7, 24), // <-- CAMBIO
    producto: 'Traje de Lino Marrón',
    cantidad: 1,
    precioUnitario: 200.00,
    metodoPago: 'Efectivo',
    total: 200.00,
  ),
  Venta(
    codigo: 'VEN-1018',
    clienteId: 1, // Mostrador (asumiendo id 1)
    fecha: DateTime(2024, 7, 23), // <-- CAMBIO
    producto: 'Traje de Lino Beige',
    cantidad: 1,
    precioUnitario: 200.00,
    metodoPago: 'Efectivo',
    total: 200.00,
  ),
];

// --- mockCitas SE ELIMINA ---
// (Ahora se maneja dentro de 'cita_repository.dart')

// --- mockInventarioCategorias SE ELIMINA ---
// (Ahora se calcula automáticamente desde 'prenda_provider.dart')

// ----- LISTA DE PAGOS (Se mantiene igual por ahora) -----
final List<Pago> mockPagos = [
  const Pago(
    id: '#20240001',
    fecha: '15 de mayo, 2024',
    clienteId: 2, // <-- ID de María López (para 'VEN-1020')
    monto: 'S/ 550.00',
    tipo: TipoPago.Venta,
    metodo: MetodoPago.Tarjeta,
    transaccionId: 'VEN-1020',
  ),
  const Pago(
    id: '#20240002',
    fecha: '14 de mayo, 2024',
    clienteId: 1, // <-- ID de Juan Pérez (para 'ALQ-0015')
    monto: 'S/ 280.00',
    tipo: TipoPago.Alquiler,
    metodo: MetodoPago.Yape,
    transaccionId: 'ALQ-0015',
  ),
  const Pago(
    id: '#20240003',
    fecha: '13 de mayo, 2024',
    clienteId: 4, // <-- ID de Alexander Tapia (para 'VEN-1019')
    monto: 'S/ 150.00',
    tipo: TipoPago.Venta,
    metodo: MetodoPago.Efectivo,
    transaccionId: 'VEN-1019',
  ),
];

// ----- LISTA DE PRENDAS (Se mantiene igual, es la fuente del inventario) -----
final List<Prenda> mockPrendas = [
  // Trajes Clásicos (Total 22: 15 Disp, 5 Alq, 2 Mant)
  const Prenda(
    id: 'TC-001',
    nombre: 'Terno Clásico Negro',
    talla: 'M',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Disponible,
    usos: 5,
  ),
  const Prenda(
    id: 'TC-002',
    nombre: 'Terno Clásico Negro',
    talla: 'L',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Disponible,
    usos: 2,
  ),
  const Prenda(
    id: 'TC-003',
    nombre: 'Terno Clásico Azul',
    talla: 'M',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Disponible,
    usos: 3,
  ),
  // ... (Imagina 12 más disponibles) ...
  const Prenda(
    id: 'TC-016',
    nombre: 'Terno Clásico Gris',
    talla: 'S',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Alquilado,
    usos: 10,
  ),
  const Prenda(
    id: 'TC-017',
    nombre: 'Terno Clásico Gris',
    talla: 'M',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Alquilado,
    usos: 8,
  ),
  // ... (Imagina 3 más alquilados) ...
  const Prenda(
    id: 'TC-021',
    nombre: 'Terno Clásico Negro',
    talla: 'XL',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Mantenimiento,
    usos: 20,
  ),
  const Prenda(
    id: 'TC-022',
    nombre: 'Terno Clásico Azul',
    talla: 'L',
    categoria: 'Traje Clásico',
    estado: PrendaEstado.Mantenimiento,
    usos: 22,
  ),

  // Trajes de Gala (Total 12: 8 Disp, 3 Alq, 1 Mant)
  const Prenda(
    id: 'TG-001',
    nombre: 'Traje de Gala Azul',
    talla: 'M',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Disponible,
    usos: 1,
  ),
  // ... (Imagina 7 más disponibles) ...
  const Prenda(
    id: 'TG-009',
    nombre: 'Traje de Gala Negro',
    talla: 'L',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Alquilado,
    usos: 4,
  ),
  // ... (Imagina 2 más alquilados) ...
  const Prenda(
    id: 'TG-012',
    nombre: 'Traje de Gala Blanco',
    talla: 'M',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Mantenimiento,
    usos: 8,
  ),

  // (Nuevos productos que ahora sí aparecerán en los dropdowns)
  const Prenda(
    id: 'TLB-001',
    nombre: 'Traje de Lino Beige',
    talla: 'M',
    categoria: 'Traje de Verano',
    estado: PrendaEstado.Disponible,
    usos: 0,
  ),
  const Prenda(
    id: 'ESM-001',
    nombre: 'Esmoquin Moderno',
    talla: 'L',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Disponible,
    usos: 1,
  ),
  const Prenda(
    id: 'TLM-001',
    nombre: 'Traje de Lino Marrón',
    talla: 'M',
    categoria: 'Traje de Verano',
    estado: PrendaEstado.Disponible,
    usos: 0,
  ),
];
