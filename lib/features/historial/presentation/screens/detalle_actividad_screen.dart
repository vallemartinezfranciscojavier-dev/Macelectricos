import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_info_row.dart';
import 'package:macelectricos/core/ui/ui_section_header.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

import '../mock_actividades.dart';

/// Pantalla de detalle de una actividad del historial.
///
/// Recibe el [recordId] de la actividad y genera los datos de ejemplo a
/// partir de la lista mock. Muestra datos clave-valor con [InfoRow],
/// secciones con [SectionHeader] y un botón para reportar problemas.
class DetalleActividadScreen extends StatelessWidget {
  final String recordId;

  const DetalleActividadScreen({
    super.key,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registro = mockActividadForId(recordId);
    final visual = ElementIcons.of(registro.tipo);
    final fechaTexto = DateFormat('dd/MM/yyyy HH:mm').format(registro.fecha);

    return Scaffold(
      appBar: AppBar(title: Text(registro.id)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          _buildHeader(theme, registro, visual),
          const Divider(),
          const SectionHeader(title: 'Información'),
          InfoRow(label: 'Tipo', value: visual.label),
          InfoRow(
            label: 'Estado',
            value: registro.estado.label,
            trailing: StatusBadge(
              label: registro.estado.label,
              variant: registro.estado.variante,
              compact: true,
            ),
          ),
          InfoRow(label: 'Operario', value: registro.operario),
          InfoRow(label: 'Fecha y hora', value: fechaTexto),
          const Divider(),
          const SectionHeader(title: 'Ubicación'),
          InfoRow(label: 'Coordenadas', value: registro.coordenadas),
          InfoRow(label: 'Referencia', value: registro.ubicacion),
          const Divider(),
          const SectionHeader(title: 'Notas'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  registro.notas,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FilledButton.icon(
              onPressed: () => _reportarProblema(context),
              icon: const Icon(Icons.report_problem_outlined),
              label: const Text('Reportar problema'),
            ),
          ),
        ],
      ),
    );
  }

  /// Encabezado con avatar, título y badge de estado de la actividad.
  Widget _buildHeader(
    ThemeData theme,
    ActividadRecord registro,
    ElementVisual visual,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(visual.icon, color: visual.color, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${visual.label} · ${registro.id}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Registrado por ${registro.operario}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: registro.estado.label,
            variant: registro.estado.variante,
          ),
        ],
      ),
    );
  }

  /// Muestra un [SnackBar] de confirmación al reportar el problema.
  void _reportarProblema(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Problema reportado para revisión.'),
      ),
    );
  }
}