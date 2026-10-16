import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';

/// Indicador de progreso del flujo de creación de un claro de línea.
///
/// Muestra los dos pasos del flujo ("Seleccionar postes" y "Detalles del
/// claro") resaltando el paso activo con el color del elemento claro.
class PasoCrearClaro extends StatelessWidget {
  /// Paso activo del flujo (1 o 2).
  final int pasoActual;

  const PasoCrearClaro({super.key, required this.pasoActual});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _PasoItem(
              numero: '1',
              titulo: 'Seleccionar postes',
              activo: pasoActual == 1,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _PasoItem(
              numero: '2',
              titulo: 'Detalles del claro',
              activo: pasoActual == 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fragmento individual del indicador de progreso.
class _PasoItem extends StatelessWidget {
  final String numero;
  final String titulo;
  final bool activo;

  const _PasoItem({
    required this.numero,
    required this.titulo,
    required this.activo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = activo ? AppColors.claro : theme.colorScheme.outlineVariant;
    final fg = activo ? Colors.white : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: activo
            ? AppColors.claro.withValues(alpha: 0.12)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: activo ? AppColors.claro : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: color,
            child: Text(
              numero,
              style: TextStyle(
                fontSize: 11,
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: activo
                    ? AppColors.claro
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}