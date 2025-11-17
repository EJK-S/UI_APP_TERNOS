// lib/screens/panel_control/panel_administracion_screen.dart (ACTUALIZADO)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// --- 1. IMPORTAR LOS PROVIDERS Y MODELOS NECESARIOS ---
import 'package:proyecto_tienda_ternos/models/alquiler.dart';
import 'package:proyecto_tienda_ternos/models/venta.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/alquiler_provider.dart';
import 'package:proyecto_tienda_ternos/providers/venta_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';
// ---
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/widgets/main_bottom_nav.dart';
import 'package:proyecto_tienda_ternos/widgets/quick_action_card.dart';
import 'package:proyecto_tienda_ternos/widgets/summary_stat_card.dart';

class PanelAdministracionScreen extends StatelessWidget {
  const PanelAdministracionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // --- ACCESOS RÁPIDOS (Sin cambios) ---
            Text(
              'Accesos Rápidos',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                QuickActionCard(
                  icon: Icons.shopping_cart,
                  label: 'Alquiler',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.gestionAlquileres);
                  },
                ),
                QuickActionCard(
                  icon: Icons.sell,
                  label: 'Venta',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.gestionVentas);
                  },
                ),
                QuickActionCard(
                  icon: Icons.inventory_2,
                  label: 'Inventario',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.inventario);
                  },
                ),
                QuickActionCard(
                  icon: Icons.pending_actions,
                  label: 'Citas Pendientes',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.citasPendientes);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- SECCIÓN DE RESUMEN (Sin cambios) ---
            Text(
              'Resumen',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Consumer2<AlquilerProvider, VentaProvider>(
              builder: (context, alquilerProvider, ventaProvider, child) {
                // ... (Tu lógica de 'isLoading' y cálculos de 'alquileresActivos',
                // 'devolucionesPendientes' y 'ventasHoy' va aquí... esta parte ya era correcta)

                // (Me aseguro de que el código esté completo)
                if (alquilerProvider.isLoading || ventaProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final alquileresActivos = alquilerProvider.alquileres
                    .where((a) => a.estado != AlquilerEstado.pendiente)
                    .length;

                final devolucionesPendientes = alquilerProvider.alquileres
                    .where((a) => a.estado == AlquilerEstado.atrasado)
                    .length;

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                final double ventasHoy = ventaProvider.ventas
                    .where((venta) {
                      final ventaDate = DateTime(
                        venta.fecha.year,
                        venta.fecha.month,
                        venta.fecha.day,
                      );
                      return ventaDate.isAtSameMomentAs(today);
                    })
                    .fold(0.0, (sum, venta) => sum + venta.total);

                final currencyFormatter = NumberFormat.currency(
                  locale: 'es_PE',
                  symbol: 'S/ ',
                  decimalDigits: 2,
                );

                return Column(
                  children: [
                    SummaryStatCard(
                      title: 'Alquileres activos',
                      value: alquileresActivos.toString(),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 12),
                    SummaryStatCard(
                      title: 'Devoluciones pendientes (En Mora)',
                      value: devolucionesPendientes.toString(),
                      icon: Icons.watch_later,
                    ),
                    const SizedBox(height: 12),
                    SummaryStatCard(
                      title: 'Ventas totales del día',
                      value: currencyFormatter.format(ventasHoy),
                      icon: Icons.paid,
                    ),
                  ],
                );
              },
            ),

            // --- 2. SECCIÓN "CITAS DEL DÍA" (RF-37) ---
            const SizedBox(height: 24),
            Text(
              'Citas para Hoy',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _CitasDelDiaCard(), // <-- NUEVO WIDGET
            // --- 3. SECCIÓN "PRÓXIMOS CUMPLEAÑOS" (RF-015) ---
            const SizedBox(height: 24),
            Text(
              'Próximos Cumpleaños (7 días)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _ProximosCumpleanosCard(), // <-- NUEVO WIDGET
          ],
        ),
      ),
      bottomNavigationBar: const MainBottomNav(currentIndex: 0),
    );
  }
}

