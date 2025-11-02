import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/data/mock_data.dart';
// Importa el modelo
import 'package:proyecto_tienda_ternos/models/alquiler.dart';

class GestionAlquileresScreen extends StatelessWidget {
  const GestionAlquileresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Función auxiliar para manejar el color y texto del enum
    Color estadoColor(AlquilerEstado e) {
      switch (e) {
        case AlquilerEstado.pendiente:
          return Colors.orange;
        case AlquilerEstado.atrasado:
          return Colors.red;
        default:
          return AppColors.primary;
      }
    }

    String estadoTexto(AlquilerEstado e) {
      switch (e) {
        case AlquilerEstado.pendiente:
          return 'Pendiente';
        case AlquilerEstado.atrasado:
          return 'Atrasado';
        default:
          return '';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Alquileres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/alquileres/nuevo');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: mockAlquileres.length,
          itemBuilder: (context, index) {
            // 'a' ahora es un objeto Alquiler
            final a = mockAlquileres[index];
            return Container(
              margin: EdgeInsets.only(
                bottom: index == mockAlquileres.length - 1 ? 0 : 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              child: ListTile(
                title: Text(
                  a.codigo, // <-- ANTES: a['codigo'] ?? ''
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  // <-- ANTES: 'Cliente: ${a['cliente']}\nDev: ${a['fechaDev']}'
                  'Cliente: ${a.cliente}\nDev: ${a.fechaDevolucion}',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.subtleDark
                        : AppColors.subtleLight,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      estadoTexto(a.estado), // <-- Usamos la función auxiliar
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: estadoColor(
                          a.estado,
                        ), // <-- Usamos la función auxiliar
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/alquileres/detalle');
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}
