import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/ui/ui_status_badge.dart';
import '../../domain/entities/gps_location.dart';
import '../providers/location_provider.dart';

/// Tarjeta flotante que muestra los datos GPS en tiempo real:
/// latitud, longitud, precisión y fecha (Fase 5).
///
/// Reacciona al estado de [locationProvider]: muestra la información cuando
/// la ubicación está lista, un indicador de carga mientras se obtiene, y
/// mensajes con acciones cuando el permiso fue denegado.
class UbicacionInfoCard extends ConsumerWidget {
  const UbicacionInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);

    final Widget content;
    switch (location.status) {
      case LocationStatus.idle:
        content = _MessageContent(
          icon: Icons.gps_not_fixed,
          title: 'GPS desactivado',
          subtitle: 'Pulsa el botón ubicación para iniciar',
        );
      case LocationStatus.loading:
        content = _LoadingContent(title: 'Obteniendo posición GPS...');
      case LocationStatus.denied:
        content = _ActionContent(
          icon: Icons.location_off_outlined,
          title: 'Permiso de ubicación denegado',
          subtitle: 'Es necesario el GPS para registrar elementos',
          actionLabel: 'Reintentar',
          onAction: () => ref.read(locationProvider.notifier).retryPermission(),
        );
      case LocationStatus.deniedForever:
        content = _ActionContent(
          icon: Icons.location_disabled_outlined,
          title: 'Permiso de ubicación bloqueado',
          subtitle: 'Habilítalo desde los ajustes del sistema',
          actionLabel: 'Abrir ajustes',
          onAction: () => ref.read(locationProvider.notifier).openSettings(),
        );
      case LocationStatus.error:
        content = _ActionContent(
          icon: Icons.error_outline,
          title: 'Error al obtener la posición',
          subtitle: location.error ?? 'Intenta nuevamente',
          actionLabel: 'Reintentar',
          onAction: () => ref.read(locationProvider.notifier).retryPermission(),
        );
      case LocationStatus.ready:
        final gps = location.currentLocation;
        if (gps == null) {
          content = _MessageContent(
            icon: Icons.gps_not_fixed,
            title: 'Sin posición disponible',
            subtitle: 'Esperando señal GPS...',
          );
        } else {
          content = _ReadyContent(gps: gps);
        }
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: content,
        ),
      ),
    );
  }
}

// ============================================
// CONTENIDOS DE LA TARJETA
// ============================================

/// Contenido cuando hay una posición GPS lista: muestra lat/long/precisión/fecha.
class _ReadyContent extends StatelessWidget {
  final GpsLocation gps;

  const _ReadyContent({required this.gps});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lev = gps.precisionLevel;
    final variant = switch (lev) {
      GpsPrecisionLevel.excellent => StatusBadgeVariant.success,
      GpsPrecisionLevel.acceptable => StatusBadgeVariant.warning,
      GpsPrecisionLevel.poor => StatusBadgeVariant.danger,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado: icono + título + badge de precisión
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: lev.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.gps_fixed, size: 18, color: lev.color),
            ),
            const SizedBox(width: 8),
            Text(
              'GPS',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              label: 'Precisión: ${lev.label}',
              variant: variant,
              showDot: true,
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Datos: latitud / longitud
        Row(
          children: [
            Expanded(
              child: _MiniDato(
                label: 'Latitud',
                value: gps.latitude.toStringAsFixed(6),
              ),
            ),
            Expanded(
              child: _MiniDato(
                label: 'Longitud',
                value: gps.longitude.toStringAsFixed(6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Datos: precisión / fecha
        Row(
          children: [
            Expanded(
              child: _MiniDato(
                label: 'Precisión',
                value: gps.accuracyText,
                valueColor: lev.color,
              ),
            ),
            Expanded(
              child: _MiniDato(
                label: 'Fecha',
                value: _formatearFecha(gps.timestamp),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatearFecha(DateTime dt) {
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')} $hh:$mm';
  }
}

/// Dato compacto (etiqueta + valor) dentro de la tarjeta GPS.
class _MiniDato extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MiniDato({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// Contenido genérico: icono + título + subtítulo.
class _MessageContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Contenido con un botón de acción (reintentar / abrir ajustes).
class _ActionContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _ActionContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.settings, size: 18),
            label: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}

/// Contenido con indicador de progreso (obteniendo posición).
class _LoadingContent extends StatelessWidget {
  final String title;

  const _LoadingContent({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}