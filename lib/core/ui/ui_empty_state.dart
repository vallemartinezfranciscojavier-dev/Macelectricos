import 'package:flutter/material.dart';
import 'app_dimensions.dart';

/// Estado vacío reutilizable para listas, búsquedas sin resultados,
/// y pantallas sin datos.
///
/// Mantiene el estilo industrial profesional: icono grande sutil,
/// título claro, mensaje descriptivo opcional, y acción opcional.
///
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'Sin registros',
///   message: 'No se encontraron postes en esta zona.',
///   action: FilledButton(onPressed: () {}, child: Text('Agregar')),
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final double iconSize;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
