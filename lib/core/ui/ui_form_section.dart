import 'package:flutter/material.dart';
import 'app_dimensions.dart';

/// Contenedor de sección de formulario que agrupa campos relacionados
/// con un título descriptivo y un separador visual sutil.
///
/// Usado en pantallas de registro/poste, transformador, arbol, etc.
/// para organizar el formulario en bloques semánticos.
///
/// ```dart
/// FormSection(
///   title: 'Información técnica',
///   children: [
///     TextFormField(decoration: InputDecoration(labelText: 'ID del poste')),
///     TextFormField(decoration: InputDecoration(labelText: 'Material')),
///   ],
/// )
/// ```
class FormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;

  const FormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
