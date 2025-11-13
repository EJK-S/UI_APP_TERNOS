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
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ClienteProvider>().cargarClientes());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _buscar() {
    context.read<ClienteProvider>().cargarClientes(search: _searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClienteProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar cliente'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _buscar(),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    _buscar();
                  },
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: prov.clientes.length,
              itemBuilder: (_, i) {
                final c = prov.clientes[i];
                return ListTile(
                  title: Text('${c.nombres} ${c.apellidos}'),
                  subtitle: Text('DNI: ${c.dni}  •  Cel: ${c.celular}'),
                  onTap: () => Navigator.pop<Cliente>(context, c),
                );
              },
            ),
    );
  }
}
