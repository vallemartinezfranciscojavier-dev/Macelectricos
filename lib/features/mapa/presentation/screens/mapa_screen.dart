import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/ui/ui_info_row.dart';
import '../../../../core/ui/ui_status_badge.dart';
import '../../domain/entities/gps_location.dart';
import '../../domain/entities/map_element.dart';
import '../providers/location_provider.dart';
import 'ubicacion_info_card.dart';

/// Pantalla de mapa con GPS real (Fase 5).
///
/// Integra: permisos de ubicación, posición en tiempo real con tarjeta de
/// lat/long/precisión/fecha, marcadores dinámicos por tipo, selección de
/// marcadores con información del elemento, capas filtrables y validación
/// de precisión antes de registrar.
class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({super.key});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  // Cámara inicial (CDMX como ejemplo); se re-centra con el GPS cuando llega.
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 14,
  );

  bool _cameraCenteredOnGps = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMap());
  }

  Future<void> _initializeMap() async {
    // Cargar los elementos de infraestructura (postes, transformadores, árboles)
    ref.read(mapElementsProvider.notifier).loadElements();
    // Solicitar permiso de ubicación y obtener la primera posición
    await ref.read(locationProvider.notifier).initializeAndRequest();
    _centerOnCurrentLocationIfReady();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elementsState = ref.watch(mapElementsProvider);

    // Centrar la cámara sobre la posición GPS la primera vez que llega.
    ref.listen<LocationState>(locationProvider, (_, next) {
      if (next.status == LocationStatus.ready &&
          next.currentLocation != null &&
          _mapController != null &&
          !_cameraCenteredOnGps) {
        _cameraCenteredOnGps = true;
        _centerCamera(LatLng(
          next.currentLocation!.latitude,
          next.currentLocation!.longitude,
        ));
      }
    });

    // Marcadores dinámicos a partir de los elementos visibles (capas activas).
    final markers = <Marker>{
      for (final element in elementsState.filteredElements)
        _markerForElement(element),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Campo'),
        actions: [
          PopupMenuButton<MapType>(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Tipo de mapa',
            onSelected: (type) => setState(() => _currentMapType = type),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: MapType.normal,
                child: Row(
                  children: [
                    Icon(Icons.map, size: 20),
                    SizedBox(width: 8),
                    Text('Normal'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MapType.satellite,
                child: Row(
                  children: [
                    Icon(Icons.satellite, size: 20),
                    SizedBox(width: 8),
                    Text('Satélite'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MapType.hybrid,
                child: Row(
                  children: [
                    Icon(Icons.layers, size: 20),
                    SizedBox(width: 8),
                    Text('Híbrido'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MapType.terrain,
                child: Row(
                  children: [
                    Icon(Icons.terrain, size: 20),
                    SizedBox(width: 8),
                    Text('Relieve'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
            tooltip: 'Mi ubicación',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showLayersBottomSheet,
            tooltip: 'Capas',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: _currentMapType,
            markers: markers,
            onMapCreated: (controller) {
              _mapController = controller;
              _centerOnCurrentLocationIfReady();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            trafficEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            padding: const EdgeInsets.only(bottom: 96),
          ),

          // Barra de búsqueda / filtros superior
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildSearchBar(context),
          ),

          // Tarjeta GPS (lat/long/precisión/fecha) inferior izquierda
          Positioned(
            bottom: 16,
            left: 16,
            right: 96,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: const UbicacionInfoCard(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_element',
            onPressed: _showAddElementDialog,
            icon: const Icon(Icons.add_location),
            label: const Text('Registrar'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'measure',
            onPressed: _startMeasuring,
            tooltip: 'Medir distancia',
            child: const Icon(Icons.straighten),
          ),
        ],
      ),
    );
  }

  // ============================================
  // MARCADORES
  // ============================================

  Marker _markerForElement(MapElement element) {
    final color = _colorFor(element.type);
    return Marker(
      markerId: MarkerId(element.id),
      position: LatLng(element.latitude, element.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        HSLColor.fromColor(color).hue,
      ),
      infoWindow: InfoWindow(
        title: element.codigo,
        snippet:
            '${_labelFor(element.type)} · ${element.gpsPrecision?.toStringAsFixed(1) ?? '—'} m',
      ),
      onTap: () => _showElementDetails(element),
    );
  }

  // ============================================
  // ACCIONES
  // ============================================

  void _centerCamera(LatLng target) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 16),
      ),
    );
  }

  void _centerOnCurrentLocationIfReady() {
    final loc = ref.read(locationProvider).currentLocation;
    if (loc == null || _cameraCenteredOnGps || _mapController == null) return;
    _cameraCenteredOnGps = true;
    _centerCamera(LatLng(loc.latitude, loc.longitude));
  }

  void _goToCurrentLocation() {
    final loc = ref.read(locationProvider).currentLocation;
    if (loc == null) {
      // Aún no hay posición: reintentar el flujo GPS.
      ref.read(locationProvider.notifier).initializeAndRequest();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obteniendo tu ubicación GPS...')),
      );
      return;
    }
    _centerCamera(LatLng(loc.latitude, loc.longitude));
  }

  void _showLayersBottomSheet() {
    final visible = ref.read(mapElementsProvider).visibleTypes;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => _LayersBottomSheet(
        visibleTypes: visible,
        onLayerToggle: (type, enabled) {
          ref.read(mapElementsProvider.notifier).toggleLayer(type, enabled);
        },
      ),
    );
  }

  void _showFiltersDialog() {
    final notifier = ref.read(mapElementsProvider.notifier);
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final visible = ref.read(mapElementsProvider).visibleTypes;
          return AlertDialog(
            title: const Text('Filtros de Mapa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final type in MapElementType.values)
                  SwitchListTile(
                    value: visible.contains(type),
                    onChanged: (value) {
                      notifier.toggleLayer(type, value);
                      setDialogState(() {});
                    },
                    title: Row(
                      children: [
                        Icon(_iconFor(type), size: 20, color: _colorFor(type)),
                        const SizedBox(width: 12),
                        Text(_labelFor(type)),
                      ],
                    ),
                    secondary: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _colorFor(type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddElementDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => _AddElementBottomSheet(
        onSelect: (type) {
          Navigator.pop(context);
          _handleRegistroSeleccion(type);
        },
      ),
    );
  }

  /// Enruta la selección del bottom sheet "Registrar" según el tipo.
  void _handleRegistroSeleccion(String type) {
    switch (type) {
      case 'poste':
        _attemptRegistro(MapElementType.pole);
      case 'transformador':
        _attemptRegistro(MapElementType.transformer);
      case 'arbol':
        _attemptRegistro(MapElementType.tree);
      default:
        // poda / claro / foto: colección de datos en fases futuras.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrar $type — Fase 3')),
        );
    }
  }

  /// Valida la precisión GPS antes de permitir registrar un elemento (Fase 5).
  void _attemptRegistro(MapElementType type) {
    final locState = ref.read(locationProvider);
    final loc = locState.currentLocation;
    final label = _labelFor(type);

    if (loc == null || locState.status != LocationStatus.ready) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero obtén tu ubicación GPS para poder registrar.'),
        ),
      );
      return;
    }

    final precisionText = loc.accuracyText;
    switch (loc.precisionLevel) {
      case GpsPrecisionLevel.excellent:
        // Precisión <= 10 m: se puede guardar directamente.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$label · GPS $precisionText. Formulario de registro (Fase 3).',
            ),
          ),
        );
      case GpsPrecisionLevel.acceptable:
        // Precisión 10-20 m: permitir mostrar una advertencia.
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Precisión aceptable'),
            content: Text(
              'La precisión actual es $precisionText (10-20 m). Puedes guardar, '
              'pero verifica que estés en el punto exacto del elemento.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '$label registrado con precisión $precisionText — Fase 3.',
                      ),
                    ),
                  );
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      case GpsPrecisionLevel.poor:
        // Precisión > 20 m: NO permitir guardar.
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Precisión GPS insuficiente'),
            content: Text(
              'La precisión actual es $precisionText (mayor a 20 m) y no es '
              'confiable. «$label» no puede guardarse. '
              'Aléjate de edificios y árboles para mejorar la señal e inténtalo de nuevo.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
    }
  }

  void _showElementDetails(MapElement element) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => _ElementDetailsBottomSheet(element: element),
    );
  }

  void _startMeasuring() {
    // TODO: Implementar herramienta de medición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Herramienta de medición — Fase 3')),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Card(
      elevation: 4,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar poste, transformador, dirección...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: _showFiltersDialog,
            tooltip: 'Filtros',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onTap: () {
          // TODO: Abrir búsqueda full screen
        },
      ),
    );
  }
}

