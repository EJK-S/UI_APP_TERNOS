import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart'; // <-- 1. IMPORTAMOS LOS DATOS
import 'package:proyecto_tienda_ternos/models/cliente.dart';

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
              Navigator.pushNamed(context, '/clientes/nuevo');
            },
          ),
        ],
      ),
      body: SafeArea(
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
                // Fíjate que "c" ahora es un objeto Cliente
                children: mockClientes.map((c) {
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(.1),
                          foregroundColor: AppColors.primary,
                          child: const Icon(Icons.person),
                        ),
                        title: Text(
                          c.nombre, // <-- ANTES: c['nombre'] ?? ''
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          // <-- ANTES: 'DNI: ${c['dni']}   Tel: ${c['telefono']}'
                          'DNI: ${c.dni}   Tel: ${c.telefono}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? AppColors.subtleDark
                                : AppColors.subtleLight,
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'alquileres') {
                              Navigator.pushNamed(
                                context,
                                '/alquileres/detalle',
                              );
                            }
                            if (val == 'ventas') {
                              Navigator.pushNamed(context, '/ventas/detalle');
                            }
                            if (val == 'editar') {}
                            if (val == 'eliminar') {}
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
                      if (c != mockClientes.last)
                        Divider(
                          height: 1,
                          color: Theme.of(context).brightness == Brightness.dark
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
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 1),
    );
  }
}
