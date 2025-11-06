import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/models/cita.dart';
import 'package:proyecto_tienda_ternos/screens/editar_cita_screen.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class DetallesCitaScreen extends StatelessWidget {
  final Cita cita;
  const DetallesCitaScreen({super.key, required this.cita});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Cita')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Etiqueta de Estado ---
            Align(
              alignment: Alignment.topLeft,
              child: _StatusTag(estado: cita.estado),
            ),
            const SizedBox(height: 16),

            // --- Tarjeta Cliente ---
            Text('Cliente', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildCard(
              context,
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.person_outline,
                    text: cita.clienteNombre,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: cita.clienteTelefono,
                  ),
                  _InfoRow(icon: Icons.email_outlined, text: cita.clienteEmail),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Tarjeta Detalles de la Cita ---
            Text(
              'Detalles de la Cita',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildCard(
              context,
              child: Column(
                children: [
                  _InfoRow(icon: Icons.list_alt_outlined, text: cita.tipoTexto),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: cita.fecha,
                  ),
                  _InfoRow(icon: Icons.access_time_outlined, text: cita.hora),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Tarjeta Prendas ---
            Text('Prendas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildCard(
              context,
              child: _InfoRow(
                icon: Icons.checkroom, // Ícono de terno
                text: cita.prendaDetalleNombre,
                subtitle: 'ID: ${cita.prendaDetalleId}',
              ),
            ),
            const SizedBox(height: 32),

            // --- Botones de Acción ---
            _buildActionButton(
              label: 'Marcar como Completada',
              color: AppColors.primary,
              textColor: Colors.white,
              onPressed: () {
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
                    builder: (context) => EditarCitaScreen(cita: cita),
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              label: 'Cancelar Cita',
              color: Colors.transparent, // Sin fondo
              textColor: Colors.red,
              onPressed: () {
                // Lógica para cancelar
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper para las tarjetas
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

  // Helper para las filas de información
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

  // Helper para los botones de acción
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

// Helper para la etiqueta de estado "Pendiente"
class _StatusTag extends StatelessWidget {
  final CitaEstado estado;
  const _StatusTag({required this.estado});

  @override
  Widget build(BuildContext context) {
    // Aquí puedes añadir lógica para Completada/Cancelada si es necesario
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Pendiente',
        style: TextStyle(
          color: Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
