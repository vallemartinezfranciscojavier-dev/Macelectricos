import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Resumen del tipo de elemento que encabeza el formulario de registro de árbol.
///
/// Presenta el icono y color del elemento (árbol) junto con la leyenda
/// "Pendiente de sincronizar" para comunicar el estado local del registro.
class ResumenRegistroArbol extends StatelessWidget {
  const ResumenRegistroArbol({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ElementIcons.of(ElementType.arbol);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: AppTouchTarget.min,
              height: AppTouchTarget.min,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(visual.icon, color: visual.color, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registro de árbol',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Árbol dentro del área de servidumbre',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const StatusBadge.warning('Pendiente de sincronizar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}