// ============================================
// HELPERS VISUALES POR TIPO DE ELEMENTO
// ============================================

Color _colorFor(MapElementType type) {
  switch (type) {
    case MapElementType.pole:
      return AppColors.poste;
    case MapElementType.transformer:
      return AppColors.transformador;
    case MapElementType.tree:
      return AppColors.arbol;
  }
}

IconData _iconFor(MapElementType type) {
  switch (type) {
    case MapElementType.pole:
      return Icons.electric_bolt;
    case MapElementType.transformer:
      return Icons.transform;
    case MapElementType.tree:
      return Icons.park;
  }
}

String _labelFor(MapElementType type) {
  switch (type) {
    case MapElementType.pole:
      return 'Poste';
    case MapElementType.transformer:
      return 'Transformador';
    case MapElementType.tree:
      return 'Árbol';
  }
}

StatusBadgeVariant _precisionVariant(double? precision) {
  if (precision == null) return StatusBadgeVariant.neutral;
  if (precision <= GpsLocation.excellentThreshold) {
    return StatusBadgeVariant.success;
  }
  if (precision <= GpsLocation.acceptableThreshold) {
    return StatusBadgeVariant.warning;
  }
  return StatusBadgeVariant.danger;
}

// ============================================
// WIDGETS AUXILIARES MAPA
// ============================================

