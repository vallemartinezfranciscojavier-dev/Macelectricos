/// Tokens de espaciado y radio para la interfaz industrial de MaCElectricos.
///
/// Centraliza las medidas para mantener consistencia entre features.
/// Uso: `padding: EdgeInsets.all(AppSpacing.lg)`
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Radios de redondeo consistentes con el tema.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

/// Alturas mínimas táctiles para trabajo de campo (guantes, luz solar).
class AppTouchTarget {
  AppTouchTarget._();

  static const double min = 48;
  static const double large = 56;
}