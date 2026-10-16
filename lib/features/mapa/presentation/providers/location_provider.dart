import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gps_location.dart';
import '../../data/services/location_service.dart';

/// Estado del servicio de ubicación GPS.
enum LocationStatus { idle, loading, ready, denied, deniedForever, error }

/// Estado inmutable de la ubicación actual del dispositivo.
class LocationState extends Equatable {
  final LocationStatus status;
  final GpsLocation? currentLocation;
  final String? error;

  const LocationState({
    this.status = LocationStatus.idle,
    this.currentLocation,
    this.error,
  });

  /// Nivel de precisión de la posición actual (o `null` si aún no hay).
  GpsPrecisionLevel? get precisionLevel => currentLocation?.precisionLevel;

  bool get isReady => status == LocationStatus.ready;

  LocationState copyWith({
    LocationStatus? status,
    GpsLocation? currentLocation,
    String? error,
  }) {
    return LocationState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, currentLocation, error];
}

/// Notifier que gestiona permisos, posición actual y stream en tiempo real.
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier(this._service) : super(const LocationState());

  final LocationService _service;
  StreamSubscription<GpsLocation>? _positionSubscription;

  /// Solicita permiso de ubicación y obtiene la posición inicial.
  ///
  /// Si el permiso fue concedido, inicia el stream para refrescar la
  /// posición y precisión en tiempo real.
  Future<void> initializeAndRequest() async {
    state = LocationState(
      status: LocationStatus.loading,
      currentLocation: state.currentLocation,
    );

    final granted = await _service.checkAndRequestPermission();
    if (!granted) {
      final deniedForever = await _service.isPermissionDeniedForever();
      state = LocationState(
        status: deniedForever ? LocationStatus.deniedForever : LocationStatus.denied,
        currentLocation: state.currentLocation,
      );
      return;
    }

    try {
      final location = await _service.getCurrentPosition();
      if (location == null) {
        state = LocationState(
          status: LocationStatus.error,
          currentLocation: state.currentLocation,
          error: 'No se pudo obtener la posición GPS.',
        );
        return;
      }
      state = LocationState(status: LocationStatus.ready, currentLocation: location);
      _startPositionStream();
    } catch (e) {
      state = LocationState(
        status: LocationStatus.error,
        currentLocation: state.currentLocation,
        error: e.toString(),
      );
    }
  }

  /// Reintenta la solicitud de permiso (tras denegación).
  Future<void> retryPermission() => initializeAndRequest();

  /// Abre los ajustes del sistema (permiso denegado permanentemente).
  Future<void> openSettings() => _service.openAppSettings();

  void _startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = _service.getPositionStream().listen(
          (location) {
            if (!mounted) return;
            state = LocationState(
              status: LocationStatus.ready,
              currentLocation: location,
            );
          },
          onError: (Object e) {
            if (!mounted) return;
            state = state.copyWith(error: e.toString());
          },
        );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}