/// Bottom sheet con el detalle de un elemento seleccionado en el mapa.
class _ElementDetailsBottomSheet extends StatelessWidget {
  final MapElement element;

  const _ElementDetailsBottomSheet({required this.element});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorFor(element.type);
    final typeEnum = element.type;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: icono + código + tipo
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconFor(typeEnum), size: 26, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      element.codigo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _labelFor(typeEnum),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: '${element.gpsPrecision?.toStringAsFixed(1) ?? '—'} m',
                variant: _precisionVariant(element.gpsPrecision),
                compact: true,
                showDot: true,
              ),
            ],
          ),
          if (element.descripcion != null) ...[
            const SizedBox(height: 12),
            Text(
              element.descripcion!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Ubicación GPS
          InfoRow(
            label: 'Latitud',
            value: element.latitude.toStringAsFixed(6),
            isTopLevel: true,
          ),
          InfoRow(
            label: 'Longitud',
            value: element.longitude.toStringAsFixed(6),
            isTopLevel: true,
          ),
          InfoRow(
            label: 'Precisión GPS',
            value: element.gpsPrecision == null
                ? '—'
                : '${element.gpsPrecision!.toStringAsFixed(1)} m',
            trailing: StatusBadge(
              label: _precisionLabel(element.gpsPrecision),
              variant: _precisionVariant(element.gpsPrecision),
              compact: true,
            ),
          ),

          // Datos específicos por tipo
          if (typeEnum == MapElementType.pole) ...[
            InfoRow(label: 'Material', value: _orDash(element.material)),
            InfoRow(
              label: 'Altura',
              value: element.altura == null ? '—' : '${element.altura} m',
            ),
          ],
          if (typeEnum == MapElementType.transformer) ...[
            InfoRow(
              label: 'Capacidad',
              value: element.kva == null ? '—' : '${element.kva} KVA',
            ),
            InfoRow(label: 'Fases', value: _orDash(element.fase)),
          ],
          if (typeEnum == MapElementType.tree) ...[
            InfoRow(label: 'Especie', value: _orDash(element.especie)),
            InfoRow(
              label: 'Riesgo',
              value: _orDash(element.riesgo?.label),
              trailing: element.riesgo == null
                  ? null
                  : StatusBadge(
                      label: element.riesgo!.label,
                      variant: _riesgoVariant(element.riesgo!),
                      compact: true,
                    ),
            ),
            InfoRow(
              label: 'Distancia a red',
              value:
                  element.distanciaRed == null ? '—' : '${element.distanciaRed} m',
            ),
          ],

          // Registro
          InfoRow(
            label: 'Registrado por',
            value: _orDash(element.registradoPor),
          ),
          InfoRow(
            label: 'Fecha de registro',
            value: _formatFecha(element.fechaRegistro),
          ),
        ],
      ),
    );
  }

  static String _orDash(String? value) => value ?? '—';

  static String _formatFecha(DateTime dt) {
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} $hh:$mm';
  }

  static String _precisionLabel(double? precision) {
    if (precision == null) return 'Sin dato';
    if (precision <= GpsLocation.excellentThreshold) return 'Excelente';
    if (precision <= GpsLocation.acceptableThreshold) return 'Aceptable';
    return 'Pobre';
  }

  static StatusBadgeVariant _riesgoVariant(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.low:
        return StatusBadgeVariant.success;
      case RiskLevel.medium:
        return StatusBadgeVariant.warning;
      case RiskLevel.high:
      case RiskLevel.critical:
        return StatusBadgeVariant.danger;
    }
  }
}