// --- 4. WIDGET AUXILIAR PARA "CITAS DEL DÍA" (RF-37) ---
class _CitasDelDiaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Consumer2<CitaProvider, ClienteProvider>(
      builder: (context, citaProvider, clienteProvider, child) {
        if (citaProvider.isLoading || clienteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Filtra las citas
        final List<Cita> citasDeHoy = citaProvider.citas.where((cita) {
          final citaDate = DateTime(
            cita.fechaHora.year,
            cita.fechaHora.month,
            cita.fechaHora.day,
          );
          return cita.estado == CitaEstado.Pendiente &&
              citaDate.isAtSameMomentAs(today);
        }).toList();

        // Ordena por hora
        citasDeHoy.sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

        if (citasDeHoy.isEmpty) {
          return const Center(
            child: Text('No hay citas programadas para hoy.'),
          );
        }

        // Construye la lista
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: citasDeHoy.map((cita) {
              // Busca el nombre del cliente
              String nombreCliente = 'Cliente no encontrado';
              try {
                nombreCliente = clienteProvider.clientes
                    .firstWhere((c) => c.id == cita.clienteId)
                    .nombre;
              } catch (e) {
                // cliente no encontrado
              }

              return ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
                title: Text(
                  '${cita.proposito.texto} - $nombreCliente',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(cita.notas ?? 'Sin notas'),
                trailing: Text(
                  DateFormat(
                    'hh:mm a',
                  ).format(cita.fechaHora), // Muestra la hora
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// --- 5. WIDGET AUXILIAR PARA "PRÓXIMOS CUMPLEAÑOS" (RF-015) ---
class _ProximosCumpleanosCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;

    return Consumer<ClienteProvider>(
      builder: (context, clienteProvider, child) {
        if (clienteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        // Define el rango de 7 días
        final weekFromToday = today.add(const Duration(days: 7));

        final List<Cliente> cumpleaneros = [];

        for (var cliente in clienteProvider.clientes) {
          if (cliente.fechaNacimiento != null &&
              cliente.fechaNacimiento!.isNotEmpty) {
            try {
              // Intenta parsear la fecha (ej. "15/05/1990")
              final bday = DateFormat(
                'dd/MM/yyyy',
              ).parse(cliente.fechaNacimiento!);

              // Normaliza al año actual para comparar
              final thisYearBday = DateTime(today.year, bday.month, bday.day);

              // Comprueba si el cumpleaños de este año está en el rango
              if (thisYearBday.isAfter(
                    today.subtract(const Duration(days: 1)),
                  ) &&
                  thisYearBday.isBefore(weekFromToday)) {
                cumpleaneros.add(cliente);
              }
            } catch (e) {
              // El formato de fecha era incorrecto (ej. "N/A"), lo ignora
              continue;
            }
          }
        }

        if (cumpleaneros.isEmpty) {
          return const Center(child: Text('No hay cumpleaños esta semana.'));
        }

        // Ordena por la fecha de cumpleaños
        cumpleaneros.sort((a, b) {
          final bdayA = DateFormat('dd/MM/yyyy').parse(a.fechaNacimiento!);
          final bdayB = DateFormat('dd/MM/yyyy').parse(b.fechaNacimiento!);
          // Compara solo por mes y día
          if (bdayA.month != bdayB.month) {
            return bdayA.month.compareTo(bdayB.month);
          }
          return bdayA.day.compareTo(bdayB.day);
        });

        // Construye la lista
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: cumpleaneros.map((cliente) {
              return ListTile(
                leading: const Icon(Icons.cake, color: Colors.pink),
                title: Text(
                  '${cliente.nombre} ${cliente.apellidos ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  // Muestra solo el día y el mes
                  DateFormat('dd MMMM').format(
                    DateFormat('dd/MM/yyyy').parse(cliente.fechaNacimiento!),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
