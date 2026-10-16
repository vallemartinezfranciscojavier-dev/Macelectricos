import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Estado operativo de una poda registrada.
///
/// Centraliza la etiqueta y la variante semántica del badge para cada estado:
/// pendiente (advertencia), programada (información) y completada (éxito).
enum EstadoPoda {
  pendiente,
  programada,
  completada;

  /// Etiqueta legible mostrada en la interfaz.
  String get label => switch (this) {
        EstadoPoda.pendiente => 'Pendiente',
        EstadoPoda.programada => 'Programada',
        EstadoPoda.completada => 'Completada',
      };

  /// Variante semántica del [StatusBadge] asociada al estado.
  StatusBadgeVariant get variant => switch (this) {
        EstadoPoda.pendiente => StatusBadgeVariant.warning,
        EstadoPoda.programada => StatusBadgeVariant.info,
        EstadoPoda.completada => StatusBadgeVariant.success,
      };
}

/// Insignia de estado que representa la situación de una poda.
///
/// ```dart
/// EstadoPodaBadge(estado: EstadoPoda.completada)
/// ```
class EstadoPodaBadge extends StatelessWidget {
  /// Estado operativo a representar.
  final EstadoPoda estado;

  const EstadoPodaBadge({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: estado.label,
      variant: estado.variant,
      compact: true,
    );
  }
}