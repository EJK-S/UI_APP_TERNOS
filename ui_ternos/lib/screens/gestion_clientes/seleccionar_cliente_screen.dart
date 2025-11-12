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
    // --- 4. LÓGICA DE FILTRADO CORREGIDA ---
    final List<Cliente> clientesFiltrados = todosLosClientes.where((cliente) {
      final nombreCompleto = '${cliente.nombre} ${cliente.apellidos ?? ''}'
          .toLowerCase();

      // CORRECCIÓN: Usar 'cliente.dni' (String) en lugar de 'cliente.id' (int?)
      final dni = cliente.dni.toLowerCase();

      final busqueda = _filtro.toLowerCase();
      return nombreCompleto.contains(busqueda) || dni.contains(busqueda);
    }).toList();

    if (clientesFiltrados.isEmpty) {
      return const Center(child: Text('No se encontraron clientes.'));
    }

    return ListView.builder(
      itemCount: clientesFiltrados.length,
      itemBuilder: (context, index) {
        final cliente = clientesFiltrados[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text('${cliente.nombre} ${cliente.apellidos ?? ''}'),
          // (Tu subtítulo ya era correcto)
          subtitle: Text('DNI: ${cliente.dni}'),
          onTap: () {
            // Devuelve el objeto 'cliente' completo
            Navigator.pop(context, cliente);
          },
        );
      },
    );
  }
}
