import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../auth/domain/failures/failures.dart';
import '../../domain/entities/map_element.dart';
import '../../domain/repositories/map_element_repository.dart';

class MapElementRepositoryImpl implements MapElementRepository {
  final FirebaseFirestore _firestore;

  MapElementRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Future<Either<Failure, List<MapElement>>> getAllElements() async {
    try {
      final snapshot = await _firestore.collection('elementos_mapa').get();
      final elements = snapshot.docs.map((doc) => _mapElementFromFirestore(doc)).toList();
      return Right(elements);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<MapElement>>> getElementsNear({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    // TODO: Implementar búsqueda geoespacial real con GeoFirestore o consultas de rango.
    // Por ahora, traemos todos y filtramos en cliente (no eficiente para muchos datos)
    return await getAllElements().then((result) => result.fold(
          (failure) => Left(failure),
          (elements) => Right(elements
              .where((e) => _haversineKm(latitude, longitude, e.latitude, e.longitude) <= radiusKm)
              .toList()),
        ));
  }

  @override
  Future<Either<Failure, MapElement>> getElementById(String id) async {
    try {
      final doc = await _firestore.collection('elementos_mapa').doc(id).get();
      if (!doc.exists) {
        return Left(LocalDatabaseFailure.notFound('Elemento del mapa ($id)'));
      }
      return Right(_mapElementFromFirestore(doc));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, MapElement>> saveElement(MapElement element) async {
    try {
      final docRef = _firestore.collection('elementos_mapa').doc(element.id);
      await docRef.set(_mapElementToFirestore(element));
      return Right(element);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  // --- Helpers ---
  Map<String, dynamic> _mapElementToFirestore(MapElement element) {
    return {
      'id': element.id,
      'type': element.type.name,
      'codigo': element.codigo,
      'descripcion': element.descripcion,
      'latitude': element.latitude,
      'longitude': element.longitude,
      'gpsPrecision': element.gpsPrecision,
      'fechaRegistro': Timestamp.fromDate(element.fechaRegistro),
      'registradoPor': element.registradoPor,
      'sincronizado': element.sincronizado,
      'material': element.material,
      'altura': element.altura,
      'kva': element.kva,
      'fase': element.fase,
      'especie': element.especie,
      'riesgo': element.riesgo?.name,
      'distanciaRed': element.distanciaRed,
    };
  }

  MapElement _mapElementFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MapElement(
      id: data['id'] ?? doc.id,
      type: MapElementType.values.byName(data['type']),
      codigo: data['codigo'],
      descripcion: data['descripcion'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      gpsPrecision: data['gpsPrecision'],
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
      registradoPor: data['registradoPor'],
      sincronizado: data['sincronizado'] ?? false,
      material: data['material'],
      altura: data['altura'],
      kva: data['kva'],
      fase: data['fase'],
      especie: data['especie'],
      riesgo: data['riesgo'] != null ? RiskLevel.values.byName(data['riesgo']) : null,
      distanciaRed: data['distanciaRed'],
    );
  }

  static double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180.0;
    final dLon = (lon2 - lon1) * 3.141592653589793 / 180.0;
    final a = pow(sin(dLat / 2), 2) +
        cos(lat1 * 3.141592653589793 / 180.0) * cos(lat2 * 3.141592653589793 / 180.0) * pow(sin(dLon / 2), 2);
    return 2 * r * asin(sqrt(a));
  }
}
