import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:macelectricos/core/ui/element_icons.dart';
import 'package:macelectricos/core/ui/ui_status_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Estado de sincronización de un elemento
enum SyncEstado {
  localOnly,    // Solo guardo localmente
  pendingSync,  // Esperando para sincronizar
  sincronizando, // En proceso de sync
  sincronizado, // Ya sincronizado
  syncError,    // Error en sincronización
}

/// Prioridad de operaciones en la cola
enum SyncPrioridad {
  baja,    // Podas, reportes
  normal,  // Registros normales
  alta,    // Transformadores, trabajos críticos
  urgente, // Emergencias
}

/// Tipo de operación de sincronización
enum SyncOperacion {
  create,
  update,
  delete,
}

/// Elemento de la cola de sincronización
class SyncQueueItem extends Equatable {
  final String id;
  final ElementType tipo;
  final SyncOperacion operacion;
  final String descripcion;
  final SyncEstado estado;
  final SyncPrioridad prioridad;
  final DateTime fechaCreacion;
  final DateTime? fechaSync;
  final int reintentos;
  final int maxReintentos;
  final Map<String, dynamic> datos;
  final String? error;

  const SyncQueueItem({
    required this.id,
    required this.tipo,
    required this.operacion,
    required this.descripcion,
    required this.estado,
    required this.prioridad,
    required this.fechaCreacion,
    this.fechaSync,
    this.reintentos = 0,
    this.maxReintentos = 3,
    required this.datos,
    this.error,
  });

  /// Crear desde JSON (para storage)
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'] as String,
      tipo: ElementType.values.byName(json['tipo'] as String),
      operacion: SyncOperacion.values.byName(json['operacion'] as String),
      descripcion: json['descripcion'] as String,
      estado: SyncEstado.values.byName(json['estado'] as String),
      prioridad: SyncPrioridad.values.byName(json['prioridad'] as String),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaSync: json['fechaSync'] != null ? DateTime.parse(json['fechaSync'] as String) : null,
      reintentos: json['reintentos'] as int,
      maxReintentos: json['maxReintentos'] as int,
      datos: Map<String, dynamic>.from(json['datos'] as Map<String, dynamic>),
      error: json['error'] as String?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'tipo': tipo.name,
    'operacion': operacion.name,
    'descripcion': descripcion,
    'estado': estado.name,
    'prioridad': prioridad.name,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'fechaSync': fechaSync?.toIso8601String(),
    'reintentos': reintentos,
    'maxReintentos': maxReintentos,
    'datos': datos,
    'error': error,
  };

  /// Si puede reintentar
  bool get puedeReintentar => reintentos < maxReintentos;

  /// Clonar con nuevos valores
  SyncQueueItem copyWith({
    String? id,
    ElementType? tipo,
    SyncOperacion? operacion,
    String? descripcion,
    SyncEstado? estado,
    SyncPrioridad? prioridad,
    DateTime? fechaCreacion,
    DateTime? fechaSync,
    int? reintentos,
    int? maxReintentos,
    Map<String, dynamic>? datos,
    String? error,
  }) {
    return SyncQueueItem(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      operacion: operacion ?? this.operacion,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaSync: fechaSync ?? this.fechaSync,
      reintentos: reintentos ?? this.reintentos,
      maxReintentos: maxReintentos ?? this.maxReintentos,
      datos: datos ?? this.datos,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tipo,
    operacion,
    descripcion,
    estado,
    prioridad,
    fechaCreacion,
    fechaSync,
    reintentos,
    maxReintentos,
    datos,
    error,
  ];
}

/// Extensiones para etiquetas y variantes visuales
extension SyncEstadoX on SyncEstado {
  String get label => switch (this) {
    SyncEstado.localOnly => 'Solo local',
    SyncEstado.pendingSync => 'Pendiente',
    SyncEstado.sincronizando => 'Sincronizando...',
    SyncEstado.sincronizado => 'Sincronizado',
    SyncEstado.syncError => 'Error',
  };

  StatusBadgeVariant get variante => switch (this) {
    SyncEstado.localOnly => StatusBadgeVariant.info,
    SyncEstado.pendingSync => StatusBadgeVariant.warning,
    SyncEstado.sincronizando => StatusBadgeVariant.info,
    SyncEstado.sincronizado => StatusBadgeVariant.success,
    SyncEstado.syncError => StatusBadgeVariant.danger,
  };
}

extension SyncPrioridadX on SyncPrioridad {
  String get label => switch (this) {
    SyncPrioridad.baja => 'Baja',
    SyncPrioridad.normal => 'Normal',
    SyncPrioridad.alta => 'Alta',
    SyncPrioridad.urgente => 'Urgente',
  };

  int get orden => switch (this) {
    SyncPrioridad.urgente => 0,
    SyncPrioridad.alta => 1,
    SyncPrioridad.normal => 2,
    SyncPrioridad.baja => 3,
  };
}

