// lib/providers/cliente_provider.dart

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/cliente_repository.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';

class ClienteProvider extends ChangeNotifier {
  // 1. DEPENDENCIA: El repositorio
  final ClienteRepository _repository;

  // 2. ESTADO: La lista de clientes
  List<Cliente> _clientes = [];
  bool _isLoading = false; // (Opcional, pero bueno para el futuro)

  // 3. GETTERS: Formas públicas de LEER el estado
  List<Cliente> get clientes => _clientes;
  bool get isLoading => _isLoading;

  // 4. CONSTRUCTOR: Recibe el repositorio
  ClienteProvider(this._repository) {
    // Cuando el provider se crea, carga los clientes
    fetchClientes();
  }

  // 5. MÉTODOS ASÍNCRONOS (Ahora usan el repositorio)

  Future<void> fetchClientes() async {
    _isLoading = true;
    notifyListeners(); // Avisa que está "cargando"

    _clientes = await _repository.getClientes();
    _isLoading = false;
    notifyListeners(); // Avisa que ya terminó de cargar
  }

  Future<void> agregarCliente(Cliente nuevoCliente) async {
    // 1. Llama al repositorio (API)
    final clienteAgregado = await _repository.agregarCliente(nuevoCliente);

    // 2. Actualiza el estado local
    _clientes.add(clienteAgregado);
    notifyListeners();
  }

  Future<void> editarCliente(Cliente clienteActualizado) async {
    // 1. Llama al repositorio (API)
    final clienteEditado = await _repository.editarCliente(clienteActualizado);

    // 2. Actualiza el estado local
    final index = _clientes.indexWhere((c) => c.dni == clienteEditado.dni);
    if (index != -1) {
      _clientes[index] = clienteEditado;
      notifyListeners();
    }
  }

  Future<void> eliminarCliente(Cliente clienteAEliminar) async {
    // 1. Llama al repositorio (API)
    await _repository.eliminarCliente(clienteAEliminar.dni);

    // 2. Actualiza el estado local
    _clientes.removeWhere((c) => c.dni == clienteAEliminar.dni);
    notifyListeners();
  }
}
