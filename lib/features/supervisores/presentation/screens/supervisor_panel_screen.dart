import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_info_row.dart';
import 'package:macelectricos/core/ui/ui_section_header.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';
import '../widgets/elemento_registrado_tile.dart';

/// Panel de revisión de una sesión de trabajo del técnico (Fase 3).
///
/// Recibe el [sessionId] y muestra un resumen de la sesión, la lista de
/// elementos registrados con su estado de revisión y las acciones de
/// aprobación o rechazo. Los datos son mock generados a partir del
/// [sessionId]; aún no se conecta a Firebase ni a base de datos.
class SupervisorPanelScreen extends StatelessWidget {
  /// Identificador de la sesión de trabajo a revisar.
  final String sessionId;

  const SupervisorPanelScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final resumen = _ResumenSesion.mock(sessionId);
    final elementos = _ElementoRegistrado.mock(sessionId);

    return Scaffold(
      appBar: AppBar(title: const Text('Revisión de sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, resumen),
            const SizedBox(height: AppSpacing.lg),
            _buildResumen(context, resumen),
            const SizedBox(height: AppSpacing.lg),
            _buildElementos(context, elementos),
            const SizedBox(height: AppSpacing.xl),
            _buildAcciones(context),
          ],
        ),
      ),
    );
  }

  /// Encabezado con el id de sesión y el estado de revisión.
  Widget _buildHeader(BuildContext context, _ResumenSesion resumen) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resumen.id,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Sesión de trabajo',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const StatusBadge.warning('Pendiente de revisión'),
        ],
      ),
    );
  }

  /// Resumen de la sesión con filas de datos clave-valor.
  Widget _buildResumen(BuildContext context, _ResumenSesion resumen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Resumen de la sesión'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              InfoRow(label: 'Operario', value: resumen.operario),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              InfoRow(label: 'Fecha', value: resumen.fecha),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              InfoRow(label: 'Ubicación', value: resumen.ubicacion),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              InfoRow(label: 'Duración', value: resumen.duracion),
              const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
              InfoRow(
                label: 'Elementos registrados',
                value: '${resumen.totalElementos}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Lista de elementos registrados en la sesión con su estado de revisión.
  Widget _buildElementos(
    BuildContext context,
    List<_ElementoRegistrado> elementos,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Elementos registrados'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < elementos.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: AppSpacing.lg,
                    endIndent: AppSpacing.lg,
                  ),
                ElementoRegistradoTile(
                  tipo: elementos[i].tipo,
                  descripcion: elementos[i].descripcion,
                  estado: elementos[i].estado,
                  estadoVariant: elementos[i].estadoVariant,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Acciones de aprobación o rechazo de la sesión con confirmación.
  Widget _buildAcciones(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: () => _mostrarConfirmacion(
              context,
              'Sesión aprobada',
              AppColors.success,
            ),
            icon: const Icon(Icons.check),
            label: const Text('Aprobar sesión'),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _mostrarConfirmacion(
              context,
              'Sesión rechazada',
              AppColors.danger,
            ),
            icon: const Icon(Icons.close),
            label: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  /// Muestra un SnackBar de confirmación tras la acción.
  void _mostrarConfirmacion(BuildContext context, String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Datos mock del resumen de una sesión de trabajo.
class _ResumenSesion {
  final String id;
  final String operario;
  final String fecha;
  final String ubicacion;
  final String duracion;
  final int totalElementos;

  const _ResumenSesion({
    required this.id,
    required this.operario,
    required this.fecha,
    required this.ubicacion,
    required this.duracion,
    required this.totalElementos,
  });

  /// Genera un resumen mock determinista a partir del id de sesión.
  factory _ResumenSesion.mock(String sessionId) {
    final indice = sessionId.hashCode.abs() % 4;

    const operarios = [
      'Carlos Ramírez',
      'Laura Méndez',
      'Jorge Salas',
      'Ana Torres',
    ];
    const ubicaciones = [
      'Col. Centro, Sector 1',
      'Av. Industrial, Sector 3',
      'Col. Valle Verde, Sector 2',
      'Zona Norte, Sector 5',
    ];

    return _ResumenSesion(
      id: sessionId,
      operario: operarios[indice],
      fecha: '08/09/2026',
      ubicacion: ubicaciones[indice],
      duracion: '3 h 40 min',
      totalElementos: 4,
    );
  }
}

/// Datos mock de un elemento registrado dentro de la sesión.
class _ElementoRegistrado {
  final ElementType tipo;
  final String descripcion;
  final String estado;
  final StatusBadgeVariant estadoVariant;

  const _ElementoRegistrado({
    required this.tipo,
    required this.descripcion,
    required this.estado,
    required this.estadoVariant,
  });

  /// Genera la lista mock de elementos registrados para la sesión.
  static List<_ElementoRegistrado> mock(String sessionId) {
    final indice = sessionId.hashCode.abs() % 4;

    return [
      _ElementoRegistrado(
        tipo: ElementType.poste,
        descripcion: 'Poste PST-2847 · Reemplazo de aislador',
        estado: 'Aprobado',
        estadoVariant: StatusBadgeVariant.success,
      ),
      _ElementoRegistrado(
        tipo: ElementType.transformador,
        descripcion: 'Transformador TR-091 · Inspección visual',
        estado: 'Pendiente',
        estadoVariant: StatusBadgeVariant.warning,
      ),
      _ElementoRegistrado(
        tipo: ElementType.poda,
        descripcion: 'Poda línea L-12 · Corte preventivo',
        estado: 'Pendiente',
        estadoVariant: StatusBadgeVariant.warning,
      ),
      _ElementoRegistrado(
        tipo: ElementType.foto,
        descripcion: 'Evidencia fotográfica ${indice + 1} · Zona de trabajo',
        estado: 'Rechazado',
        estadoVariant: StatusBadgeVariant.danger,
      ),
    ];
  }
}
