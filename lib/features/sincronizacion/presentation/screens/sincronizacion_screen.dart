import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:macelectricos/core/di/providers.dart';
import 'package:macelectricos/core/ui/app_colors.dart';
import 'package:macelectricos/core/ui/app_dimensions.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_section_header.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';
import 'package:macelectricos/features/sincronizacion/data/sync_queue.dart';

/// Panel de sincronización offline-first.
///
/// Muestra el estado de conectividad real, resumen con KPIs,
/// botón "Sincronizar ahora" y la cola de elementos pendientes.
class SincronizacionScreen extends ConsumerStatefulWidget {
  const SincronizacionScreen({super.key});

  @override
  ConsumerState<SincronizacionScreen> createState() => _SincronizacionScreenState();
}

class _SincronizacionScreenState extends ConsumerState<SincronizacionScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final syncQueueAsync = ref.watch(syncQueueProvider);
    final connectivityAsync = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reintentar errores',
            onPressed: () => _limpiarErrores(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar sincronizados',
            onPressed: () => _eliminarSincronizados(),
          ),
        ],
      ),
      body: syncQueueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.refresh(syncQueueProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (syncQueue) {
          final stats = syncQueue.estadisticas;
          final ultimaSync = syncQueue.lastSyncTime;
          final ultimaSyncStr = ultimaSync != null
              ? DateFormat('dd/MM · HH:mm').format(ultimaSync)
              : 'Nunca';
          final pendientes = syncQueue.getPendientesPorPrioridad();

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            children: [
              _buildBannerConectividad(connectivityAsync),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Resumen'),
              _buildResumen(stats, ultimaSyncStr),
              const SizedBox(height: AppSpacing.sm),
              _buildBotonSincronizar(pendientes.length, _isSyncing),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Cola de sincronización'),
              if (pendientes.isEmpty)
                _buildVacio()
              else
                ...pendientes.map((item) => _buildQueueTile(item, syncQueue)),
              if (stats['sincronizados']! > 0) ...[
                const SizedBox(height: AppSpacing.md),
                const SectionHeader(title: 'Historial'),
                ..._buildHistorial(syncQueue.obtenerTodos()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBannerConectividad(AsyncValue<List<ConnectivityResult>> connectivity) {
    final theme = Theme.of(context);

    return connectivity.maybeWhen(
      data: (results) {
        final enLinea = !results.contains(ConnectivityResult.none);
        return _buildBannerContent(enLinea, theme);
      },
      orElse: () => _buildBannerContent(true, theme),
    );
  }

  Widget _buildBannerContent(bool enLinea, ThemeData theme) {
    final fondo = enLinea ? AppColors.successContainer : AppColors.warningContainer;
    final color = enLinea ? AppColors.success : AppColors.warning;
    final icono = enLinea ? Icons.cloud_done_outlined : Icons.cloud_off_outlined;
    final titulo = enLinea ? 'En línea' : 'Sin conexión';
    final detalle = enLinea
        ? 'Los cambios se sincronizarán automáticamente.'
        : 'Los cambios se guardan localmente.';

    return Container(
      color: fondo,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumen(Map<String, int> stats, String ultimaSync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kpiCard(
            valor: '${stats['pendientes'] ?? 0}',
            etiqueta: 'Pendientes',
            color: AppColors.warning,
          ),
          _kpiCard(
            valor: '${stats['sincronizados'] ?? 0}',
            etiqueta: 'Sincronizados',
            color: AppColors.success,
          ),
          _kpiCard(
            valor: '${stats['errores'] ?? 0}',
            etiqueta: 'Errores',
            color: AppColors.danger,
          ),
          _kpiCard(
            valor: ultimaSync,
            etiqueta: 'Última sync',
            color: null,
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String valor,
    required String etiqueta,
    required Color? color,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Text(
                valor,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                etiqueta.toUpperCase(),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotonSincronizar(int pendientes, bool isSyncing) {
    final etiqueta = isSyncing
        ? 'Sincronizando...'
        : pendientes == 0
            ? 'Todo sincronizado'
            : 'Sincronizar ahora ($pendientes)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: FilledButton.icon(
        onPressed: isSyncing || pendientes == 0 ? null : _sincronizarAhora,
        icon: isSyncing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.sync),
        label: Text(etiqueta),
      ),
    );
  }

  Widget _buildQueueTile(SyncQueueItem item, SyncQueue queue) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ElementIcons.of(item.tipo).color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    ElementIcons.of(item.tipo).icon,
                    color: ElementIcons.of(item.tipo).color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.id} · ${item.operacion.name.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        item.descripcion,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: item.estado.label,
                  variant: item.estado.variante,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      size: 14,
                      color: _getPrioridadColor(item.prioridad),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.prioridad.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: _getPrioridadColor(item.prioridad),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatHora(item.fechaCreacion),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                if (item.reintentos > 0)
                  Text(
                    'Reintentos: ${item.reintentos}/${item.maxReintentos}',
                    style: TextStyle(
                      fontSize: 11,
                      color: item.puedeReintentar ? Colors.orange : Colors.red,
                    ),
                  ),
              ],
            ),
            if (item.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.cloud_done_outlined,
              size: 64,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Todo sincronizado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No hay elementos pendientes de sincronización',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildHistorial(List<SyncQueueItem> items) {
    final sincronizados = items
        .where((i) => i.estado == SyncEstado.sincronizado)
        .take(10)
        .toList();

    return sincronizados.map((item) {
      return ListTile(
        dense: true,
        leading: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 18,
        ),
        title: Text(item.id),
        subtitle: Text(item.fechaSync != null ? _formatHora(item.fechaSync!) : ''),
        trailing: Text(
          item.tipo.name.toUpperCase(),
          style: const TextStyle(fontSize: 10),
        ),
      );
    }).toList();
  }

  Color _getPrioridadColor(SyncPrioridad prioridad) {
    return switch (prioridad) {
      SyncPrioridad.urgente => Colors.red,
      SyncPrioridad.alta => Colors.orange,
      SyncPrioridad.normal => Colors.blue,
      SyncPrioridad.baja => Colors.grey,
    };
  }

  String _formatHora(DateTime fecha) {
    return DateFormat('HH:mm').format(fecha);
  }

  Future<void> _sincronizarAhora() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);
    try {
      final syncService = ref.read(syncServiceProvider);
      final procesados = await syncService.procesarCola();

      if (!mounted) return;

      if (procesados > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$procesados elementos sincronizados')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay elementos para sincronizar')),
        );
      }

      ref.refresh(syncQueueProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _limpiarErrores() async {
    final queue = await ref.read(syncQueueProvider.future);
    await queue.limpiarErrores();
    ref.refresh(syncQueueProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Errores marcados para reintentar')),
    );
  }

  Future<void> _eliminarSincronizados() async {
    final queue = await ref.read(syncQueueProvider.future);
    await queue.eliminarSincronizados();
    ref.refresh(syncQueueProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Elementos sincronizados eliminados de la cola')),
    );
  }
}