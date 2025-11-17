// lib/data/mock_data.dart (CORREGIDO CON prendaId)

import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';

// ----- LISTA DE CLIENTES (Estaba correcta) -----
final List<Cliente> mockClientes = [
  const Cliente(
    id: 1,
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
    id: 2,
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
    id: 3,
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
    id: 4,
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

// ----- LISTA DE ALQUILERES (CORREGIDA CON prendaId) -----
final List<Alquiler> mockAlquileres = [
  Alquiler(
    codigo: 'ALQ-0015',
    clienteId: 1, // Juan Pérez
    producto: 'Esmoquin Clásico',
    prendaId:
        'ESM-001', // <-- AÑADIDO (Debe coincidir con un ID de mockPrendas)
    fechaInicio: DateTime(2024, 7, 15),
    fechaDevolucion: DateTime(2024, 7, 20),
    estado: AlquilerEstado.activo,
    metodoPago: 'Tarjeta de Crédito',
    montoTotal: 'S/ 150',
    garantia: 'S/ 50',
  ),
  Alquiler(
    codigo: 'ALQ-0016',
    clienteId: 2, // María López
    producto: 'Traje de Gala Azul',
    prendaId: 'TG-001', // <-- AÑADIDO
    fechaInicio: DateTime(2024, 7, 10),
    fechaDevolucion: DateTime(2024, 7, 14),
    estado: AlquilerEstado.activo,
    metodoPago: 'Yape - Plin',
    montoTotal: 'S/ 280',
    garantia: 'S/ 100',
  ),
  Alquiler(
    codigo: 'ALQ-0017',
    clienteId: 3, // Miguel Rodríguez
    producto: 'Frac Negro',
    prendaId: 'TG-009', // <-- AÑADIDO (Asignado a 'Traje de Gala Negro')
    fechaInicio: DateTime(2024, 7, 1),
    fechaDevolucion: DateTime(2024, 7, 5),
    estado: AlquilerEstado.atrasado,
    metodoPago: 'Efectivo',
    montoTotal: 'S/ 180',
    garantia: 'S/ 50',
  ),
];

// ----- LISTA DE VENTAS (CORREGIDA CON prendaId) -----
final List<Venta> mockVentas = [
  Venta(
    codigo: 'VEN-1021',
    clienteId: 1, // Juan Pérez
    fecha: DateTime(2024, 7, 26),
    producto: 'Traje Clásico Negro',
    prendaId: 'TC-001', // <-- AÑADIDO
    cantidad: 1,
    precioUnitario: 250.00,
    metodoPago: 'Tarjeta',
    total: 250.00,
  ),
  Venta(
    codigo: 'VEN-1020',
    clienteId: 2, // María López
    fecha: DateTime.now(),
    producto: 'Esmoquin Moderno',
    prendaId: 'ESM-001', // <-- AÑADIDO
    cantidad: 1,
    precioUnitario: 300.00,
    metodoPago: 'Yape-Plin',
    total: 300.00,
  ),
  Venta(
    codigo: 'VEN-1019',
    clienteId: 4, // Alexander Tapia
    fecha: DateTime(2024, 7, 24),
    producto: 'Traje de Lino Marrón',
    prendaId: 'TLM-001', // <-- AÑADIDO
    cantidad: 1,
    precioUnitario: 200.00,
    metodoPago: 'Efectivo',
    total: 200.00,
  ),
  Venta(
    codigo: 'VEN-1018',
    clienteId: 1, // Mostrador (asumiendo id 1)
    fecha: DateTime(2024, 7, 23),
    producto: 'Traje de Lino Beige',
    prendaId: 'TLB-001', // <-- AÑADIDO
    cantidad: 1,
    precioUnitario: 200.00,
    metodoPago: 'Efectivo',
    total: 200.00,
  ),
];

// (Comentarios de Citas e Inventario - correctos)

// ----- LISTA DE PAGOS (CORREGIDA CON ';') -----
final List<Pago> mockPagos = [
  Pago(
    id: '#20240001',
    fecha: DateTime(2024, 5, 15),
    clienteId: 2, // María López
    monto: 'S/ 300.00',
    tipo: TipoPago.Venta,
    metodo: 'Yape-Plin',
    transaccionId: 'VEN-1020',
  ),
  Pago(
    id: '#20240002',
    fecha: DateTime(2024, 5, 14),
    clienteId: 1, // Juan Pérez
    monto: 'S/ 150.00',
    tipo: TipoPago.Alquiler,
    metodo: 'Tarjeta de Crédito',
    transaccionId: 'ALQ-0015',
  ),
  Pago(
    id: '#20240003',
    fecha: DateTime(2024, 5, 13),
    clienteId: 4, // Alexander Tapia
    monto: 'S/ 200.00',
    tipo: TipoPago.Venta,
    metodo: 'Efectivo',
    transaccionId: 'VEN-1019',
  ),
]; // <-- AÑADIDO EL PUNTO Y COMA

// ----- LISTA DE PRENDAS (Estaba correcta) -----
final List<Prenda> mockPrendas = [
  // ... (tu lista de prendas es correcta)
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
  const Prenda(
    id: 'TG-001',
    nombre: 'Traje de Gala Azul',
    talla: 'M',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Disponible,
    usos: 1,
  ),
  const Prenda(
    id: 'TG-009',
    nombre: 'Traje de Gala Negro',
    talla: 'L',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Alquilado,
    usos: 4,
  ),
  const Prenda(
    id: 'TG-012',
    nombre: 'Traje de Gala Blanco',
    talla: 'M',
    categoria: 'Traje de Gala',
    estado: PrendaEstado.Mantenimiento,
    usos: 8,
  ),
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
