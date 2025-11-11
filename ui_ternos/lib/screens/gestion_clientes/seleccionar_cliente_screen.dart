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
    // Obtenemos la lista completa de clientes del provider
    final clienteProvider = Provider.of<ClienteProvider>(context);
    final List<Cliente> todosLosClientes = clienteProvider.clientes;

    // Filtramos la lista basándonos en el texto de búsqueda
    final List<Cliente> clientesFiltrados = todosLosClientes.where((cliente) {
      final nombreCompleto = '${cliente.nombre} ${cliente.apellidos ?? ''}'
          .toLowerCase();
      final dni = cliente.dni.toLowerCase();
      final busqueda = _filtro.toLowerCase();
      return nombreCompleto.contains(busqueda) || dni.contains(busqueda);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar Cliente')),
      body: SafeArea(
        child: Column(
          children: [
            // --- Barra de Búsqueda ---
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

            // --- Lista de Clientes ---
            Expanded(
              child: ListView.builder(
                itemCount: clientesFiltrados.length,
                itemBuilder: (context, index) {
                  final cliente = clientesFiltrados[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('${cliente.nombre} ${cliente.apellidos ?? ''}'),
                    subtitle: Text('DNI: ${cliente.dni}'),
                    onTap: () {
                      // --- ACCIÓN CLAVE ---
                      // Al tocar, cierra esta pantalla y DEVUELVE el objeto 'cliente'
                      Navigator.pop(context, cliente);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
