import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../../auth/domain/failures/failures.dart';
import '../../domain/entities/map_element.dart';
import '../../domain/repositories/map_element_repository.dart';

/// Repositorio mock de elementos del mapa para la demo (sin backend).
///
/// Los elementos de ejemplo se ubican en la zona de la Ciudad de México
/// para que coincidan con la cámara inicial del mapa.
///
/// TODO(Fase 5+): reemplazar por una implementación sobre Isar/Firestore.
class MockMapElementRepository implements MapElementRepository {
  MockMapElementRepository() : _elements = _buildSeedElements();

  final List<MapElement> _elements;

  static List<MapElement> _buildSeedElements() {
    final ahora = DateTime.now();
    return [
      // ---- Postes ----
      MapElement.pole(
        id: 'pole-001',
        codigo: 'P-001',
        latitude: 19.4326,
        longitude: -99.1332,
        gpsPrecision: 6.2,
        fechaRegistro: ahora.subtract(const Duration(days: 2, hours: 3)),
        descripcion: 'Poste de concreto en esquina de Av. Reforma',
        registradoPor: 'tecnico-1',
        material: 'Concreto',
        altura: 12,
      ),
      MapElement.pole(
        id: 'pole-002',
        codigo: 'P-002',
        latitude: 19.4350,
        longitude: -99.1310,
        gpsPrecision: 8.4,
        fechaRegistro: ahora.subtract(const Duration(days: 2, hours: 1)),
        descripcion: 'Poste de madera junto a camellón',
        registradoPor: 'tecnico-1',
        material: 'Madera',
        altura: 10,
      ),
      MapElement.pole(
        id: 'pole-003',
        codigo: 'P-003',
        latitude: 19.4340,
        longitude: -99.1365,
        gpsPrecision: 12.0,
        fechaRegistro: ahora.subtract(const Duration(days: 1, hours: 5)),
        descripcion: 'Poste metálico de media tensión',
        registradoPor: 'tecnico-2',
        material: 'Metálico',
        altura: 14,
      ),
      MapElement.pole(
        id: 'pole-004',
        codigo: 'P-004',
        latitude: 19.4308,
        longitude: -99.1298,
        gpsPrecision: 5.8,
        fechaRegistro: ahora.subtract(const Duration(days: 1, hours: 2)),
        descripcion: 'Poste de concreto con retenida',
        registradoPor: 'tecnico-1',
        material: 'Concreto',
        altura: 13,
      ),
      MapElement.pole(
        id: 'pole-005',
        codigo: 'P-005',
        latitude: 19.4369,
        longitude: -99.1349,
        gpsPrecision: 15.5,
        fechaRegistro: ahora.subtract(const Duration(hours: 8)),
        descripcion: 'Poste de madera en crucero',
        registradoPor: 'tecnico-3',
        material: 'Madera',
        altura: 11,
      ),
      // ---- Transformadores ----
      MapElement.transformer(
        id: 'transformer-001',
        codigo: 'T-001',
        latitude: 19.4333,
        longitude: -99.1324,
        gpsPrecision: 4.9,
        fechaRegistro: ahora.subtract(const Duration(days: 5, hours: 2)),
        descripcion: 'Transformador tipo poste 3 fases',
        registradoPor: 'tecnico-1',
        kva: 25,
        fase: '3F',
      ),
      MapElement.transformer(
        id: 'transformer-002',
        codigo: 'T-002',
        latitude: 19.4346,
        longitude: -99.1348,
        gpsPrecision: 7.3,
        fechaRegistro: ahora.subtract(const Duration(days: 4)),
        descripcion: 'Transformador montado en P-003',
        registradoPor: 'tecnico-2',
        kva: 50,
        fase: '3F',
      ),
      MapElement.transformer(
        id: 'transformer-003',
        codigo: 'T-003',
        latitude: 19.4315,
        longitude: -99.1300,
        gpsPrecision: 9.1,
        fechaRegistro: ahora.subtract(const Duration(days: 3, hours: 6)),
        descripcion: 'Transformador monofásico residencial',
        registradoPor: 'tecnico-1',
        kva: 15,
        fase: '1F',
      ),
      MapElement.transformer(
        id: 'transformer-004',
        codigo: 'T-004',
        latitude: 19.4362,
        longitude: -99.1318,
        gpsPrecision: 18.0,
        fechaRegistro: ahora.subtract(const Duration(days: 2, hours: 5)),
        descripcion: 'Transformador sobre plataforma',
        registradoPor: 'tecnico-3',
        kva: 75,
        fase: '3F',
      ),
      // ---- Árboles ----
      MapElement.tree(
        id: 'tree-001',
        codigo: 'A-001',
        latitude: 19.4328,
        longitude: -99.1351,
        gpsPrecision: 6.7,
        fechaRegistro: ahora.subtract(const Duration(days: 6)),
        descripcion: 'Eucalipto cerca de línea de media tensión',
        registradoPor: 'tecnico-2',
        especie: 'Eucalipto',
        riesgo: RiskLevel.high,
        distanciaRed: 4.5,
      ),
      MapElement.tree(
        id: 'tree-002',
        codigo: 'A-002',
        latitude: 19.4343,
        longitude: -99.1295,
        gpsPrecision: 8.8,
        fechaRegistro: ahora.subtract(const Duration(days: 5, hours: 4)),
        descripcion: 'Fresno sin riesgo a la red',
        registradoPor: 'tecnico-1',
        especie: 'Fresno',
        riesgo: RiskLevel.low,
        distanciaRed: 12.0,
      ),
      MapElement.tree(
        id: 'tree-003',
        codigo: 'A-003',
        latitude: 19.4312,
        longitude: -99.1338,
        gpsPrecision: 22.0,
        fechaRegistro: ahora.subtract(const Duration(days: 3, hours: 2)),
        descripcion: 'Álamo con ramas sobre conductores',
        registradoPor: 'tecnico-3',
        especie: 'Álamo',
        riesgo: RiskLevel.critical,
        distanciaRed: 2.0,
      ),
      MapElement.tree(
        id: 'tree-004',
        codigo: 'A-004',
        latitude: 19.4371,
        longitude: -99.1356,
        gpsPrecision: 10.5,
        fechaRegistro: ahora.subtract(const Duration(days: 1, hours: 7)),
        descripcion: 'Jacaranda en banquet',
        registradoPor: 'tecnico-2',
        especie: 'Jacaranda',
        riesgo: RiskLevel.medium,
        distanciaRed: 8.0,
      ),
    ];
  }

