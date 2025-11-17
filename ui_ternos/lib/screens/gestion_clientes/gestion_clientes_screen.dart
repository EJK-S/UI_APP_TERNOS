// lib/screens/gestion_clientes_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORTAMOS PROVIDER
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart'; // <-- 2. IMPORTAMOS EL CEREBRO
// import 'package:proyecto_tienda_ternos/data/mock_data.dart'; // <-- 3. YA NO NECESITAMOS MOCK_DATA
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_clientes/editar_cliente_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_alquiler/gestion_alquileres_screen.dart';
import 'package:proyecto_tienda_ternos/screens/gestion_ventas/gestion_ventas_screen.dart';

class GestionClientesScreen extends StatefulWidget {
  const GestionClientesScreen({super.key});
  @override
  State<GestionClientesScreen> createState() => _GestionClientesScreenState();
}

class _GestionClientesScreenState extends State<GestionClientesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () {
              // Navegamos a la pantalla de crear nuevo cliente
              // (Esta pantalla la actualizaremos en el siguiente paso)
              Navigator.pushNamed(context, '/clientes/nuevo');
            },
          ),
        ],
      ),
      // 5. USAMOS UN CONSUMER PARA "ESCUCHAR" CAMBIOS EN LA LISTA
      body: Consumer<ClienteProvider>(
        builder: (context, clienteProvider, child) {
          // --- ¡NUEVA LÓGICA DE CARGA! ---
          if (clienteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- FIN DE LA LÓGICA DE CARGA ---

          // 6. Obtenemos la lista "viva" desde el provider
          final List<Cliente> clientes = clienteProvider.clientes;

          // (Opcional: un buen 'fallback' si la lista está vacía)
          if (clientes.isEmpty) {
            return const Center(child: Text('No hay clientes registrados.'));
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Buscar cliente por nombre o DNI',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: clientes.map((c) {
                      // <-- 7. Usamos la lista del provider
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                .1,
                              ),
                              foregroundColor: AppColors.primary,
                              child: const Icon(Icons.person),
                            ),
                            title: Text(
                              '${c.nombre} ${c.apellidos ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              'DNI: ${c.id}   Tel: ${c.telefono}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.subtleDark
                                    : AppColors.subtleLight,
                              ),
                            ),
                            // --- 8. LÓGICA DEL MENÚ DE OPCIONES ACTUALIZADA ---
                            trailing: PopupMenuButton<String>(
                              onSelected: (val) {
                                // 'c' es la variable del cliente (ej. Cliente(nombre: 'Juan Pérez', ...))

                                if (val == 'alquileres') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GestionAlquileresScreen(
                                        // --- CORREGIDO: Pasar el nombre completo ---
                                        filtroClienteNombre:
                                            '${c.nombre} ${c.apellidos ?? ''}',
                                      ),
                                    ),
                                  );
                                }

                                if (val == 'ventas') {
                                  // --- 2. NAVEGACIÓN CORREGIDA ---
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GestionVentasScreen(
                                        filtroClienteNombre:
                                            '${c.nombre} ${c.apellidos ?? ''}', // <-- Le pasamos el nombre
                                      ),
                                    ),
                                  );
                                }

                                if (val == 'editar') {
                                  // (Esta navegación ya estaba bien)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditarClienteScreen(cliente: c),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                }

                                if (val == 'eliminar') {
                                  // (Esta lógica ya estaba bien)
                                  clienteProvider.eliminarCliente(c);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${c.nombre} eliminado.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'alquileres',
                                  child: Text('Ver alquileres'),
                                ),
                                const PopupMenuItem(
                                  value: 'ventas',
                                  child: Text('Ver compras'),
                                ),
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Text('Editar cliente'),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Text('Eliminar cliente'),
                                ),
                              ],
                            ),
                          ),
                          if (c !=
                              clientes
                                  .last) // <-- 9. Usamos la lista del provider
                            Divider(
                              height: 1,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }
}
