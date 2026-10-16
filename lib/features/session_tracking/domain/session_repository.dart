import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:macelectricos/core/models/session_models.dart';

/// Contrato del repositorio de sesiones
abstract class SessionRepository {
  /// Iniciar una nueva sesión de trabajo
  Future<Either<SessionFailure, Session>> iniciarSesion({
    required String userId,
    required String cuadrillaId,
  });

  /// Finalizar sesión actual
  Future<Either<SessionFailure, SessionSummary>> finalizarSesion({
    required String sessionId,
  });

  /// Obtener sesión activa del usuario
  Future<Either<SessionFailure, Session?>> obtenerSesionActiva(String userId);

  /// Obtener resumen de una sesión
  Future<Either<SessionFailure, SessionSummary>> obtenerResumenSesion(String sessionId);

  /// Guardar elemento en la sesión
  Future<Either<SessionFailure, void>> guardarElemento(SessionElement elemento);

  /// Obtener todos los elementos de una sesión
  Future<Either<SessionFailure, List<SessionElement>>> obtenerElementosSesion(String sessionId);

  /// Obtener elementos por tipo
  Future<Either<SessionFailure, List<SessionElement>>> obtenerElementosPorTipo(
    String sessionId,
    SessionElementType tipo,
  );

  /// Actualizar contador de la sesión
  Future<Either<SessionFailure, void>> actualizarContadores(String sessionId);

  /// Generar grafo de recorrido de la sesión
  Future<Either<SessionFailure, SessionGraph>> generarGrafoRecorrido(String sessionId);

  /// Exportar sesión completa (JSON/PDF)
  Future<Either<SessionFailure, String>> exportarSesion(String sessionId, ExportFormat formato);

  /// Sincronizar sesión pendiente
  Future<Either<SessionFailure, void>> sincronizarSesion(String sessionId);
}

/// Sesión de trabajo en campo
class Session extends Equatable {
  final String id;
  final String userId;
  final String cuadrillaId;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final SessionEstado estado;
  final SessionContadores contadores;
  final List<String> tecnicosIds;
  final bool sincronizada;

