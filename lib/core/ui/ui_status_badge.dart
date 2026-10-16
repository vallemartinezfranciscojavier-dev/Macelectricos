import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Chip/badge de estado con color semántico, usado en listas de historial,
/// detalle de actividades, y panels de control.
///
/// Soporta 6 variantes semánticas predefinidas para una consistencia visual
/// sin necesidad de especificar colores manualmente.
///
/// ```dart
/// StatusBadge(label: 'Completado', variant: StatusBadgeVariant.success)
/// StatusBadge(label: 'En curso', variant: StatusBadgeVariant.info)
/// ```
enum StatusBadgeVariant {
  neutral,
  primary,
  success,
  warning,
  danger,
  info,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeVariant variant;
  final bool showDot;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.showDot = false,
    this.compact = false,
  });

  const StatusBadge.success(this.label, {super.key})
      : variant = StatusBadgeVariant.success,
        showDot = false,
        compact = false;

  const StatusBadge.warning(this.label, {super.key})
      : variant = StatusBadgeVariant.warning,
        showDot = false,
        compact = false;

  const StatusBadge.danger(this.label, {super.key})
      : variant = StatusBadgeVariant.danger,
        showDot = false,
        compact = false;

  const StatusBadge.info(this.label, {super.key})
      : variant = StatusBadgeVariant.info,
        showDot = false,
        compact = false;

  Color _backgroundColor(ColorScheme colors) {
    return switch (variant) {
      StatusBadgeVariant.neutral => colors.secondaryContainer,
      StatusBadgeVariant.primary => colors.primaryContainer,
      StatusBadgeVariant.success => AppColors.successContainer,
      StatusBadgeVariant.warning => AppColors.warningContainer,
      StatusBadgeVariant.danger => AppColors.dangerContainer,
      StatusBadgeVariant.info => AppColors.infoContainer,
    };
  }

  Color _foregroundColor(ColorScheme colors) {
    return switch (variant) {
      StatusBadgeVariant.neutral => colors.onSecondaryContainer,
      StatusBadgeVariant.primary => colors.primary,
      StatusBadgeVariant.success => AppColors.success,
      StatusBadgeVariant.warning => AppColors.warning,
      StatusBadgeVariant.danger => AppColors.danger,
      StatusBadgeVariant.info => AppColors.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bgColor = _backgroundColor(colors);
    final fgColor = _foregroundColor(colors);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fgColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}
