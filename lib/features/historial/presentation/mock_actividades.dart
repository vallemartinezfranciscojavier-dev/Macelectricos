import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';

/// Estados posibles de una actividad registrada en campo.
enum ActividadEstado {
  completado,
  enProgreso,
  pendiente,
  reportado,
}

/// Extensión con la etiqueta y variante visual de cada estado.
extension ActividadEstadoX on ActividadEstado {
  /// Etiqueta legible en español para el estado.
  String get label => switch (this) {
        ActividadEstado.completado => 'Completado',
        ActividadEstado.enProgreso => 'En progreso',
        ActividadEstado.pendiente => 'Pendiente',
        ActividadEstado.reportado => 'Reportado',
      };

  /// Variante de color del [StatusBadge] asociada al estado.
  StatusBadgeVariant get variante => switch (this) {
        ActividadEstado.completado => StatusBadgeVariant.success,
        ActividadEstado.enProgreso => StatusBadgeVariant.info,
        ActividadEstado.pendiente => StatusBadgeVariant.warning,
        ActividadEstado.reportado => StatusBadgeVariant.danger,
      };
}

/// Registro de una actividad del historial (datos mock, Fase 3).
///
/// Representa una acción registrada por un operario: instalaciones,
/// revisiones, podas, mediciones y evidencia fotográfica.
class ActividadRecord {
  final String id;
  final ElementType tipo;
  final String operario;
  final DateTime fecha;
  final String ubicacion;
  final ActividadEstado estado;
  final String notas;
  final String coordenadas;

  const ActividadRecord({
    required this.id,
    required this.tipo,
    required this.operario,
    required this.fecha,
    required this.ubicacion,
    required this.estado,
    required this.notas,
    required this.coordenadas,
  });
}

/// Lista mock de actividades registradas, usada de ejemplo en la Fase 3.
final List<ActividadRecord> mockActividades = [
  ActividadRecord(
    id: 'PST-2847',
    tipo: ElementType.poste,
    operario: 'Juan Pérez',
    fecha: DateTime(2026, 9, 8, 9, 12),
    ubicacion: 'Av. Reforma 245',
    estado: ActividadEstado.completado,
    notas: 'Poste de concreto instalado, verificado y con placa colocada.',
    coordenadas: '19.4326, -99.1332',
  ),
  ActividadRecord(
    id: 'TRF-1023',
    tipo: ElementType.transformador,
    operario: 'María López',
    fecha: DateTime(2026, 9, 7, 16, 40),
    ubicacion: 'Calle Hidalgo 32, Col. Centro',
    estado: ActividadEstado.enProgreso,
    notas: 'Cambio de transformador de 25 KVA a 50 KVA en curso.',
    coordenadas: '19.4228, -99.1456',
  ),
  ActividadRecord(
    id: 'ARB-0514',
    tipo: ElementType.arbol,
    operario: 'Carlos Ruiz',
    fecha: DateTime(2026, 9, 6, 11, 5),
    ubicacion: 'Prol. Paseo de la Reforma',
    estado: ActividadEstado.completado,
    notas: 'Revisión de inclinación y evaluación de riesgo estructural del árbol.',
    coordenadas: '19.4412, -99.1589',
  ),
  ActividadRecord(
    id: 'POD-0876',
    tipo: ElementType.poda,
    operario: 'Laura Herrera',
    fecha: DateTime(2026, 9, 5, 8, 30),
    ubicacion: 'Calle 5 de Mayo 110',
    estado: ActividadEstado.completado,
    notas: 'Poda de ramas en contacto con línea de media tensión.',
    coordenadas: '19.4283, -99.1397',
  ),
  ActividadRecord(
    id: 'CLA-0341',
    tipo: ElementType.claro,
    operario: 'Juan Pérez',
    fecha: DateTime(2026, 9, 4, 14, 20),
    ubicacion: 'Entre calle Juárez y Allende',
    estado: ActividadEstado.pendiente,
    notas: 'Medición de claro entre postes pendiente de aprobación.',
    coordenadas: '19.4350, -99.1502',
  ),
  ActividadRecord(
    id: 'PST-2760',
    tipo: ElementType.poste,
    operario: 'Miguel Torres',
    fecha: DateTime(2026, 9, 3, 10, 45),
    ubicacion: 'Camino Real 500',
    estado: ActividadEstado.reportado,
    notas: 'Poste con daño en la base reportado para mantenimiento urgente.',
    coordenadas: '19.4187, -99.1210',
  ),
  ActividadRecord(
    id: 'FOT-0211',
    tipo: ElementType.foto,
    operario: 'Ana Gómez',
    fecha: DateTime(2026, 9, 2, 12, 0),
    ubicacion: 'Av. Insurgentes Sur 2000',
    estado: ActividadEstado.completado,
    notas: 'Evidencia fotográfica del estado de la red en la zona.',
    coordenadas: '19.3646, -99.1783',
  ),
];

/// Retorna el registro mock correspondiente a [recordId].
///
/// Si el identificador no existe en la lista de ejemplo, genera un registro
/// por defecto para que la pantalla de detalle siempre tenga datos que
/// mostrar durante la Fase 3.
ActividadRecord mockActividadForId(String recordId) {
  for (final registro in mockActividades) {
    if (registro.id == recordId) {
      return registro;
    }
  }
  return ActividadRecord(
    id: recordId,
    tipo: ElementType.poste,
    operario: 'No asignado',
    fecha: DateTime.now(),
    ubicacion: 'Sin ubicación registrada',
    estado: ActividadEstado.pendiente,
    notas: 'Actividad no encontrada en los datos locales de ejemplo.',
    coordenadas: 'Sin coordenadas',
  );
}