  const Session({
    required this.id,
    required this.userId,
    required this.cuadrillaId,
    required this.fechaInicio,
    this.fechaFin,
    this.estado = SessionEstado.activa,
    this.contadores = const SessionContadores(),
    this.tecnicosIds = const [],
    this.sincronizada = false,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'] as String,
    userId: json['userId'] as String,
    cuadrillaId: json['cuadrillaId'] as String,
    fechaInicio: DateTime.parse(json['fechaInicio'] as String),
    fechaFin: json['fechaFin'] != null
        ? DateTime.parse(json['fechaFin'] as String)
        : null,
    estado: SessionEstado.values.byName(json['estado'] as String),
    contadores: SessionContadores.fromJson(json['contadores'] as Map<String, dynamic>),
    tecnicosIds: List<String>.from(json['tecnicosIds'] ?? []),
    sincronizada: json['sincronizada'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'cuadrillaId': cuadrillaId,
    'fechaInicio': fechaInicio.toIso8601String(),
    'fechaFin': fechaFin?.toIso8601String(),
    'estado': estado.name,
    'contadores': contadores.toJson(),
    'tecnicosIds': tecnicosIds,
    'sincronizada': sincronizada,
  };

  Session copyWith({
    DateTime? fechaFin,
    SessionEstado? estado,
    SessionContadores? contadores,
    List<String>? tecnicosIds,
    bool? sincronizada,
  }) => Session(
    id: id,
    userId: userId,
    cuadrillaId: cuadrillaId,
    fechaInicio: fechaInicio,
    fechaFin: fechaFin ?? this.fechaFin,
    estado: estado ?? this.estado,
    contadores: contadores ?? this.contadores,
    tecnicosIds: tecnicosIds ?? this.tecnicosIds,
    sincronizada: sincronizada ?? this.sincronizada,
  );

  Duration get duracion => (fechaFin ?? DateTime.now()).difference(fechaInicio);

  @override
  List<Object?> get props => [
    id,
    userId,
    cuadrillaId,
    fechaInicio,
    fechaFin,
    estado,
    contadores,
    tecnicosIds,
    sincronizada,
  ];
}

/// Estado de la sesión
enum SessionEstado {
  activa,
  pausada,
  finalizada,
  sincronizando,
  error,
}

/// Contadores automáticos durante la sesión
class SessionContadores extends Equatable {
  final int postes;
  final int transformadores;
  final int arboles;
  final int podas;
  final int claros;
  final int fotos;
  final double distanciaTotalClaros;
  final DateTime? ultimaActualizacion;

  const SessionContadores({
    this.postes = 0,
    this.transformadores = 0,
    this.arboles = 0,
    this.podas = 0,
    this.claros = 0,
    this.fotos = 0,
    this.distanciaTotalClaros = 0.0,
    this.ultimaActualizacion,
  });

  factory SessionContadores.fromJson(Map<String, dynamic> json) => SessionContadores(
    postes: json['postes'] as int? ?? 0,
    transformadores: json['transformadores'] as int? ?? 0,
    arboles: json['arboles'] as int? ?? 0,
    podas: json['podas'] as int? ?? 0,
    claros: json['claros'] as int? ?? 0,
    fotos: json['fotos'] as int? ?? 0,
    distanciaTotalClaros: (json['distanciaTotalClaros'] as num?)?.toDouble() ?? 0.0,
    ultimaActualizacion: DateTime.parse(json['ultimaActualizacion'] as String),
  );

  Map<String, dynamic> toJson() => {
    'postes': postes,
    'transformadores': transformadores,
    'arboles': arboles,
    'podas': podas,
    'claros': claros,
    'fotos': fotos,
    'distanciaTotalClaros': distanciaTotalClaros,
    'ultimaActualizacion': (ultimaActualizacion ?? DateTime.now()).toIso8601String(),
  };

  SessionContadores incrementar(SessionElementType tipo, {double distanciaClaro = 0.0}) {
    return SessionContadores(
      postes: postes + (tipo == SessionElementType.poste ? 1 : 0),
      transformadores: transformadores + (tipo == SessionElementType.transformador ? 1 : 0),
      arboles: arboles + (tipo == SessionElementType.arbol ? 1 : 0),
      podas: podas + (tipo == SessionElementType.poda ? 1 : 0),
      claros: claros + (tipo == SessionElementType.claro ? 1 : 0),
      fotos: fotos + (tipo == SessionElementType.foto ? 1 : 0),
      distanciaTotalClaros: distanciaTotalClaros + distanciaClaro,
      ultimaActualizacion: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    postes,
    transformadores,
    arboles,
    podas,
    claros,
    fotos,
    distanciaTotalClaros,
    ultimaActualizacion,
  ];
}

/// Grafo de recorrido generado al final de la sesión
class SessionGraph extends Equatable {
  final String sessionId;
  final List<GraphNode> nodos;
  final List<GraphEdge> aristas;
  final List<GraphRoute> rutas;
  final GraphStats estadisticas;
  final DateTime generadoEn;

  const SessionGraph({
    required this.sessionId,
    required this.nodos,
    required this.aristas,
    required this.rutas,
    required this.estadisticas,
    required this.generadoEn,
  });

  factory SessionGraph.fromJson(Map<String, dynamic> json) => SessionGraph(
    sessionId: json['sessionId'] as String,
    nodos: (json['nodos'] as List).map((e) => GraphNode.fromJson(e)).toList(),
    aristas: (json['aristas'] as List).map((e) => GraphEdge.fromJson(e)).toList(),
    rutas: (json['rutas'] as List).map((e) => GraphRoute.fromJson(e)).toList(),
    estadisticas: GraphStats.fromJson(json['estadisticas']),
    generadoEn: DateTime.parse(json['generadoEn'] as String),
  );

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'nodos': nodos.map((e) => e.toJson()).toList(),
    'aristas': aristas.map((e) => e.toJson()).toList(),
    'rutas': rutas.map((e) => e.toJson()).toList(),
    'estadisticas': estadisticas.toJson(),
    'generadoEn': generadoEn.toIso8601String(),
  };

  @override
  List<Object?> get props => [sessionId, nodos, aristas, rutas, estadisticas, generadoEn];
}

/// Nodo del grafo (poste, transformador, árbol, etc.)
class GraphNode extends Equatable {
  final String id;
  final String label;
  final GraphNodeType tipo;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime timestamp;
  final String? codigo;
  final Map<String, dynamic> propiedades;
  final List<String> fotosIds;

  const GraphNode({
    required this.id,
    required this.label,
    required this.tipo,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.timestamp,
    this.codigo,
    this.propiedades = const {},
    this.fotosIds = const [],
  });

  factory GraphNode.fromJson(Map<String, dynamic> json) => GraphNode(
    id: json['id'] as String,
    label: json['label'] as String,
    tipo: GraphNodeType.values.byName(json['tipo'] as String),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    altitude: (json['altitude'] as num?)?.toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    codigo: json['codigo'] as String?,
    propiedades: Map<String, dynamic>.from(json['propiedades'] ?? {}),
    fotosIds: List<String>.from(json['fotosIds'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'tipo': tipo.name,
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'timestamp': timestamp.toIso8601String(),
    'codigo': codigo,
    'propiedades': propiedades,
    'fotosIds': fotosIds,
  };

  @override
  List<Object?> get props => [id, label, tipo, latitude, longitude, altitude, timestamp, codigo, propiedades, fotosIds];
}

enum GraphNodeType {
  poste,
  transformador,
  arbol,
  poda,
  inicio,
  fin,
}

/// Arista del grafo (conexión entre nodos - claros, podas, etc.)
class GraphEdge extends Equatable {
  final String id;
  final String origenId;
  final String destinoId;
  final GraphEdgeType tipo;
  final double distanciaMetros;
  final DateTime timestamp;
  final Map<String, dynamic> propiedades;

  const GraphEdge({
    required this.id,
    required this.origenId,
    required this.destinoId,
    required this.tipo,
    required this.distanciaMetros,
    required this.timestamp,
    this.propiedades = const {},
  });

  factory GraphEdge.fromJson(Map<String, dynamic> json) => GraphEdge(
    id: json['id'] as String,
    origenId: json['origenId'] as String,
    destinoId: json['destinoId'] as String,
    tipo: GraphEdgeType.values.byName(json['tipo'] as String),
    distanciaMetros: (json['distanciaMetros'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    propiedades: Map<String, dynamic>.from(json['propiedades'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'origenId': origenId,
    'destinoId': destinoId,
    'tipo': tipo.name,
    'distanciaMetros': distanciaMetros,
    'timestamp': timestamp.toIso8601String(),
    'propiedades': propiedades,
  };

  @override
  List<Object?> get props => [id, origenId, destinoId, tipo, distanciaMetros, timestamp, propiedades];
}

enum GraphEdgeType {
  claro,
  poda,
  desplazamiento,
  vinculacion,
}

/// Ruta calculada en el grafo
class GraphRoute extends Equatable {
  final String id;
  final List<String> nodosOrdenados;
  final double distanciaTotal;
  final Duration tiempoEstimado;
  final String descripcion;

  const GraphRoute({
    required this.id,
    required this.nodosOrdenados,
    required this.distanciaTotal,
    required this.tiempoEstimado,
    required this.descripcion,
  });

  factory GraphRoute.fromJson(Map<String, dynamic> json) => GraphRoute(
    id: json['id'] as String,
    nodosOrdenados: List<String>.from(json['nodosOrdenados'] as List),
    distanciaTotal: (json['distanciaTotal'] as num).toDouble(),
    tiempoEstimado: Duration(seconds: json['tiempoEstimadoSegundos'] as int),
    descripcion: json['descripcion'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nodosOrdenados': nodosOrdenados,
    'distanciaTotal': distanciaTotal,
    'tiempoEstimadoSegundos': tiempoEstimado.inSeconds,
    'descripcion': descripcion,
  };

  @override
  List<Object?> get props => [id, nodosOrdenados, distanciaTotal, tiempoEstimado, descripcion];
}

/// Estadísticas del grafo
class GraphStats extends Equatable {
  final int totalNodos;
  final int totalAristas;
  final double distanciaTotalRecorrida;
  final double areaCubiertaKm2;
  final int componentesConexos;
  final Duration tiempoTotalTrabajo;
  final Map<GraphNodeType, int> nodosPorTipo;
  final Map<GraphEdgeType, int> aristasPorTipo;

  const GraphStats({
    required this.totalNodos,
    required this.totalAristas,
    required this.distanciaTotalRecorrida,
    required this.areaCubiertaKm2,
    required this.componentesConexos,
    required this.tiempoTotalTrabajo,
    required this.nodosPorTipo,
    required this.aristasPorTipo,
  });

  factory GraphStats.fromJson(Map<String, dynamic> json) => GraphStats(
    totalNodos: json['totalNodos'] as int,
    totalAristas: json['totalAristas'] as int,
    distanciaTotalRecorrida: (json['distanciaTotalRecorrida'] as num).toDouble(),
    areaCubiertaKm2: (json['areaCubiertaKm2'] as num).toDouble(),
    componentesConexos: json['componentesConexos'] as int,
    tiempoTotalTrabajo: Duration(seconds: json['tiempoTotalTrabajoSegundos'] as int),
    nodosPorTipo: Map<GraphNodeType, int>.from(
      (json['nodosPorTipo'] as Map).map((k, v) => MapEntry(GraphNodeType.values.byName(k), v as int)),
    ),
    aristasPorTipo: Map<GraphEdgeType, int>.from(
      (json['aristasPorTipo'] as Map).map((k, v) => MapEntry(GraphEdgeType.values.byName(k), v as int)),
    ),
  );

  Map<String, dynamic> toJson() => {
    'totalNodos': totalNodos,
    'totalAristas': totalAristas,
    'distanciaTotalRecorrida': distanciaTotalRecorrida,
    'areaCubiertaKm2': areaCubiertaKm2,
    'componentesConexos': componentesConexos,
    'tiempoTotalTrabajoSegundos': tiempoTotalTrabajo.inSeconds,
    'nodosPorTipo': nodosPorTipo.map((k, v) => MapEntry(k.name, v)),
    'aristasPorTipo': aristasPorTipo.map((k, v) => MapEntry(k.name, v)),
  };

  @override
  List<Object?> get props => [
    totalNodos,
    totalAristas,
    distanciaTotalRecorrida,
    areaCubiertaKm2,
    componentesConexos,
    tiempoTotalTrabajo,
    nodosPorTipo,
    aristasPorTipo,
  ];
}

/// Formatos de exportación
enum ExportFormat {
  json,
  pdf,
  csv,
  geojson,
  kml,
}

/// Fallos del repositorio
class SessionFailure extends Equatable {
  final String mensaje;
  final SessionFailureType tipo;

  const SessionFailure(this.mensaje, {this.tipo = SessionFailureType.desconocido});

  @override
  List<Object?> get props => [mensaje, tipo];
}

enum SessionFailureType {
  sesionNoEncontrada,
  sesionYaActiva,
  errorAlmacenamiento,
  errorRed,
  errorPermisos,
  datosInvalidos,
  sesionNoFinalizada,
  desconocido,
}