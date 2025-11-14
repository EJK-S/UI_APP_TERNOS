// lib/screens/gestion_clientes/gestion_clientes_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'editar_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes/nuevo_cliente_screen.dart';

class GestionClientesScreen extends StatefulWidget {
  const GestionClientesScreen({super.key});

  @override
  State<GestionClientesScreen> createState() => _GestionClientesScreenState();
}

class _GestionClientesScreenState extends State<GestionClientesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        context.read<ClienteProvider>().cargarClientes();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refrescar(BuildContext context) async {
    await context.read<ClienteProvider>().cargarClientes();
  }

  // ⬇️ AHORA solo refresca el widget, el filtro es local
  void _onSearchChanged(String value) {
    setState(() {});
  }

  Future<void> _confirmarEliminar(BuildContext context, Cliente c) async {
    if (c.id == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Seguro que deseas eliminar a "${c.nombres} ${c.apellidos}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final prov = context.read<ClienteProvider>();
    final eliminado = await prov.eliminarCliente(c.id!.toString());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          eliminado
              ? 'Cliente eliminado correctamente.'
              : 'Ocurrió un error al eliminar.',
        ),
      ),
    );
  }

  Future<void> _cambiarVeto(BuildContext context, Cliente c) async {
    final TextEditingController motivoCtrl = TextEditingController(
      text: c.motivoVeto ?? '',
    );

    final bool vetar = !c.vetado;

    if (vetar) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Vetado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Establece un motivo de veto para este cliente:'),
              const SizedBox(height: 12),
              TextField(
                controller: motivoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Motivo de veto',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (motivoCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('El motivo de veto es obligatorio.'),
                    ),
                  );
                  return;
                }
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      );

      if (ok != true) return;
    } else {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Quitar veto'),
          content: const Text(
            '¿Seguro que deseas quitar el veto a este cliente?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Quitar veto'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      motivoCtrl.text = '';
    }

    final prov = context.read<ClienteProvider>();
    final actualizado = await prov.actualizarVeto(
      c,
      vetar,
      motivoCtrl.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          actualizado
              ? (vetar
                    ? 'Cliente vetado correctamente.'
                    : 'Veto retirado correctamente.')
              : 'No se pudo actualizar el estado de veto.',
        ),
      ),
    );
  }

  void _irANuevoCliente() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NuevoClienteScreen()));
  }

  void _irAEditarCliente(Cliente c) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditarClienteScreen(cliente: c)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),

      bottomNavigationBar: const MainBottomNav(currentIndex: 1),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irANuevoCliente,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo cliente'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refrescar(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre, DNI o celular',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: Consumer<ClienteProvider>(
                builder: (context, prov, _) {
                  if (prov.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (prov.error != null && prov.error!.isNotEmpty) {
                    return Center(
                      child: Text(
                        prov.error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  // ⬇️ FILTRO LOCAL
                  final query = _searchController.text.trim().toLowerCase();

                  final baseList = prov.clientes;
                  final List<Cliente> clientes = query.isEmpty
                      ? baseList
                      : baseList.where((c) {
                          final nombreCompleto = '${c.nombres} ${c.apellidos}'
                              .toLowerCase();
                          final dni = c.dni.toLowerCase();
                          final celular = c.celular.toLowerCase();
                          return nombreCompleto.contains(query) ||
                              dni.contains(query) ||
                              celular.contains(query);
                        }).toList();

                  if (clientes.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron clientes.'),
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: clientes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final c = clientes[index];

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Primera fila: nombre + chip vetado
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${c.nombres} ${c.apellidos}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  if (c.vetado)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.block,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Vetado',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Datos básicos
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  _InfoChip(
                                    icon: Icons.badge_outlined,
                                    label: 'DNI:',
                                    value: c.dni,
                                  ),
                                  _InfoChip(
                                    icon: Icons.phone_outlined,
                                    label: 'Celular:',
                                    value: c.celular,
                                  ),
                                  if (c.direccion != null &&
                                      c.direccion!.trim().isNotEmpty)
                                    _InfoChip(
                                      icon: Icons.location_on_outlined,
                                      label: 'Dirección:',
                                      value: c.direccion!,
                                    ),
                                ],
                              ),
                              if (c.motivoVeto != null &&
                                  c.motivoVeto!.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Motivo veto: ${c.motivoVeto}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Botones de acción
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _cambiarVeto(context, c),
                                    icon: Icon(
                                      c.vetado ? Icons.lock_open : Icons.block,
                                    ),
                                    label: Text(
                                      c.vetado ? 'Quitar veto' : 'Vetarlo',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton.icon(
                                    onPressed: () => _irAEditarCliente(c),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Editar'),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton.icon(
                                    onPressed: c.id == null
                                        ? null
                                        : () => _confirmarEliminar(context, c),
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Eliminar'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 2),
        Text(value, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
