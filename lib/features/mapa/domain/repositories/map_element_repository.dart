import 'package:dartz/dartz.dart';

import '../entities/map_element.dart';
import '../../../auth/domain/failures/failures.dart';

/// Contrato del repositorio de elementos del mapa.
///
/// Expone las operaciones de consulta y guardado de elementos de
/// infraestructura (postes, transformadores, árboles). Las pantallas y los
/// providers dependen solo de esta interfaz, por lo que es la frontera de
/// aislamiento: hoy la implementa un mock, mañana Firestore/Isar sin
/// cambios en la UI.
abstract interface class MapElementRepository {
  /// Retorna todos los elementos disponibles (para la demo; en producción
  /// esta consulta se paginaría o filtraría por bounding box).
  Future<Either<Failure, List<MapElement>>> getAllElements();

  /// Retorna los elementos que se encuentran dentro del radio indicado.
  Future<Either<Failure, List<MapElement>>> getElementsNear({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  });

  /// Retorna un elemento por su [id].
  Future<Either<Failure, MapElement>> getElementById(String id);

  /// Guarda un nuevo elemento (mock: solo lo agrega en memoria).
  Future<Either<Failure, MapElement>> saveElement(MapElement element);
}