import 'package:flutter/material.dart';
import 'app_dimensions.dart';

/// Encabezado de sección reutilizable en pantallas de dashboard, registro,
/// historial y detalles.
///
/// Muestra un título en mayúsculas con estilo `labelSmall` del tema,
/// replicando el patrón ya usado en el `ProfileScreen`.
///
/// ```dart
/// SectionHeader(
///   title: 'Datos del poste',
///   trailing: TextButton(onPressed: () {}, child: Text('Editar')),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.only(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: AppSpacing.sm,
    ),
    this.spacing = AppSpacing.sm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
