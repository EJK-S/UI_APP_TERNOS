import 'package:flutter/material.dart';
import 'package:proyecto_tienda_ternos/theme/app_theme.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
