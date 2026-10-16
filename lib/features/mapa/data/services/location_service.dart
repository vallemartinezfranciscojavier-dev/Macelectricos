import 'package:geolocator/geolocator.dart';

import '../../domain/entities/gps_location.dart';

/// Servicio de ubicación GPS del dispositivo.
///
/// Encapsula todo el uso de `geolocator`: solicitud de permisos, obtención
/// de la posición actual, stream de posiciones en tiempo real y apertura de
/// ajustes del sistema cuando el permiso está denegado permanentemente.
///
/// Todas las respuestas se traducen al value object [GpsLocation] del
/// dominio para que la capa de presentación no dependa de `geolocator`.
class LocationService {
  /// Verifica y solicita permiso de ubicación (mientras la app esté en uso).
  ///
  /// Retorna `true` si el permiso quedó concedido.
  Future<bool> checkAndRequestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Indica si el permiso está denegado permanentemente
  /// (el usuario marcó "no volver a preguntar").
  Future<bool> isPermissionDeniedForever() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.deniedForever;
  }

  /// Obtiene la posición actual con alta precisión.
  ///
  /// Retorna `null` si el permiso fue denegado o si no se pudo fijar la
  /// posición en el tiempo límite.
  Future<GpsLocation?> getCurrentPosition() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
    return _toGpsLocation(position);
  }

  /// Stream continuo de posiciones. Emite un [GpsLocation] cada vez que el
  /// dispositivo se mueve más de [distanceFilter] metros (o cuando mejora
  /// la precisión), lo que mantiene la tarjeta de GPS actualizada.
  Stream<GpsLocation> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map(_toGpsLocation);
  }

  /// Abre los ajustes del sistema para habilitar el permiso de ubicación
  /// (se usa cuando el permiso quedó denegado permanentemente).
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  GpsLocation _toGpsLocation(Position position) {
    return GpsLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }
}