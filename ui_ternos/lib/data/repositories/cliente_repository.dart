// lib/data/repositories/cliente_repository.dart
/*
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';

// --- (En el futuro, aquí importarías 'package:http/http.dart' as http) ---

class ClienteRepository {
  // Lista temporal que simula la base de datos
  // La copiamos de mockClientes para poder modificarla.
  //final List<Cliente> _clientesDB = List.from();

  // --- AÑADIDO: Simula el AUTO_INCREMENT ---
  int _nextClienteId = 5; // (Porque mockClientes tiene 4)

  // MÉTODO 1: Obtener todos los clientes
  Future<List<Cliente>> getClientes() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _clientesDB;
  }

  // --- CORREGIDO: Lógica de agregarCliente ---
  Future<Cliente> agregarCliente(Cliente nuevoCliente) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Simula la asignación de ID por la BD
    final clienteConId = Cliente(
      id: _nextClienteId++, // <-- Asigna el nuevo ID
      nombres: nuevoCliente.nombres,
      apellidos: nuevoCliente.apellidos,
      dni: nuevoCliente.dni,
      celular: nuevoCliente.celular,
      //correo: nuevoCliente.correo,
      direccion: nuevoCliente.direccion,
      fechaNac: nuevoCliente.fechaNac,
      vetado: nuevoCliente.vetado,
      motivoVeto: nuevoCliente.motivoVeto,
    );

    _clientesDB.add(clienteConId);
    return clienteConId; // Devuelve el cliente CON el ID
  }

  Future<Cliente> editarCliente(Cliente clienteActualizado) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // La edición requiere un ID, así que usamos '!'
    final index = _clientesDB.indexWhere((c) => c.id == clienteActualizado.id!);
    if (index != -1) {
      _clientesDB[index] = clienteActualizado;
      return clienteActualizado;
    } else {
      throw Exception('Cliente no encontrado');
    }
  }

  Future<void> eliminarCliente(String dni) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // (La eliminación por DNI puede seguir funcionando si es un requisito)
    _clientesDB.removeWhere((c) => c.dni == dni);
  }
}
*/
