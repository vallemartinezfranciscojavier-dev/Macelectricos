import 'package:flutter/material.dart';
import 'app_dimensions.dart';

/// Fila de información label/valor para pantallas de detalle (DetallePoste,
/// DetalleActividad, etc).
///
/// Mantiene consistencia en la presentación de datos clave-valor en las
/// pantallas de inspección y reporte.
///
/// ```dart
/// InfoRow(label: 'ID', value: 'PST-2847')
/// InfoRow(label: 'Estado', value: 'Bueno', trailing: StatusBadge.success('OK'))
/// ```
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final bool isTopLevel;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.isTopLevel = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isTopLevel ? FontWeight.w600 : FontWeight.w400,
                    color: isTopLevel ? colors.primary : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
