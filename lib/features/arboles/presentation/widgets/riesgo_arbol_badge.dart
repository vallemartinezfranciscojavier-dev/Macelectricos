import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Nivel de riesgo de interferencia de un árbol con la línea eléctrica.
///
/// Centraliza la etiqueta y la variante semántica del badge para cada nivel,
/// manteniendo la semántica visual: bajo (éxito), medio (advertencia) y
/// alto (peligro).
enum RiesgoInterferencia {
  bajo,
  medio,
  alto;

  /// Etiqueta legible que se muestra en la interfaz.
  String get label => switch (this) {
        RiesgoInterferencia.bajo => 'Bajo',
        RiesgoInterferencia.medio => 'Medio',
        RiesgoInterferencia.alto => 'Alto',
      };

  /// Variante semántica del [StatusBadge] asociada al nivel de riesgo.
  StatusBadgeVariant get variant => switch (this) {
        RiesgoInterferencia.bajo => StatusBadgeVariant.success,
        RiesgoInterferencia.medio => StatusBadgeVariant.warning,
        RiesgoInterferencia.alto => StatusBadgeVariant.danger,
      };
}

/// Insignia de estado que representa el nivel de riesgo de interferencia
/// de un árbol con la red eléctrica.
///
/// ```dart
/// RiesgoArbolBadge(riesgo: RiesgoInterferencia.alto)
/// ```
class RiesgoArbolBadge extends StatelessWidget {
  /// Nivel de riesgo a representar.
  final RiesgoInterferencia riesgo;

  const RiesgoArbolBadge({super.key, required this.riesgo});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: riesgo.label,
      variant: riesgo.variant,
      compact: true,
    );
  }
}