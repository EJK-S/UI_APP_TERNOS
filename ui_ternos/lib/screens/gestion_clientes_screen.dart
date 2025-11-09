import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/screens/editar_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/screens/nuevo_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart'; // 👈 tu widget

class GestionClientesScreen extends StatefulWidget {
  const GestionClientesScreen({super.key});

  @override
  State<GestionClientesScreen> createState() => _GestionClientesScreenState();
}

class _GestionClientesScreenState extends State<GestionClientesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ClienteProvider>().cargarClientes());
  }

  Future<void> _refresh() => context.read<ClienteProvider>().cargarClientes();

  Future<void> _crearCliente() async {
    final nuevo = await Navigator.of(context).push<Cliente>(
      MaterialPageRoute(builder: (_) => const NuevoClienteScreen()),
    );
    if (nuevo != null && mounted) {
      await context.read<ClienteProvider>().agregarCliente(nuevo);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente creado')));
    }
  }

  Future<void> _editarCliente(Cliente c) async {
    final editado = await Navigator.of(context).push<Cliente>(
      MaterialPageRoute(builder: (_) => EditarClienteScreen(cliente: c)),
    );
    if (editado != null && mounted) {
      await context.read<ClienteProvider>().actualizarCliente(editado);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente actualizado')));
    }
  }

  Future<void> _eliminarCliente(Cliente c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text('¿Seguro que deseas eliminar a "${c.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<ClienteProvider>().eliminarCliente(c);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cliente eliminado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClienteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),

      // 👇 vuelve tu navegación inferior
      bottomNavigationBar: const MainBottomNav(
        currentIndex: 1, // 0 = Clientes (ajusta si tu orden es otro)
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _crearCliente,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Agregar'),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (_) {
            if (prov.cargando) {
              return const Center(child: CircularProgressIndicator());
            }
            if (prov.error != null) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text(prov.error!)),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ),
                ],
              );
            }
            if (prov.clientes.isEmpty) {
              return ListView(
                padding: const EdgeInsets.only(
                  top: 120,
                  bottom: kBottomNavigationBarHeight + 88, // evita solape
                ),
                children: const [Center(child: Text('No hay clientes aún'))],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(
                bottom:
                    kBottomNavigationBarHeight +
                    88, // evita solape con bottom nav + FAB
              ),
              itemCount: prov.clientes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = prov.clientes[i];
                return Dismissible(
                  key: ValueKey('cliente-${c.id ?? c.dni}'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    await _eliminarCliente(c);
                    return false; // manejamos nosotros el borrado
                  },
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(c.nombre),
                    subtitle: Text('DNI: ${c.dni}  •  Tel: ${c.telefono}'),
                    onTap: () => _editarCliente(c),

                    // 👇 botones explícitos de editar / eliminar
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Editar',
                          onPressed: () => _editarCliente(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Eliminar',
                          onPressed: () => _eliminarCliente(c),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