/// Cola de sincronización real con persistencia
class SyncQueue {
  static const _prefKey = 'sync_queue';
  static const _prefLastSync = 'last_sync_timestamp';

  final SharedPreferences _prefs;
  final List<SyncQueueItem> _cola;

  SyncQueue({required SharedPreferences prefs})
    : _prefs = prefs,
      _cola = [];

  /// Inicializar cargando desde storage
  Future<void> init() async {
    final jsonString = _prefs.getString(_prefKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString) as List;
      _cola.clear();
      _cola.addAll(
        jsonList.map((json) => SyncQueueItem.fromJson(json as Map<String, dynamic>)),
      );
    }
  }

  /// Guardar estado actual
  Future<void> _save() async {
    final jsonList = _cola.map((item) => item.toJson()).toList();
    await _prefs.setString(_prefKey, jsonEncode(jsonList));
  }

  /// Agregar elemento a la cola
  Future<void> agregar({
    required ElementType tipo,
    required SyncOperacion operacion,
    required String descripcion,
    required Map<String, dynamic> datos,
    SyncPrioridad prioridad = SyncPrioridad.normal,
  }) async {
    final item = SyncQueueItem(
      id: '${tipo.name.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}',
      tipo: tipo,
      operacion: operacion,
      descripcion: descripcion,
      estado: SyncEstado.pendingSync,
      prioridad: prioridad,
      fechaCreacion: DateTime.now(),
      datos: datos,
    );

    _cola.insert(0, item);
    await _save();
  }

  /// Marcar como sincronizado
  Future<void> marcarSincronizado(String id, [DateTime? fecha]) async {
    final index = _cola.indexWhere((item) => item.id == id);
    if (index != -1) {
      _cola[index] = _cola[index].copyWith(
        estado: SyncEstado.sincronizado,
        fechaSync: fecha ?? DateTime.now(),
        error: null,
      );
      await _save();
    }
  }

  /// Marcar error
  Future<void> marcarError(String id, String mensajeError) async {
    final index = _cola.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _cola[index];
      final nuevosReintentos = item.reintentos + 1;

      if (nuevosReintentos >= item.maxReintentos) {
        _cola[index] = item.copyWith(
          estado: SyncEstado.syncError,
          reintentos: nuevosReintentos,
          error: mensajeError,
        );
      } else {
        _cola[index] = item.copyWith(
          estado: SyncEstado.pendingSync,
          reintentos: nuevosReintentos,
          error: mensajeError,
        );
      }
      await _save();
    }
  }

  /// Marcar como sincronizando
  Future<void> marcarSincronizando(String id) async {
    final index = _cola.indexWhere((item) => item.id == id);
    if (index != -1) {
      _cola[index] = _cola[index].copyWith(estado: SyncEstado.sincronizando);
      await _save();
    }
  }

  /// Eliminar elemento sincronizado
  Future<void> eliminarSincronizados() async {
    _cola.removeWhere((item) => item.estado == SyncEstado.sincronizado);
    await _save();
  }

  /// Obtener pendientes ordenados por prioridad
  List<SyncQueueItem> getPendientesPorPrioridad() {
    return _cola
        .where((item) =>
            item.estado == SyncEstado.pendingSync ||
            (item.estado == SyncEstado.syncError && item.puedeReintentar))
        .toList()
      ..sort((a, b) => a.prioridad.orden.compareTo(b.prioridad.orden));
  }

  /// Contar pendientes
  int get pendientesCount {
    return _cola.where((item) =>
      item.estado == SyncEstado.pendingSync ||
      item.estado == SyncEstado.syncError
    ).length;
  }

  /// Contar sincronizados
  int get sincronizadosCount {
    return _cola.where((item) => item.estado == SyncEstado.sincronizado).length;
  }

  /// Obtener por ID
  SyncQueueItem? obtener(String id) {
    try {
      return _cola.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener todos
  List<SyncQueueItem> obtenerTodos() => List.unmodifiable(_cola);

  /// Obtener fecha de última sincronización
  DateTime? get lastSyncTime {
    final timestamp = _prefs.getInt(_prefLastSync);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Actualizar fecha de última sincronización
  Future<void> actualizarLastSyncTime() async {
    await _prefs.setInt(_prefLastSync, DateTime.now().millisecondsSinceEpoch);
  }

  /// Limpiar errores (para reintentar)
  Future<void> limpiarErrores() async {
    for (var i = 0; i < _cola.length; i++) {
      if (_cola[i].estado == SyncEstado.syncError && _cola[i].puedeReintentar) {
        _cola[i] = _cola[i].copyWith(
          estado: SyncEstado.pendingSync,
          error: null,
        );
      }
    }
    await _save();
  }

  /// Obtener estadísticas
  Map<String, int> get estadisticas {
    return {
      'total': _cola.length,
      'pendientes': pendientesCount,
      'sincronizados': sincronizadosCount,
      'errores': _cola.where((i) => i.estado == SyncEstado.syncError).length,
    };
  }
}