import 'package:equatable/equatable.dart';

/// Tipos de elementos que se pueden registrar en una sesión
enum SessionElementType {
  poste,
  transformador,
  arbol,
  poda,
  claro,
  foto,
}

/// Modelo base para cualquier elemento registrado en sesión
abstract class SessionElement extends Equatable {
  final String id;
  final SessionElementType type;
  final DateTime timestamp;
  final String userId;
  final String sessionId;
  final Map<String, dynamic> metadata;

  const SessionElement({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.userId,
    required this.sessionId,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [id, type, timestamp, userId, sessionId, metadata];
}

/// Poste eléctrico con coordenadas GPS
class Poste extends SessionElement {
  final double latitude;
  final double longitude;
  final double? altitude;
  final String? codigoPoste;
  final String? tipoPoste; // concreto, madera, acero
  final double? altura;
  final String? observaciones;
  final List<String> fotosIds;

  const Poste({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.sessionId,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.codigoPoste,
    this.tipoPoste,
    this.altura,
    this.observaciones,
    this.fotosIds = const [],
    super.metadata,
  }) : super(type: SessionElementType.poste);

  factory Poste.fromJson(Map<String, dynamic> json) => Poste(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    userId: json['userId'] as String,
    sessionId: json['sessionId'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    altitude: (json['altitude'] as num?)?.toDouble(),
    codigoPoste: json['codigoPoste'] as String?,
    tipoPoste: json['tipoPoste'] as String?,
    altura: (json['altura'] as num?)?.toDouble(),
    observaciones: json['observaciones'] as String?,
    fotosIds: List<String>.from(json['fotosIds'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'codigoPoste': codigoPoste,
    'tipoPoste': tipoPoste,
    'altura': altura,
    'observaciones': observaciones,
    'fotosIds': fotosIds,
    'metadata': metadata,
  };

  @override
  List<Object?> get props => [
    ...super.props,
    latitude,
    longitude,
    altitude,
    codigoPoste,
    tipoPoste,
    altura,
    observaciones,
    fotosIds,
  ];
}

/// Transformador eléctrico
class Transformador extends SessionElement {
  final double latitude;
  final double longitude;
  final String? codigoTransformador;
  final double? potenciaKva;
  final String? tipoTransformador;
  final int? numeroFases;
  final String? observaciones;
  final List<String> fotosIds;
  final String? posteIdAsociado;

  const Transformador({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.sessionId,
    required this.latitude,
    required this.longitude,
    this.codigoTransformador,
    this.potenciaKva,
    this.tipoTransformador,
    this.numeroFases,
    this.observaciones,
    this.fotosIds = const [],
    this.posteIdAsociado,
    super.metadata,
  }) : super(type: SessionElementType.transformador);

  factory Transformador.fromJson(Map<String, dynamic> json) => Transformador(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    userId: json['userId'] as String,
    sessionId: json['sessionId'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    codigoTransformador: json['codigoTransformador'] as String?,
    potenciaKva: (json['potenciaKva'] as num?)?.toDouble(),
    tipoTransformador: json['tipoTransformador'] as String?,
    numeroFases: json['numeroFases'] as int?,
    observaciones: json['observaciones'] as String?,
    fotosIds: List<String>.from(json['fotosIds'] ?? []),
    posteIdAsociado: json['posteIdAsociado'] as String?,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'latitude': latitude,
    'longitude': longitude,
    'codigoTransformador': codigoTransformador,
    'potenciaKva': potenciaKva,
    'tipoTransformador': tipoTransformador,
    'numeroFases': numeroFases,
    'observaciones': observaciones,
    'fotosIds': fotosIds,
    'posteIdAsociado': posteIdAsociado,
    'metadata': metadata,
  };
}

/// Árbol detectado cerca de infraestructura
class Arbol extends SessionElement {
  final double latitude;
  final double longitude;
  final String? especie;
  final double? alturaAproximada;
  final double? distanciaAlPoste;
  final String? posteCercanoId;
  final String? riesgo; // alto, medio, bajo
  final String? observaciones;
  final List<String> fotosIds;

  const Arbol({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.sessionId,
    required this.latitude,
    required this.longitude,
    this.especie,
    this.alturaAproximada,
    this.distanciaAlPoste,
    this.posteCercanoId,
    this.riesgo,
    this.observaciones,
    this.fotosIds = const [],
    super.metadata,
  }) : super(type: SessionElementType.arbol);

  factory Arbol.fromJson(Map<String, dynamic> json) => Arbol(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    userId: json['userId'] as String,
    sessionId: json['sessionId'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    especie: json['especie'] as String?,
    alturaAproximada: (json['alturaAproximada'] as num?)?.toDouble(),
    distanciaAlPoste: (json['distanciaAlPoste'] as num?)?.toDouble(),
    posteCercanoId: json['posteCercanoId'] as String?,
    riesgo: json['riesgo'] as String?,
    observaciones: json['observaciones'] as String?,
    fotosIds: List<String>.from(json['fotosIds'] ?? []),
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'latitude': latitude,
    'longitude': longitude,
    'especie': especie,
    'alturaAproximada': alturaAproximada,
    'distanciaAlPoste': distanciaAlPoste,
    'posteCercanoId': posteCercanoId,
    'riesgo': riesgo,
    'observaciones': observaciones,
    'fotosIds': fotosIds,
    'metadata': metadata,
  };
}

/// Trabajo de poda realizado
class Poda extends SessionElement {
  final String arbolId;
  final double latitude;
  final double longitude;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? responsable;
  final String? herramientaUtilizada;
  final String? observaciones;
  final List<String> fotosIds;
  final bool completada;

  const Poda({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.sessionId,
    required this.arbolId,
    required this.latitude,
    required this.longitude,
    required this.fechaInicio,
    required this.fechaFin,
    this.responsable,
    this.herramientaUtilizada,
    this.observaciones,
    this.fotosIds = const [],
    this.completada = false,
    super.metadata,
  }) : super(type: SessionElementType.poda);

  factory Poda.fromJson(Map<String, dynamic> json) => Poda(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    userId: json['userId'] as String,
    sessionId: json['sessionId'] as String,
    arbolId: json['arbolId'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    fechaInicio: DateTime.parse(json['fechaInicio'] as String),
    fechaFin: DateTime.parse(json['fechaFin'] as String),
    responsable: json['responsable'] as String?,
    herramientaUtilizada: json['herramientaUtilizada'] as String?,
    observaciones: json['observaciones'] as String?,
    fotosIds: List<String>.from(json['fotosIds'] ?? []),
    completada: json['completada'] as bool? ?? false,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'arbolId': arbolId,
    'latitude': latitude,
    'longitude': longitude,
    'fechaInicio': fechaInicio.toIso8601String(),
    'fechaFin': fechaFin.toIso8601String(),
    'responsable': responsable,
    'herramientaUtilizada': herramientaUtilizada,
    'observaciones': observaciones,
    'fotosIds': fotosIds,
    'completada': completada,
    'metadata': metadata,
  };

  Duration get duracion => fechaFin.difference(fechaInicio);
}

/// Claro (distancia entre dos postes)
class Claro extends SessionElement {
  final String posteOrigenId;
  final String posteDestinoId;
  final double distanciaMetros;
  final double latitudeOrigen;
  final double longitudeOrigen;
  final double latitudeDestino;
  final double longitudeDestino;
  final String? tipoCable;
  final int? numeroCables;
  final String? observaciones;

  const Claro({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.sessionId,
    required this.posteOrigenId,
    required this.posteDestinoId,
    required this.distanciaMetros,
    required this.latitudeOrigen,
    required this.longitudeOrigen,
    required this.latitudeDestino,
    required this.longitudeDestino,
    this.tipoCable,
    this.numeroCables,
    this.observaciones,
    super.metadata,
  }) : super(type: SessionElementType.claro);

  factory Claro.fromJson(Map<String, dynamic> json) => Claro(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    userId: json['userId'] as String,
    sessionId: json['sessionId'] as String,
    posteOrigenId: json['posteOrigenId'] as String,
    posteDestinoId: json['posteDestinoId'] as String,
    distanciaMetros: (json['distanciaMetros'] as num).toDouble(),
    latitudeOrigen: (json['latitudeOrigen'] as num).toDouble(),
    longitudeOrigen: (json['longitudeOrigen'] as num).toDouble(),
    latitudeDestino: (json['latitudeDestino'] as num).toDouble(),
    longitudeDestino: (json['longitudeDestino'] as num).toDouble(),
    tipoCable: json['tipoCable'] as String?,
    numeroCables: json['numeroCables'] as int?,
    observaciones: json['observaciones'] as String?,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'posteOrigenId': posteOrigenId,
    'posteDestinoId': posteDestinoId,
    'distanciaMetros': distanciaMetros,
    'latitudeOrigen': latitudeOrigen,
    'longitudeOrigen': longitudeOrigen,
    'latitudeDestino': latitudeDestino,
    'longitudeDestino': longitudeDestino,
    'tipoCable': tipoCable,
    'numeroCables': numeroCables,
    'observaciones': observaciones,
    'metadata': metadata,
  };
}

/// Fotografía como evidencia
class FotoEvidencia extends SessionElement {
  final String rutaLocal;
  final String? rutaRemota;
  final double latitude;
  final double longitude;
  final String? descripcion;
  final String? elementoAsociadoId;
  final SessionElementType? elementoAsociadoTipo;
  final int? tamanoBytes;

  const FotoEvidencia({
    required super.id,
    required super.timestamp,
    required super.userId,
    required super.sessionId,
    required this.rutaLocal,
    this.rutaRemota,
    required this.latitude,
    required this.longitude,
    this.descripcion,
    this.elementoAsociadoId,
    this.elementoAsociadoTipo,
    this.tamanoBytes,
    super.metadata,
  }) : super(type: SessionElementType.foto);

  factory FotoEvidencia.fromJson(Map<String, dynamic> json) => FotoEvidencia(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    userId: json['userId'] as String,
    sessionId: json['sessionId'] as String,
    rutaLocal: json['rutaLocal'] as String,
    rutaRemota: json['rutaRemota'] as String?,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    descripcion: json['descripcion'] as String?,
    elementoAsociadoId: json['elementoAsociadoId'] as String?,
    elementoAsociadoTipo: json['elementoAsociadoTipo'] != null
        ? SessionElementType.values.byName(json['elementoAsociadoTipo'] as String)
        : null,
    tamanoBytes: json['tamanoBytes'] as int?,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'sessionId': sessionId,
    'rutaLocal': rutaLocal,
    'rutaRemota': rutaRemota,
    'latitude': latitude,
    'longitude': longitude,
    'descripcion': descripcion,
    'elementoAsociadoId': elementoAsociadoId,
    'elementoAsociadoTipo': elementoAsociadoTipo?.name,
    'tamanoBytes': tamanoBytes,
    'metadata': metadata,
  };
}

/// Resumen estadístico de una sesión
class SessionSummary extends Equatable {
  final String sessionId;
  final String userId;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final int totalPostes;
  final int totalTransformadores;
  final int totalArboles;
  final int totalPodas;
  final int totalClaros;
  final int totalFotos;
  final double distanciaTotalClaros;
  final Duration duracionSesion;
  final List<String> tecnicosParticipantes;

  const SessionSummary({
    required this.sessionId,
    required this.userId,
    required this.fechaInicio,
    this.fechaFin,
    this.totalPostes = 0,
    this.totalTransformadores = 0,
    this.totalArboles = 0,
    this.totalPodas = 0,
    this.totalClaros = 0,
    this.totalFotos = 0,
    this.distanciaTotalClaros = 0.0,
    this.duracionSesion = Duration.zero,
    this.tecnicosParticipantes = const [],
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) => SessionSummary(
    sessionId: json['sessionId'] as String,
    userId: json['userId'] as String,
    fechaInicio: DateTime.parse(json['fechaInicio'] as String),
    fechaFin: json['fechaFin'] != null
        ? DateTime.parse(json['fechaFin'] as String)
        : null,
    totalPostes: json['totalPostes'] as int? ?? 0,
    totalTransformadores: json['totalTransformadores'] as int? ?? 0,
    totalArboles: json['totalArboles'] as int? ?? 0,
    totalPodas: json['totalPodas'] as int? ?? 0,
    totalClaros: json['totalClaros'] as int? ?? 0,
    totalFotos: json['totalFotos'] as int? ?? 0,
    distanciaTotalClaros: (json['distanciaTotalClaros'] as num?)?.toDouble() ?? 0.0,
    duracionSesion: Duration(milliseconds: json['duracionSesionMs'] as int? ?? 0),
    tecnicosParticipantes: List<String>.from(json['tecnicosParticipantes'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'userId': userId,
    'fechaInicio': fechaInicio.toIso8601String(),
    'fechaFin': fechaFin?.toIso8601String(),
    'totalPostes': totalPostes,
    'totalTransformadores': totalTransformadores,
    'totalArboles': totalArboles,
    'totalPodas': totalPodas,
    'totalClaros': totalClaros,
    'totalFotos': totalFotos,
    'distanciaTotalClaros': distanciaTotalClaros,
    'duracionSesionMs': duracionSesion.inMilliseconds,
    'tecnicosParticipantes': tecnicosParticipantes,
  };

  SessionSummary copyWith({
    DateTime? fechaFin,
    int? totalPostes,
    int? totalTransformadores,
    int? totalArboles,
    int? totalPodas,
    int? totalClaros,
    int? totalFotos,
    double? distanciaTotalClaros,
    Duration? duracionSesion,
    List<String>? tecnicosParticipantes,
  }) => SessionSummary(
    sessionId: sessionId,
    userId: userId,
    fechaInicio: fechaInicio,
    fechaFin: fechaFin ?? this.fechaFin,
    totalPostes: totalPostes ?? this.totalPostes,
    totalTransformadores: totalTransformadores ?? this.totalTransformadores,
    totalArboles: totalArboles ?? this.totalArboles,
    totalPodas: totalPodas ?? this.totalPodas,
    totalClaros: totalClaros ?? this.totalClaros,
    totalFotos: totalFotos ?? this.totalFotos,
    distanciaTotalClaros: distanciaTotalClaros ?? this.distanciaTotalClaros,
    duracionSesion: duracionSesion ?? this.duracionSesion,
    tecnicosParticipantes: tecnicosParticipantes ?? this.tecnicosParticipantes,
  );

  @override
  List<Object?> get props => [
    sessionId,
    userId,
    fechaInicio,
    fechaFin,
    totalPostes,
    totalTransformadores,
    totalArboles,
    totalPodas,
    totalClaros,
    totalFotos,
    distanciaTotalClaros,
    duracionSesion,
    tecnicosParticipantes,
  ];
}