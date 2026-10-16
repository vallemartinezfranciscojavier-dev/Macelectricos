import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Fila de una aprobación pendiente en el dashboard del supervisor.
///
/// Muestra el avatar del tipo de elemento, el título de la actividad y un
/// badge de "Pendiente". La fila es tappable para entrar a la revisión de
/// la sesión correspondiente (la navegación se conectará en una fase
/// posterior).
class AprobacionTile extends StatelessWidget {
  /// Tipo de elemento de infraestructura involucrado (define icono y color).
  final ElementType tipo;

  /// Título de la actividad o elemento a revisar.
  final String titulo;

  /// Subtítulo descriptivo (sesión, cuadrilla, ubicación).
  final String subtitulo;

  /// Callback opcional al tocar la fila.
  final VoidCallback? onTap;

  const AprobacionTile({
    super.key,
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ElementIcons.of(tipo);

    return ListTile(
      onTap: onTap,
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
        titulo,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitulo),
      trailing: const StatusBadge.warning('Pendiente'),
    );
  }
}
