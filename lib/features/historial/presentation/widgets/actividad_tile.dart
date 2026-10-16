import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

import '../mock_actividades.dart';

/// Fila de una actividad del historial.
///
/// Muestra el avatar con el icono/color del tipo de elemento, el título
/// (tipo + ID), el subtítulo (fecha y operario) y el [StatusBadge] con el
/// estado de la actividad. La fila es tappable para abrir el detalle.
class ActividadTile extends StatelessWidget {
  final ActividadRecord registro;
  final VoidCallback? onTap;

  const ActividadTile({
    super.key,
    required this.registro,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ElementIcons.of(registro.tipo);
    final fechaTexto = DateFormat('dd/MM/yyyy HH:mm').format(registro.fecha);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Avatar con icono y color del tipo de elemento.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(visual.icon, color: visual.color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              // Título y subtítulo.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${visual.label} · ${registro.id}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$fechaTexto · ${registro.operario}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Estado y navegación.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(
                    label: registro.estado.label,
                    variant: registro.estado.variante,
                    compact: true,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}