/// Bottom sheet de capas: activa/desactiva tipos de elementos en el mapa.
class _LayersBottomSheet extends StatelessWidget {
  final Set<MapElementType> visibleTypes;
  final void Function(MapElementType type, bool enabled) onLayerToggle;

  const _LayersBottomSheet({
    required this.visibleTypes,
    required this.onLayerToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capas del Mapa',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Muestra u oculta los elementos de infraestructura',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          for (final type in MapElementType.values)
            _MapLayerTile(
              type: type,
              enabled: visibleTypes.contains(type),
              onToggle: (value) => onLayerToggle(type, value),
            ),
          const SizedBox(height: 8),
          Text(
            'Las capas de podas, claros y fotos se integrarán en fases futuras.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLayerTile extends StatelessWidget {
  final MapElementType type;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _MapLayerTile({
    required this.type,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: enabled,
      onChanged: onToggle,
      title: Row(
        children: [
          Icon(_iconFor(type), size: 20, color: _colorFor(type)),
          const SizedBox(width: 12),
          Text(_labelFor(type)),
        ],
      ),
      secondary: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: _colorFor(type),
          shape: BoxShape.circle,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class _AddElementBottomSheet extends StatelessWidget {
  final void Function(String type) onSelect;

  const _AddElementBottomSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final elements = [
      _ElementOption('poste', 'Poste Eléctrico', Icons.electric_bolt, AppColors.poste, 'GPS + Código + Tipo + Fotos'),
      _ElementOption('transformador', 'Transformador', Icons.transform, AppColors.transformador, 'GPS + Código + KVA + Poste asociado'),
      _ElementOption('arbol', 'Árbol', Icons.park, AppColors.arbol, 'GPS + Especie + Riesgo + Poste cercano'),
      _ElementOption('poda', 'Trabajo de Poda', Icons.content_cut, AppColors.poda, 'Árbol + Tiempo + Responsable + Fotos'),
      _ElementOption('claro', 'Claro (Distancia)', Icons.straighten, AppColors.claro, 'Poste A + Poste B + Distancia auto'),
      _ElementOption('foto', 'Foto Evidencia', Icons.photo_camera, AppColors.foto, 'GPS + Descripción + Elemento asociado'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué deseas registrar?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Se valida la precisión GPS antes de permitir el registro',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...elements.map((e) => _ElementTile(option: e, onTap: onSelect)),
        ],
      ),
    );
  }
}

class _ElementOption {
  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const _ElementOption(
    this.type,
    this.label,
    this.icon,
    this.color,
    this.description,
  );
}

class _ElementTile extends StatelessWidget {
  final _ElementOption option;
  final void Function(String type) onTap;

  const _ElementTile({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () => onTap(option.type),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: option.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(option.icon, size: 24, color: option.color),
      ),
      title: Text(
        option.label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        option.description,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}