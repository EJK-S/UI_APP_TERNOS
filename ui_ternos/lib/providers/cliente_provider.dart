import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';

class ClienteProvider extends ChangeNotifier {
  // 1. ESTADO: La lista de clientes (privada)
  // Nota: La copiamos de mockClientes para poder modificarla.
  final List<Cliente> _clientes = List.from(mockClientes);

  // 2. GETTER: La forma pública de LEER la lista
  List<Cliente> get clientes => _clientes;

  // 3. MÉTODOS: Las formas públicas de MODIFICAR la lista

  void agregarCliente(Cliente nuevoCliente) {
    _clientes.add(nuevoCliente);
    // Notificamos a los "oyentes" (la pantalla de lista) que hay un cambio
    notifyListeners();
  }

  void editarCliente(Cliente clienteActualizado) {
    // Buscamos al cliente en la lista por su DNI (que es un ID único)
    final index = _clientes.indexWhere((c) => c.dni == clienteActualizado.dni);

    if (index != -1) {
      // Si lo encontramos, lo reemplazamos en esa posición
      _clientes[index] = clienteActualizado;
      notifyListeners();
    }
  }

  void eliminarCliente(Cliente clienteAEliminar) {
    // Eliminamos al cliente de la lista (usando el DNI)
    _clientes.removeWhere((c) => c.dni == clienteAEliminar.dni);
    notifyListeners();
  }

  // (En el futuro, aquí llamarías a tu API de Node.js)
  // Future<void> fetchClientesFromAPI() { ... }
  // Future<void> postNuevoCliente(Cliente c) { ... }
  // Future<void> putClienteActualizado(Cliente c) { ... }
  // Future<void> deleteCliente(Cliente c) { ... }
}
