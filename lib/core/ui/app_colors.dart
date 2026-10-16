import 'package:flutter/material.dart';

/// Colores semánticos de la interfaz industrial de MaCElectricos.
///
/// Complementan el `ColorScheme` del tema con los colores de estado
/// (éxito, advertencia, peligro, información) y sus fondos suaves,
/// usados por badges, banners y elementos de estado.
class AppColors {
  AppColors._();

  // Estados semánticos (alineados con la paleta de app_theme.dart)
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color danger = Color(0xFFD32F2F);
  static const Color info = Color(0xFF0277BD);

  // Fondos suaves para usarse junto a los colores de estado
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color dangerContainer = Color(0xFFFFEBEE);
  static const Color infoContainer = Color(0xFFE1F5FE);

  // Tipos de infraestructura (se mantiene consistente entre features)
  static const Color poste = Color(0xFF1565C0);
  static const Color transformador = Color(0xFFEF6C00);
  static const Color arbol = Color(0xFF2E7D32);
  static const Color poda = Color(0xFFC62828);
  static const Color claro = Color(0xFF00897B);
  static const Color foto = Color(0xFF3949AB);
}