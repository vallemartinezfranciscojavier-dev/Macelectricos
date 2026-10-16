import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Fila de un elemento registrado dentro de una sesión de trabajo.
///
/// Se usa en el panel de revisión para mostrar cada elemento con su avatar
/// de tipo, una descripción y el estado de revisión (aprobado, pendiente o
/// rechazado) mediante un [StatusBadge].
class ElementoRegistradoTile extends StatelessWidget {
  /// Tipo de elemento de infraestructura (define icono y color del avatar).
  final ElementType tipo;

  /// Descripción del elemento registrado.
  final String descripcion;

  /// Texto del estado de revisión, p. ej. "Aprobado" o "Rechazado".
  final String estado;

  /// Variante semántica del badge de estado de revisión.
  final StatusBadgeVariant estadoVariant;

  const ElementoRegistradoTile({
    super.key,
    required this.tipo,
    required this.descripcion,
    required this.estado,
    this.estadoVariant = StatusBadgeVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ElementIcons.of(tipo);

    return ListTile(
      minVerticalPadding: AppSpacing.md,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: visual.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(visual.icon, color: visual.color),
      ),
      title: Text(
        descripcion,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: StatusBadge(label: estado, variant: estadoVariant),
    );
  }
}
