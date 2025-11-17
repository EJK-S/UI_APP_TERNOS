// lib/providers/cliente_provider.dart (VERSIÓN COMPLETA Y CORRECTA)

import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/data/repositories/cliente_repository.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';

class ClienteProvider extends ChangeNotifier {
  // 1. DEPENDENCIA: El repositorio
  final ClienteRepository _repository;

  // 2. ESTADO: La lista de clientes
  List<Cliente> _clientes = [];
  bool _isLoading = false;

  // 3. GETTERS: Formas públicas de LEER el estado
  List<Cliente> get clientes => _clientes;
  bool get isLoading => _isLoading;

  // 4. CONSTRUCTOR: (CORREGIDO)
  // La llamada a fetchClientes() se elimina de aquí y se mueve a main.dart
  ClienteProvider(this._repository);

  // 5. MÉTODOS ASÍNCRONOS

  // CORREGIDO: Añadida la "guardia" para evitar cargas duplicadas
  Future<void> fetchClientes() async {
    if (_clientes.isNotEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners(); // Avisa que está "cargando"

    // (Tu 'List.from' ya era correcto para evitar duplicados)
    _clientes = List.from(await _repository.getClientes());

    _isLoading = false;
    notifyListeners(); // Avisa que ya terminó de cargar
  }

  // (agregarCliente ya era correcto)
  Future<void> agregarCliente(Cliente nuevoCliente) async {
    final clienteAgregado = await _repository.agregarCliente(nuevoCliente);
    _clientes.add(clienteAgregado);
    notifyListeners();
  }

  // --- CORREGIDO: Usa 'id' para la comparación ---
  Future<void> editarCliente(Cliente clienteActualizado) async {
    // 1. Llama al repositorio (API)
    final clienteEditado = await _repository.editarCliente(clienteActualizado);

    // 2. Actualiza el estado local usando 'id'
    final index = _clientes.indexWhere(
      (c) => c.id == clienteEditado.id, // <-- CORREGIDO
    );
    if (index != -1) {
      _clientes[index] = clienteEditado;
      notifyListeners();
    }
  }

  // --- CORREGIDO: Usa 'id' para la lista local ---
  Future<void> eliminarCliente(Cliente clienteAEliminar) async {
    // 1. Llama al repositorio (API)
    // (Tu repositorio elimina por 'dni', lo cual está bien si esa es tu lógica de API)
    await _repository.eliminarCliente(clienteAEliminar.dni);

    // 2. Actualiza el estado local usando 'id' (más seguro)
    _clientes.removeWhere(
      (c) => c.id == clienteAEliminar.id, // <-- CORREGIDO
    );
    notifyListeners();
  }
}
