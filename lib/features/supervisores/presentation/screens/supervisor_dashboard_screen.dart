import 'package:flutter/material.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_section_header.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';
import 'supervisor_panel_screen.dart';
import '../widgets/aprobacion_tile.dart';
import '../widgets/cuadrilla_tile.dart';
import '../widgets/kpi_card.dart';

/// Dashboard del supervisor con datos mock (Fase 3).
///
/// Muestra el estado operativo del día: saludo con fecha, indicadores clave
/// (KPIs), el avance de las cuadrillas y las aprobaciones pendientes de
/// revisión. La navegación a la revisión de cada aprobación queda conectada
/// al panel de sesión ([SupervisorPanelScreen]).
class SupervisorDashboardScreen extends StatelessWidget {
  const SupervisorDashboardScreen({super.key});

  static const List<String> _diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  static const List<String> _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Supervisor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.lg),
            _buildKpis(context),
            const SizedBox(height: AppSpacing.lg),
            _buildCuadrillas(context),
            const SizedBox(height: AppSpacing.lg),
            _buildAprobaciones(context),
          ],
        ),
      ),
    );
  }

  /// Encabezado con saludo según la hora y la fecha actual.
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final ahora = DateTime.now();
    final hora = ahora.hour;
    final saludo =
        hora < 12
            ? 'Buenos días'
            : hora < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$saludo, Supervisor',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatearFecha(ahora),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de indicadores clave en una grilla de dos columnas.
  Widget _buildKpis(BuildContext context) {
    final kpis = <Widget>[
      KpiCard(
        value: '3',
        label: 'Sesiones activas',
        color: AppColors.info,
        icon: Icons.play_circle_outline,
      ),
      KpiCard(
        value: '7',
        label: 'Pendientes de revisión',
        color: AppColors.warning,
        icon: Icons.pending_outlined,
      ),
      KpiCard(
        value: '42',
        label: 'Elementos verificados hoy',
        color: AppColors.success,
        icon: Icons.verified_outlined,
      ),
      KpiCard(
        value: '5',
        label: 'Sin sincronizar',
        color: AppColors.danger,
        icon: Icons.sync_problem_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.6,
        children: kpis,
      ),
    );
  }

  /// Sección de cuadrillas con su estado y progreso.
  Widget _buildCuadrillas(BuildContext context) {
    final cuadrillas = <Widget>[
      const CuadrillaTile(
        nombre: 'Cuadrilla Norte',
        integrantes: '5 integrantes',
        estado: 'En campo',
        estadoVariant: StatusBadgeVariant.info,
        progreso: 0.7,
      ),
      const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
      const CuadrillaTile(
        nombre: 'Cuadrilla Sur',
        integrantes: '4 integrantes',
        estado: 'En campo',
        estadoVariant: StatusBadgeVariant.info,
        progreso: 0.45,
      ),
      const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
      const CuadrillaTile(
        nombre: 'Cuadrilla Este',
        integrantes: '6 integrantes',
        estado: 'Completada',
        estadoVariant: StatusBadgeVariant.success,
        progreso: 1.0,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Cuadrillas'),
        Card(margin: EdgeInsets.zero, child: Column(children: cuadrillas)),
      ],
    );
  }

  /// Sección de aprobaciones pendientes, cada una tappable hacia el panel.
  Widget _buildAprobaciones(BuildContext context) {
    final aprobaciones = <_Aprobacion>[
      _Aprobacion(
        tipo: ElementType.poste,
        titulo: 'Revisión de poste PST-2847',
        subtitulo: 'Sesión S-1023 · Cuadrilla Norte',
        sessionId: 'S-1023',
      ),
      _Aprobacion(
        tipo: ElementType.transformador,
        titulo: 'Revisión de transformador TR-091',
        subtitulo: 'Sesión S-1027 · Cuadrilla Sur',
        sessionId: 'S-1027',
      ),
      _Aprobacion(
        tipo: ElementType.poda,
        titulo: 'Revisión de poda en línea L-12',
        subtitulo: 'Sesión S-1029 · Cuadrilla Este',
        sessionId: 'S-1029',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Aprobaciones pendientes'),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final aprobacion in aprobaciones)
                AprobacionTile(
                  tipo: aprobacion.tipo,
                  titulo: aprobacion.titulo,
                  subtitulo: aprobacion.subtitulo,
                  onTap: () => _abrirRevision(context, aprobacion.sessionId),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Navega al panel de revisión de la sesión indicada.
  void _abrirRevision(BuildContext context, String sessionId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupervisorPanelScreen(sessionId: sessionId),
      ),
    );
  }

  /// Formatea la fecha en español, p. ej. "lunes, 8 de septiembre de 2026".
  String _formatearFecha(DateTime fecha) {
    return '${_diasSemana[fecha.weekday - 1]}, '
        '${fecha.day} de ${_meses[fecha.month - 1]} de ${fecha.year}';
  }
}

/// Datos mock de una aprobación pendiente en el dashboard.
class _Aprobacion {
  final ElementType tipo;
  final String titulo;
  final String subtitulo;
  final String sessionId;

  const _Aprobacion({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.sessionId,
  });
}
