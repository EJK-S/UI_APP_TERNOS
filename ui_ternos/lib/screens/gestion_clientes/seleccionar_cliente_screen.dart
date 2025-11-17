// lib/screens/gestion_clientes/seleccionar_cliente_screen.dart (CORREGIDO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';

class SeleccionarClienteScreen extends StatefulWidget {
  const SeleccionarClienteScreen({super.key});

  @override
  State<SeleccionarClienteScreen> createState() =>
      _SeleccionarClienteScreenState();
}

class _SeleccionarClienteScreenState extends State<SeleccionarClienteScreen> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el provider (con 'watch' para reaccionar a los cambios)
    final clienteProvider = context.watch<ClienteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Cliente')),
      body: SafeArea(
        child: Column(
          children: [
            // --- Barra de Búsqueda (Sin cambios) ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o DNI...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _filtro = value;
                  });
                },
              ),
            ),

            // --- 2. MANEJAR ESTADO DE CARGA ---
            Expanded(
              child: clienteProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildListaClientes(clienteProvider.clientes),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. WIDGET AUXILIAR PARA LA LISTA (Más limpio) ---
  Widget _buildListaClientes(List<Cliente> todosLosClientes) {
    final List<Cliente> clientesFiltrados = todosLosClientes.where((cliente) {
      final nombreCompleto = '${cliente.nombre} ${cliente.apellidos ?? ''}'
          .toLowerCase();
      final dni = cliente.dni.toLowerCase();
      final busqueda = _filtro.toLowerCase();
      return nombreCompleto.contains(busqueda) || dni.contains(busqueda);
    }).toList();

    if (clientesFiltrados.isEmpty) {
      return const Center(child: Text('No se encontraron clientes.'));
    }

    // --- CORRECCIÓN DE LÓGICA DE VETO (RN-21) ---
    return ListView.builder(
      itemCount: clientesFiltrados.length,
      itemBuilder: (context, index) {
        final cliente = clientesFiltrados[index];
        final bool estaVetado = cliente.vetado ?? false; // 1. Chequear estado

        return ListTile(
          // 2. Modificación Visual
          leading: CircleAvatar(
            backgroundColor: estaVetado
                ? Colors.red.shade100
                : Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(
              estaVetado ? Icons.block : Icons.person, // Icono de bloqueo
              color: estaVetado
                  ? Colors.red.shade700
                  : Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            '${cliente.nombre} ${cliente.apellidos ?? ''}',
            style: TextStyle(
              // Texto gris y cursiva si está vetado
              color: estaVetado ? Colors.grey.shade600 : null,
              fontStyle: estaVetado ? FontStyle.italic : FontStyle.normal,
              decoration: estaVetado ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            estaVetado
                ? 'CLIENTE VETADO (Motivo: ${cliente.motivoVeto ?? 'N/A'})'
                : 'DNI: ${cliente.dni}',
            style: TextStyle(
              color: estaVetado ? Colors.red.shade700 : null,
              fontSize: 12,
            ),
          ),

          // 3. Lógica de Negocio (RN-21)
          onTap:
              estaVetado // Si el cliente está vetado...
              ? () {
                  // ...mostrar un mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Este cliente está vetado y no puede realizar nuevos alquileres.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              : () {
                  // ...si no, devolver el cliente
                  Navigator.pop(context, cliente);
                },
        );
      },
    );
  }
}
