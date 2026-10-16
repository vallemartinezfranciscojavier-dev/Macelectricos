import 'package:equatable/equatable.dart';

/// Tipos de elementos de infraestructura eléctrica que se registran
/// y visualizan en el mapa.
enum MapElementType { pole, transformer, tree }

/// Nivel de riesgo de un elemento (principalmente para árboles).
enum RiskLevel { low, medium, high, critical }

/// Extensión con etiqueta legible para cada nivel de riesgo.
extension RiskLevelLabel on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Bajo';
      case RiskLevel.medium:
        return 'Medio';
      case RiskLevel.high:
        return 'Alto';
      case RiskLevel.critical:
        return 'Crítico';
    }
  }
}

/// Entidad base de un elemento de infraestructura visualizado en el mapa.
///
/// Un [MapElement] representa un poste, transformador o árbol con sus
/// coordenadas GPS y los datos específicos de su tipo. Es la fuente de
/// verdad para los marcadores del mapa y para los registros de campo
/// (Fase 5).
class MapElement extends Equatable {
  final String id;
  final MapElementType type;
  final String codigo; // Ej: "P-001", "T-012", "A-003"
  final String? descripcion;
  final double latitude;
  final double longitude;

  /// Precisión GPS en metros al momento del registro.
  final double? gpsPrecision;
  final DateTime fechaRegistro;

  /// userId del técnico que lo registró.
  final String? registradoPor;
  final bool sincronizado;

  // Específicos de poste
  final String? material; // concreto / madera / metalico
  final double? altura; // metros

  // Específicos de transformador
  final double? kva; // capacidad en KVA
  final String? fase; // "1F" / "3F"

  // Específicos de árbol
  final String? especie;
  final RiskLevel? riesgo;
  final double? distanciaRed; // metros a la red eléctrica

  const MapElement({
    required this.id,
    required this.type,
    required this.codigo,
    this.descripcion,
    required this.latitude,
    required this.longitude,
    this.gpsPrecision,
    required this.fechaRegistro,
    this.registradoPor,
    this.sincronizado = false,
    this.material,
    this.altura,
    this.kva,
    this.fase,
    this.especie,
    this.riesgo,
    this.distanciaRed,
  });

  /// Constructor conveniente para un poste eléctrico.
  factory MapElement.pole({
    required String id,
    required String codigo,
    required double latitude,
    required double longitude,
    double? gpsPrecision,
    required DateTime fechaRegistro,
    String? descripcion,
    String? registradoPor,
    bool sincronizado = false,
    String? material,
    double? altura,
  }) {
    return MapElement(
      id: id,
      type: MapElementType.pole,
      codigo: codigo,
      descripcion: descripcion,
      latitude: latitude,
      longitude: longitude,
      gpsPrecision: gpsPrecision,
      fechaRegistro: fechaRegistro,
      registradoPor: registradoPor,
      sincronizado: sincronizado,
      material: material,
      altura: altura,
    );
  }

  /// Constructor conveniente para un transformador.
  factory MapElement.transformer({
    required String id,
    required String codigo,
    required double latitude,
    required double longitude,
    double? gpsPrecision,
    required DateTime fechaRegistro,
    String? descripcion,
    String? registradoPor,
    bool sincronizado = false,
    double? kva,
    String? fase,
  }) {
    return MapElement(
      id: id,
      type: MapElementType.transformer,
      codigo: codigo,
      descripcion: descripcion,
      latitude: latitude,
      longitude: longitude,
      gpsPrecision: gpsPrecision,
      fechaRegistro: fechaRegistro,
      registradoPor: registradoPor,
      sincronizado: sincronizado,
      kva: kva,
      fase: fase,
    );
  }

  /// Constructor conveniente para un árbol.
  factory MapElement.tree({
    required String id,
    required String codigo,
    required double latitude,
    required double longitude,
    double? gpsPrecision,
    required DateTime fechaRegistro,
    String? descripcion,
    String? registradoPor,
    bool sincronizado = false,
    String? especie,
    RiskLevel? riesgo,
    double? distanciaRed,
  }) {
    return MapElement(
      id: id,
      type: MapElementType.tree,
      codigo: codigo,
      descripcion: descripcion,
      latitude: latitude,
      longitude: longitude,
      gpsPrecision: gpsPrecision,
      fechaRegistro: fechaRegistro,
      registradoPor: registradoPor,
      sincronizado: sincronizado,
      especie: especie,
      riesgo: riesgo,
      distanciaRed: distanciaRed,
    );
  }

  MapElement copyWith({
    String? id,
    MapElementType? type,
    String? codigo,
    String? descripcion,
    double? latitude,
    double? longitude,
    double? gpsPrecision,
    DateTime? fechaRegistro,
    String? registradoPor,
    bool? sincronizado,
    String? material,
    double? altura,
    double? kva,
    String? fase,
    String? especie,
    RiskLevel? riesgo,
    double? distanciaRed,
  }) {
    return MapElement(
      id: id ?? this.id,
      type: type ?? this.type,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsPrecision: gpsPrecision ?? this.gpsPrecision,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      registradoPor: registradoPor ?? this.registradoPor,
      sincronizado: sincronizado ?? this.sincronizado,
      material: material ?? this.material,
      altura: altura ?? this.altura,
      kva: kva ?? this.kva,
      fase: fase ?? this.fase,
      especie: especie ?? this.especie,
      riesgo: riesgo ?? this.riesgo,
      distanciaRed: distanciaRed ?? this.distanciaRed,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        codigo,
        descripcion,
        latitude,
        longitude,
        gpsPrecision,
        fechaRegistro,
        registradoPor,
        sincronizado,
        material,
        altura,
        kva,
        fase,
        especie,
        riesgo,
        distanciaRed,
      ];
}