  @override
  Future<Either<Failure, List<MapElement>>> getAllElements() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(List.unmodifiable(_elements));
  }

  @override
  Future<Either<Failure, List<MapElement>>> getElementsNear({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final near = _elements
        .where((e) => _haversineKm(latitude, longitude, e.latitude, e.longitude) <= radiusKm)
        .toList();
    return Right(List.unmodifiable(near));
  }

  @override
  Future<Either<Failure, MapElement>> getElementById(String id) async {
    for (final element in _elements) {
      if (element.id == id) return Right(element);
    }
    return Left(
      LocalDatabaseFailure.notFound('Elemento del mapa ($id)'),
    );
  }

  @override
  Future<Either<Failure, MapElement>> saveElement(MapElement element) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _elements.add(element);
    return Right(element);
  }

  /// Distancia (km) entre dos coordenadas usando la fórmula de Haversine.
  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Radio terrestre en km
    final dLat = _radians(lat2 - lat1);
    final dLon = _radians(lon2 - lon1);
    final a = pow(sin(dLat / 2), 2) +
        cos(_radians(lat1)) * cos(_radians(lat2)) * pow(sin(dLon / 2), 2);
    return 2 * r * asin(sqrt(a));
  }

  static double _radians(double degrees) => degrees * pi / 180.0;
}