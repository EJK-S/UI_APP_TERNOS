import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORTAMOS PROVIDER
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/providers/cita_provider.dart'; // <-- 2. IMPORTAMOS EL CEREBRO
import 'package:proyecto_tienda_ternos/screens/gestion_citas/editar_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';
import 'package:proyecto_tienda_ternos/models/cliente.dart';
import 'package:proyecto_tienda_ternos/providers/cliente_provider.dart';

class DetallesCitaScreen extends StatelessWidget {
  final Cita cita;
  const DetallesCitaScreen({super.key, required this.cita});

  @override
  Widget build(BuildContext context) {
    // 3. Obtenemos la instancia del provider (para llamar a los métodos)
    final citaProvider = Provider.of<CitaProvider>(context, listen: false);
    final clienteProvider = Provider.of<ClienteProvider>(
      context,
      listen: false,
    );
    Cliente? cliente;
    try {
      cliente = clienteProvider.clientes.firstWhere(
        (c) => c.dni == cita.clienteId,
      );
    } catch (e) {
      cliente = null; // No se encontró
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Cita')),
      // --- 3. USAMOS UN CONSUMER DE CITA ---
      // (Para que el estado 'Pendiente' cambie si lo cancelas/completas)
      body: Consumer<CitaProvider>(
        builder: (context, provider, child) {
          // Busca la versión más actualizada de la cita
          final citaActualizada = provider.citas.firstWhere(
            (c) => c.prendaDetalleId == cita.prendaDetalleId,
            orElse: () => cita, // Si no la encuentra, usa la original
          );

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: _StatusTag(estado: citaActualizada.estado),
                ),
                const SizedBox(height: 16),

                // --- 4. TARJETA DE CLIENTE CORREGIDA ---
                Text('Cliente', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildCard(
                  context,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        text: cliente != null
                            ? '${cliente.nombre} ${cliente.apellidos ?? ''}'
                            : 'Cliente no encontrado',
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        text: cliente?.telefono ?? 'Sin teléfono',
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        text: cliente?.correo ?? 'Sin correo',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // --- FIN DE LA CORRECCIÓN ---

                // --- Tarjeta Detalles de la Cita (ya estaba bien) ---
                Text(
                  'Detalles de la Cita',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildCard(
                  context,
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.list_alt_outlined,
                        text: citaActualizada.tipo.tipoTexto,
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: citaActualizada.fecha,
                      ),
                      _InfoRow(
                        icon: Icons.access_time_outlined,
                        text: citaActualizada.hora,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Tarjeta Prendas (ya estaba bien) ---
                Text('Prendas', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildCard(
                  context,
                  child: _InfoRow(
                    icon: Icons.checkroom,
                    text: citaActualizada.prendaDetalleNombre,
                    subtitle: 'ID: ${citaActualizada.prendaDetalleId}',
                  ),
                ),
                const SizedBox(height: 32),

                // --- Botones de Acción (ya estaban bien) ---
                _buildActionButton(
                  label: 'Marcar como Completada',
                  color: AppColors.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    citaProvider.marcarComoCompletada(citaActualizada);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: 'Editar Cita',
                  color: AppColors.borderLight,
                  textColor: AppColors.stone800,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditarCitaScreen(cita: citaActualizada),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: 'Cancelar Cita',
                  color: Colors.transparent,
                  textColor: Colors.red,
                  onPressed: () {
                    citaProvider.cancelarCita(citaActualizada);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- NINGÚN CAMBIO DE AQUÍ PARA ABAJO ---
  // (Todos los widgets auxiliares siguen exactamente iguales)

  Widget _buildCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }

  Widget _InfoRow({
    required IconData icon,
    required String text,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.stone600, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.stone600,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: color == Colors.transparent
              ? const BorderSide(color: Colors.red)
              : BorderSide.none,
        ),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final CitaEstado estado;
  const _StatusTag({required this.estado});

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE UI ACTUALIZADA ---
    String text;
    Color color;
    Color backgroundColor;

    switch (estado) {
      case CitaEstado.Pendiente:
        text = 'Pendiente';
        color = Colors.orange.shade800;
        backgroundColor = Colors.orange.shade100;
        break;
      case CitaEstado.Completada:
        text = 'Completada';
        color = Colors.green.shade800;
        backgroundColor = Colors.green.shade100;
        break;
      case CitaEstado.Cancelada:
        text = 'Cancelada';
        color = Colors.red.shade800;
        backgroundColor = Colors.red.shade100;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
