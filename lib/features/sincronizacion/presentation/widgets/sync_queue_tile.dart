import 'package:flutter/material.dart';

import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

import '../mock_sincronizacion.dart';

/// Fila de un elemento de la cola de sincronización.
///
/// Muestra el avatar con el icono/color del tipo de elemento, la descripción
/// del registro, el identificador y el [StatusBadge] con el estado de
/// sincronización (pendiente, sincronizado o error).
class SyncQueueTile extends StatelessWidget {
  final SyncQueueItem item;
  final VoidCallback? onTap;

  const SyncQueueTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ElementIcons.of(item.tipo);

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
              // Descripción e identificador.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.descripcion,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${visual.label} · ${item.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Estado de sincronización.
              StatusBadge(
                label: item.estado.label,
                variant: item.estado.variante,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}