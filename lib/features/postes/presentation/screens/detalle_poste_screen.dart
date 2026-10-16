import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_info_row.dart';
import 'package:macelectricos/core/ui/ui_section_header.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Datos de ejemplo de un poste para la pantalla de detalle.
///
/// Mantiene los valores clave-valor que se muestran en la UI mock;
/// en Fase 4 estos datos llegarán desde el repositorio de postes.
class PosteMock {
  final String id;
  final String material;
  final double altura;
  final String fijacion;
  final String estado;
  final String latitud;
  final String longitud;
  final String referencia;
  final String fechaInspeccion;
  final String resultadoInspeccion;

  const PosteMock({
    required this.id,
    required this.material,
    required this.altura,
    required this.fijacion,
    required this.estado,
    required this.latitud,
    required this.longitud,
    required this.referencia,
    required this.fechaInspeccion,
    required this.resultadoInspeccion,
  });
}

/// Genera el poste de ejemplo asociado a un [elementoId].
///
/// Usa el identificador como semilla para variar los datos mock de forma
/// determinista, de modo que cada poste consultado se vea coherente.
PosteMock _posteMockPara(String elementoId) {
  final seed = elementoId.hashCode & 0x7fffffff;
  final materiales = ['Concreto', 'Madera', 'Metal'];
  final material = materiales[seed % materiales.length];
  final latitud = (19.0 + (seed % 100) / 100.0).toStringAsFixed(4);
  final longitud = (-99.0 + (seed % 100) / 100.0).toStringAsFixed(4);
  final altura = 8.0 + (seed % 7).toDouble() * 0.5;

  return PosteMock(
    id: elementoId,
    material: material,
    altura: altura,
    fijacion: 'Superficie',
    estado: seed.isEven ? 'Bueno' : 'Deteriorado',
    latitud: latitud,
    longitud: longitud,
    referencia: 'Col. Centro, esquina Av. Principal',
    fechaInspeccion: '05/09/2026 10:30',
    resultadoInspeccion: 'Sin anomalías estructurales',
  );
}

/// Pantalla de detalle de un poste de la red eléctrica.
///
/// Recibe el [elementoId] del poste y genera datos de ejemplo (mock) a
/// partir de él. Muestra las secciones de información con [SectionHeader],
/// los datos clave-valor con [InfoRow], el estado con [StatusBadge] y un
/// botón para iniciar una nueva inspección.
class DetallePosteScreen extends StatelessWidget {
  final String elementoId;

  const DetallePosteScreen({
    super.key,
    required this.elementoId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final poste = _posteMockPara(elementoId);
    final visual = ElementIcons.of(ElementType.poste);
    final estadoOk = poste.estado == 'Bueno';

    return Scaffold(
      appBar: AppBar(title: Text(poste.id)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          _buildHeader(theme, poste, visual, estadoOk),
          const Divider(),
          const SectionHeader(title: 'Información'),
          InfoRow(label: 'Elemento', value: visual.label),
          InfoRow(
            label: 'Estado',
            value: poste.estado,
            trailing: StatusBadge(
              label: poste.estado,
              variant: estadoOk
                  ? StatusBadgeVariant.success
                  : StatusBadgeVariant.warning,
              compact: true,
            ),
          ),
          InfoRow(label: 'Material', value: poste.material),
          InfoRow(label: 'Altura', value: '${poste.altura} m'),
          InfoRow(label: 'Tipo de fijación', value: poste.fijacion),
          const Divider(),
          const SectionHeader(title: 'Ubicación'),
          InfoRow(
            label: 'Coordenadas',
            value: '${poste.latitud}, ${poste.longitud}',
          ),
          InfoRow(label: 'Referencia', value: poste.referencia),
          const Divider(),
          const SectionHeader(title: 'Última inspección'),
          InfoRow(label: 'Fecha', value: poste.fechaInspeccion),
          InfoRow(label: 'Resultado', value: poste.resultadoInspeccion),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: FilledButton.icon(
              onPressed: () => _nuevaInspeccion(context),
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Nueva inspección'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppTouchTarget.large),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Encabezado con avatar, título y badge de estado del poste.
  Widget _buildHeader(
    ThemeData theme,
    PosteMock poste,
    ElementVisual visual,
    bool estadoOk,
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
                  '${visual.label} · ${poste.id}',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  'Red de distribución eléctrica',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(
            label: poste.estado,
            variant: estadoOk
                ? StatusBadgeVariant.success
                : StatusBadgeVariant.warning,
          ),
        ],
      ),
    );
  }

  /// Muestra un [SnackBar] de confirmación al iniciar una nueva inspección.
  void _nuevaInspeccion(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nueva inspección preparada para registro.'),
      ),
    );
  }
}