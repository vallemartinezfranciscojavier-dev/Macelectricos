import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/ui/app_colors.dart';

/// Nivel de precisión GPS según la tolerancia en metros (Fase 5).
enum GpsPrecisionLevel { excellent, acceptable, poor }

/// Extensión con metadatos visuales de cada nivel de precisión.
extension GpsPrecisionLevelVisual on GpsPrecisionLevel {
  /// Etiqueta legible en español.
  String get label {
    switch (this) {
      case GpsPrecisionLevel.excellent:
        return 'Excelente';
      case GpsPrecisionLevel.acceptable:
        return 'Aceptable';
      case GpsPrecisionLevel.poor:
        return 'Pobre';
    }
  }

  /// Color de estado asociado al nivel.
  Color get color {
    switch (this) {
      case GpsPrecisionLevel.excellent:
        return AppColors.success;
      case GpsPrecisionLevel.acceptable:
        return AppColors.warning;
      case GpsPrecisionLevel.poor:
        return AppColors.danger;
    }
  }

  /// Color de fondo suave asociado al nivel.
  Color get containerColor {
    switch (this) {
      case GpsPrecisionLevel.excellent:
        return AppColors.successContainer;
      case GpsPrecisionLevel.acceptable:
        return AppColors.warningContainer;
      case GpsPrecisionLevel.poor:
        return AppColors.dangerContainer;
    }
  }
}

/// Value object con los datos de una ubicación GPS obtenida del dispositivo.
///
/// Encapsula latitud, longitud y precisión (en metros). La validación de
/// precisión sigue los umbrales de la Fase 5: excelente <= 10 m,
/// aceptable <= 20 m y pobre > 20 m (no permite guardar).
class GpsLocation extends Equatable {
  final double latitude;
  final double longitude;

  /// Precisión en metros (desviación estándar reportada por el GPS).
  final double? accuracy;
  final double? altitude; // metros sobre el nivel del mar
  final double? speed; // m/s
  final DateTime timestamp;

  const GpsLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
  });

  /// Umbrales de precisión según la especificación de la Fase 5.
  static const double excellentThreshold = 10.0; // <= 10 m
  static const double acceptableThreshold = 20.0; // <= 20 m

  /// Precisión excelente: permite guardar sin advertencias.
  bool get isAccurate => accuracy != null && accuracy! <= excellentThreshold;

  /// Precisión aceptable: permite guardar mostrando una advertencia.
  bool get isAcceptable => accuracy != null && accuracy! <= acceptableThreshold;

  /// Nivel de precisión derivado del valor en metros.
  GpsPrecisionLevel get precisionLevel {
    final acc = accuracy;
    if (acc == null) return GpsPrecisionLevel.poor;
    if (acc <= excellentThreshold) return GpsPrecisionLevel.excellent;
    if (acc <= acceptableThreshold) return GpsPrecisionLevel.acceptable;
    return GpsPrecisionLevel.poor;
  }

  /// Texto legible de la precisión (ej: "8.5 m") o "—" si no hay dato.
  String get accuracyText => accuracy == null ? '—' : '${accuracy!.toStringAsFixed(1)} m';

  @override
  List<Object?> get props => [latitude, longitude, accuracy, altitude, speed, timestamp];
}