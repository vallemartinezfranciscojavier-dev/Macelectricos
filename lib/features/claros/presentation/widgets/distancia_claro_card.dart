import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';

/// Tarjeta que resume la distancia (mock) entre el poste A y el poste B del
/// claro de línea que se está creando.
///
/// Muestra el tramo seleccionado y el valor calculado en metros con el color
/// característico del elemento claro.
class DistanciaClaroCard extends StatelessWidget {
  /// Identificador del poste de origen.
  final String posteA;

  /// Identificador del poste de destino.
  final String posteB;

  /// Distancia calculada entre postes, en metros.
  final double distanciaMetros;

  const DistanciaClaroCard({
    super.key,
    required this.posteA,
    required this.posteB,
    required this.distanciaMetros,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = ElementIcons.of(ElementType.claro);

    return Card(
      margin: EdgeInsets.zero,
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
                    'Distancia del tramo',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$posteA  →  $posteB',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${distanciaMetros.toStringAsFixed(1)} m',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.claro,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}