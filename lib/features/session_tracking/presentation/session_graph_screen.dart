import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:macelectricos/core/models/session_models.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/ui_info_row.dart';
import 'package:macelectricos/core/ui/ui_section_header.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';
import 'package:macelectricos/features/session_tracking/domain/session_repository.dart';

/// Pantalla del grafo de recorrido generado al finalizar una sesión.
///
/// Muestra el resumen de la sesión, las estadísticas del grafo (nodos,
/// aristas, distancias), la distribución de nodos por tipo, las rutas
/// calculadas y el detalle de nodos y aristas que componen el recorrido.
class SessionGraphScreen extends StatelessWidget {
  /// Grafo de recorrido generado por [GraphGenerator].
  final SessionGraph grafo;

  /// Resumen estadístico de la sesión finalizada.
  final SessionSummary resumen;

  const SessionGraphScreen({
    super.key,
    required this.grafo,
    required this.resumen,
  });

  @override
  Widget build(BuildContext context) {
    final stats = grafo.estadisticas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafo de Recorrido'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          // Resumen general de la sesión
          const SectionHeader(title: 'Resumen de la Sesión'),
          _ResumenSesion(resumen: resumen),
          const Divider(height: AppSpacing.xxl),

          // Estadísticas del grafo
          const SectionHeader(title: 'Estadísticas del Grafo'),
          _StatsGrid(stats: stats),
          const Divider(height: AppSpacing.xxl),

          // Distribución de nodos por tipo
          const SectionHeader(title: 'Nodos por Tipo'),
          _NodosPorTipoChart(nodosPorTipo: stats.nodosPorTipo),
          const Divider(height: AppSpacing.xxl),

          // Rutas calculadas
          if (stats.totalNodos > 0 && grafo.rutas.isNotEmpty) ...[
            const SectionHeader(title: 'Rutas de Recorrido'),
            ...grafo.rutas.map((r) => _RutaCard(ruta: r)),
            const Divider(height: AppSpacing.xxl),
          ],

          // Detalle de nodos
          SectionHeader(title: 'Nodos (${grafo.nodos.length})'),
          ...grafo.nodos.map(
            (n) => InfoRow(
              label: _labelDeTipoNodo(n.tipo),
              value: n.label,
              isTopLevel: true,
              trailing: StatusBadge(
                label: '${n.latitude.toStringAsFixed(5)}, ${n.longitude.toStringAsFixed(5)}',
                variant: StatusBadgeVariant.neutral,
                compact: true,
              ),
            ),
          ),

          // Detalle de aristas
          if (grafo.aristas.isNotEmpty) ...[
            const Divider(height: AppSpacing.xxl),
            SectionHeader(title: 'Aristas (${grafo.aristas.length})'),
            ...grafo.aristas.map(
              (a) => InfoRow(
                label: _labelDeTipoArista(a.tipo),
                value:
                    '${a.origenId.substring(0, 8)} -> ${a.destinoId.substring(0, 8)}'
                    '  |  ${a.distanciaMetros.toStringAsFixed(1)} m',
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _labelDeTipoNodo(GraphNodeType tipo) {
    return switch (tipo) {
      GraphNodeType.poste => 'Poste',
      GraphNodeType.transformador => 'Transformador',
      GraphNodeType.arbol => 'Árbol',
      GraphNodeType.poda => 'Poda',
      GraphNodeType.inicio => 'Inicio',
      GraphNodeType.fin => 'Fin',
    };
  }

  String _labelDeTipoArista(GraphEdgeType tipo) {
    return switch (tipo) {
      GraphEdgeType.claro => 'Claro',
      GraphEdgeType.poda => 'Poda',
      GraphEdgeType.desplazamiento => 'Desplazamiento',
      GraphEdgeType.vinculacion => 'Vinculación',
    };
  }
}

/// Resumen de la sesión: horarios, duración y distancia total de claros.
class _ResumenSesion extends StatelessWidget {
  final SessionSummary resumen;

  const _ResumenSesion({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final inicio = _formatearFechaCompleta(resumen.fechaInicio);
    final fin = resumen.fechaFin != null
        ? _formatearFechaCompleta(resumen.fechaFin!)
        : 'En curso';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          _InfoFila(label: 'Inicio', valor: inicio),
          _InfoFila(label: 'Fin', valor: fin),
          _InfoFila(label: 'Duración', valor: _formatearDuracion(resumen.duracionSesion)),
          _InfoFila(
            label: 'Distancia de claros',
            valor: '${resumen.distanciaTotalClaros.toStringAsFixed(1)} m',
            resaltado: true,
          ),
        ],
      ),
    );
  }
}

class _InfoFila extends StatelessWidget {
  final String label;
  final String valor;
  final bool resaltado;

  const _InfoFila({
    required this.label,
    required this.valor,
    this.resaltado = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
          ),
          Text(
            valor,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: resaltado ? FontWeight.w600 : FontWeight.w400,
              color: resaltado ? AppColors.info : theme.colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Cuadrícula de estadísticas del grafo.
class _StatsGrid extends StatelessWidget {
  final GraphStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.0,
      children: [
        _StatCard(
          icon: Icons.circle_outlined,
          label: 'Nodos',
          valor: stats.totalNodos.toString(),
          color: AppColors.poste,
        ),
        _StatCard(
          icon: Icons.alt_route,
          label: 'Aristas',
          valor: stats.totalAristas.toString(),
          color: AppColors.transformador,
        ),
        _StatCard(
          icon: Icons.route,
          label: 'Recorrido',
          valor: '${stats.distanciaTotalRecorrida.toStringAsFixed(1)} m',
          color: AppColors.arbol,
        ),
        _StatCard(
          icon: Icons.crop_square,
          label: 'Área cubierta',
          valor: '${stats.areaCubiertaKm2.toStringAsFixed(2)} km2',
          color: AppColors.claro,
        ),
        _StatCard(
          icon: Icons.account_tree_outlined,
          label: 'Componentes',
          valor: stats.componentesConexos.toString(),
          color: AppColors.info,
        ),
        _StatCard(
          icon: Icons.timelapse,
          label: 'Trabajo',
          valor: _formatearDuracion(stats.tiempoTotalTrabajo),
          color: AppColors.poda,
        ),
      ],
    );
  }
}

/// Tarjeta de estadística individual.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

/// Distribución de nodos por tipo en un gráfico de barras.
class _NodosPorTipoChart extends StatelessWidget {
  final Map<GraphNodeType, int> nodosPorTipo;

  const _NodosPorTipoChart({required this.nodosPorTipo});

  @override
  Widget build(BuildContext context) {
    final items = nodosPorTipo.entries.toList();
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: Text('Sin nodos registrados')),
      );
    }

    final maxVal = items.map((e) => e.value).fold<int>(0, math.max) + 1;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal.toDouble(),
            barTouchData: BarTouchData(enabled: true),
            gridData: const FlGridData(show: true, drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= items.length) {
                      return const SizedBox.shrink();
                    }
                    final label = _labelCorto(items[index].key);
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            barGroups: [
              for (var i = 0; i < items.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: items[i].value.toDouble(),
                      color: _colorDeTipoNodo(items[i].key),
                      width: 20,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelCorto(GraphNodeType tipo) {
    return switch (tipo) {
      GraphNodeType.poste => 'Poste',
      GraphNodeType.transformador => 'Trafo',
      GraphNodeType.arbol => 'Árbol',
      GraphNodeType.poda => 'Poda',
      GraphNodeType.inicio => 'Inicio',
      GraphNodeType.fin => 'Fin',
    };
  }

  Color _colorDeTipoNodo(GraphNodeType tipo) {
    return switch (tipo) {
      GraphNodeType.poste => AppColors.poste,
      GraphNodeType.transformador => AppColors.transformador,
      GraphNodeType.arbol => AppColors.arbol,
      GraphNodeType.poda => AppColors.poda,
      GraphNodeType.inicio => AppColors.info,
      GraphNodeType.fin => AppColors.danger,
    };
  }
}

/// Tarjeta de una ruta de recorrido.
class _RutaCard extends StatelessWidget {
  final GraphRoute ruta;

  const _RutaCard({required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    ruta.descripcion,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                StatusBadge.info(
                  '${ruta.distanciaTotal.toStringAsFixed(1)} m',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${ruta.nodosOrdenados.length} puntos  |  '
              'Tiempo estimado: ${_formatearDuracion(ruta.tiempoEstimado)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatearDuracion(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;

  if (h > 0) {
    return '$h h ${m.toString().padLeft(2, '0')} min';
  }
  if (m > 0) {
    return '$m min ${s.toString().padLeft(2, '0')} s';
  }
  return '${s.toString().padLeft(2, '0')} s';
}

String _formatearFechaCompleta(DateTime d) {
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}