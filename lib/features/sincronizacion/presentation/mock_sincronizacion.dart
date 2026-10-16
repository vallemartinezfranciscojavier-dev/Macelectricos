import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Estado de sincronización de un elemento de la cola.
enum SyncEstado {
  pendiente,
  sincronizado,
  error,
}

/// Extensión con la etiqueta y variante visual de cada estado.
extension SyncEstadoX on SyncEstado {
  /// Etiqueta legible en español para el estado.
  String get label => switch (this) {
        SyncEstado.pendiente => 'Pendiente',
        SyncEstado.sincronizado => 'Sincronizado',
        SyncEstado.error => 'Error',
      };

  /// Variante de color del [StatusBadge] asociada al estado.
  StatusBadgeVariant get variante => switch (this) {
        SyncEstado.pendiente => StatusBadgeVariant.warning,
        SyncEstado.sincronizado => StatusBadgeVariant.success,
        SyncEstado.error => StatusBadgeVariant.danger,
      };
}

/// Elemento de la cola de sincronización local (datos mock, Fase 3).
///
/// Representa un registro generado en campo que espera ser subido al
/// servidor, ya está sincronizado o falló durante el intento.
class SyncQueueItem {
  final String id;
  final ElementType tipo;
  final String descripcion;
  final SyncEstado estado;

  const SyncQueueItem({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.estado,
  });
}

/// Cola de sincronización mock de ejemplo.
final List<SyncQueueItem> mockColaSincronizacion = [
  SyncQueueItem(
    id: 'PST-2847',
    tipo: ElementType.poste,
    descripcion: 'Poste nuevo con registro de GPS',
    estado: SyncEstado.pendiente,
  ),
  SyncQueueItem(
    id: 'CLA-0341',
    tipo: ElementType.claro,
    descripcion: 'Medición de claro entre postes',
    estado: SyncEstado.pendiente,
  ),
  SyncQueueItem(
    id: 'POD-0876',
    tipo: ElementType.poda,
    descripcion: 'Reporte de poda completada',
    estado: SyncEstado.pendiente,
  ),
  SyncQueueItem(
    id: 'TRF-1023',
    tipo: ElementType.transformador,
    descripcion: 'Cambio de transformador en curso',
    estado: SyncEstado.error,
  ),
  SyncQueueItem(
    id: 'FOT-0211',
    tipo: ElementType.foto,
    descripcion: 'Evidencia fotográfica de red',
    estado: SyncEstado.sincronizado,
  ),
  SyncQueueItem(
    id: 'ARB-0514',
    tipo: ElementType.arbol,
    descripcion: 'Inspección de árbol en riesgo',
    estado: SyncEstado.sincronizado,
  ),
];

/// Cantidad de elementos que aún no se han sincronizado (pendientes y con error).
int get mockPendientesPorSubir => mockColaSincronizacion
    .where((item) => item.estado != SyncEstado.sincronizado)
    .length;

/// Cantidad de elementos sincronizados correctamente.
int get mockSincronizados => mockColaSincronizacion
    .where((item) => item.estado == SyncEstado.sincronizado)
    .length;

/// Fecha mock de la última sincronización exitosa.
final DateTime mockUltimaSincronizacion = DateTime(2026, 9, 8, 6, 45);