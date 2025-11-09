import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/pago.dart';
import 'package:proyecto_tienda_ternos/models/inventario_categoria.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/models/prenda.dart';

// ----- LISTA DE ALQUILERES ACTUALIZADA -----
final List<Alquiler> mockAlquileres = [
  const Alquiler(
    codigo: 'ALQ-0015',
    clienteId: '12345678', // <-- ID de Juan Pérez
    producto: 'Esmoquin Clásico',
    fechaInicio: '15/07/24',
    fechaDevolucion: '20/07/24',
    estado: AlquilerEstado.activo,
    metodoPago: 'Tarjeta de Crédito',
    montoTotal: 'S/ 150',
    garantia: 'S/ 50',
  ),
  const Alquiler(
    codigo: 'ALQ-0016',
    clienteId: '87654321', // <-- ID de María López
    producto: 'Traje de Gala Azul',
    fechaInicio: '10/07/24',
    fechaDevolucion: '14/07/24',
    estado: AlquilerEstado.activo,
    metodoPago: 'Yape - Plin',
    montoTotal: 'S/ 280',
    garantia: 'S/ 100',
  ),

  // ... (otros alquileres)
  const Alquiler(
    codigo: 'ALQ-0017',
    clienteId: '651354189', //<-- ID de Miguel Rodríguez
    producto: 'Frac Negro',
    fechaInicio: '01/07/24',
    fechaDevolucion: '05/07/24',
    estado: AlquilerEstado.atrasado, // "En Mora"
    // --- Datos nuevos ---
    metodoPago: 'Efectivo',
    montoTotal: 'S/ 180',
    garantia: 'S/ 50',
  ),
];

// ----- LISTA DE VENTAS ACTUALIZADA -----
final List<Venta> mockVentas = [
  const Venta(
    codigo: 'VEN-1021',
    clienteId: '12345678', // <-- ID de Juan Pérez
    fecha: '26 de Julio, 2024',
    producto: 'Traje Clásico Negro',
    cantidad: 1,
    precioUnitario: 250.00,
    metodoPago: 'Tarjeta',
    total: 250.00,
  ),
  const Venta(
    codigo: 'VEN-1020',
    clienteId: '87654321', // <-- ID de María López
    fecha: '25 de Julio, 2024',
    producto: 'Esmoquin Moderno',
    cantidad: 1,
    precioUnitario: 300.00,
    metodoPago: 'Yape-Plin',
    total: 300.00,
  ),
  const Venta(
    codigo: 'VEN-1019',
    clienteId: '28964165', // <-- ID de Otro tipazo
    fecha: '24 de Julio, 2024',
    producto: 'Traje de Lino Marrón',
    cantidad: 1,
    precioUnitario: 200.00,
    metodoPago: 'Efectivo',
    total: 200.00,
  ),
];

// --- (El resto de tus listas siguen igual) ---
// Datos para gestion_clientes_screen.dart
final List<Cliente> mockClientes = [
  const Cliente(
    nombre: 'Juan', // <-- Ahora solo el nombre
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
    nombre: 'María', // <-- Ahora solo el nombre
    apellidos: 'López',
    dni: '87654321',
    telefono: '912345678',
    correo: 'maria@correo.com',
    direccion: 'Calle Falsa 456',
    fechaNacimiento: '20/10/1995',
    vetado: true,
    motivoVeto: 'No devolvió el traje a tiempo.',
  ),
];

final List<Pago> mockPagos = [
  const Pago(
    id: '#20240001',
    fecha: '15 de mayo, 2024',
    cliente: 'Sofia Ramirez', // (Este modelo aún no lo hemos refactorizado)
    monto: 'S/ 550.00',
    tipo: TipoPago.Venta,
    metodo: MetodoPago.Tarjeta,
    transaccionId: 'VEN-1020',
  ),
  const Pago(
    id: '#20240002',
    fecha: '14 de mayo, 2024',
    cliente: 'Juan Pérez', // (Este modelo aún no lo hemos refactorizado)
    monto: 'S/ 280.00',
    tipo: TipoPago.Alquiler,
    metodo: MetodoPago.Yape,
    transaccionId: 'ALQ-0015',
  ),

  const Pago(
    id: '#20240003',
    fecha: '13 de mayo, 2024',
    cliente: 'Carlos Sánchez',
    monto: 'S/ 150.00',
    tipo: TipoPago.Venta,
    metodo: MetodoPago.Efectivo,
    transaccionId: 'VEN-1019',
  ),
];

// Datos para inventario_ternos_screen.dart
final List<InventarioCategoria> mockInventarioCategorias = [
  const InventarioCategoria(
    nombre: 'Traje Clásico',
    disponibles: 15,
    alquilados: 5,
    mantenimiento: 2,
  ),
  const InventarioCategoria(
    nombre: 'Traje de Gala',
    disponibles: 8,
    alquilados: 3,
    mantenimiento: 1,
  ),
  const InventarioCategoria(
    nombre: 'Traje de Verano',
    disponibles: 12,
    alquilados: 6,
    mantenimiento: 0,
  ),
  const InventarioCategoria(
    nombre: 'Traje de Invierno',
    disponibles: 5,
    alquilados: 1,
    mantenimiento: 3,
  ),
];

final List<Cita> mockCitas = [
  const Cita(
    tipo: CitaTipo.Alquiler,
    clienteId: '12345678', // <-- ID de Juan Pérez
    prendasResumen: 'Prendas: Terno Negro, Zapatos, Camisa',
    fecha: '15 de Oct, 2024',
    hora: '10:00 AM',
    estado: CitaEstado.Pendiente,
    prendaDetalleNombre: 'Terno Clásico Azul Marino',
    prendaDetalleId: 'T-00123',
  ),
  const Cita(
    tipo: CitaTipo.Prueba,
    clienteId: '87654321', // <-- ID de María López
    prendasResumen: 'Prendas: Terno Azul, Corbatín',
    fecha: '15 de Oct, 2024',
    hora: '02:30 PM',
    estado: CitaEstado.Pendiente,
    prendaDetalleNombre: 'Terno Azul',
    prendaDetalleId: 'T-00124',
  ),
  const Cita(
    tipo: CitaTipo.Devolucion,
    clienteId: '35486153', // <-- ID de Carlos Mendoza
    prendasResumen: 'Prendas: Terno Gris',
    fecha: '16 de Oct, 2024',
    hora: '11:00 AM',
    estado: CitaEstado.Pendiente,
    prendaDetalleNombre: 'Terno Gris',
    prendaDetalleId: 'T-00105',
  ),
];

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

  // (Y así para las otras categorías...)
];
