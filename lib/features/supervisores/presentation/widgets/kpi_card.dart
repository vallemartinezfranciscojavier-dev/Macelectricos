import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';

/// Tarjeta de indicador clave (KPI) para el dashboard del supervisor.
///
/// Muestra un valor grande con un acento de color semántico y una etiqueta
/// descriptiva, permitiendo un vistazo rápido al estado operativo de la
/// jornada (sesiones activas, pendientes, verificados, sin sincronizar).
class KpiCard extends StatelessWidget {
  /// Valor numérico principal del indicador (texto para permitir formatos).
  final String value;

  /// Etiqueta descriptiva debajo del valor.
  final String label;

  /// Color semántico que acompaña al valor (de [AppColors]).
  final Color color;

  /// Icono opcional que refuerza el significado del indicador.
  final IconData? icon;

  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: AppTouchTarget.large),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
