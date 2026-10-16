import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Prioridad operativa de un claro de línea.
///
/// Centraliza la etiqueta y la variante semántica del badge para cada nivel:
/// baja (éxito), media (advertencia) y alta (peligro).
enum PrioridadClaro {
  baja,
  media,
  alta;

  /// Etiqueta legible mostrada en la interfaz.
  String get label => switch (this) {
        PrioridadClaro.baja => 'Baja',
        PrioridadClaro.media => 'Media',
        PrioridadClaro.alta => 'Alta',
      };

  /// Variante semántica del [StatusBadge] asociada a la prioridad.
  StatusBadgeVariant get variant => switch (this) {
        PrioridadClaro.baja => StatusBadgeVariant.success,
        PrioridadClaro.media => StatusBadgeVariant.warning,
        PrioridadClaro.alta => StatusBadgeVariant.danger,
      };
}

/// Insignia de estado que representa la prioridad de un claro de línea.
///
/// ```dart
/// PrioridadClaroBadge(prioridad: PrioridadClaro.alta)
/// ```
class PrioridadClaroBadge extends StatelessWidget {
  /// Nivel de prioridad a representar.
  final PrioridadClaro prioridad;

  const PrioridadClaroBadge({super.key, required this.prioridad});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: prioridad.label,
      variant: prioridad.variant,
      compact: true,
    );
  }
}