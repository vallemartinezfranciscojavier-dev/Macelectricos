import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Fila de una cuadrilla en el dashboard del supervisor.
///
/// Muestra el nombre, la cantidad de integrantes, el estado operativo
/// mediante un [StatusBadge] y el progreso de la jornada con una barra de
/// avance. La fila es opcionalmente tappable.
class CuadrillaTile extends StatelessWidget {
  /// Nombre de la cuadrilla.
  final String nombre;

  /// Descripción de integrantes, p. ej. "5 integrantes".
  final String integrantes;

  /// Texto del estado operativo, p. ej. "En campo" o "Completada".
  final String estado;

  /// Variante semántica del badge de estado.
  final StatusBadgeVariant estadoVariant;

  /// Progreso de la jornada entre 0.0 y 1.0.
  final double progreso;

  /// Callback opcional al tocar la fila.
  final VoidCallback? onTap;

  const CuadrillaTile({
    super.key,
    required this.nombre,
    required this.integrantes,
    required this.estado,
    this.estadoVariant = StatusBadgeVariant.info,
    this.progreso = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    nombre,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(label: estado, variant: estadoVariant),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              integrantes,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progreso.clamp(0.0, 1.0),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
