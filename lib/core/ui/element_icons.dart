import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tipos de elementos de infraestructura eléctrica disponibles en la app.
enum ElementType {
  poste,
  transformador,
  arbol,
  poda,
  claro,
  foto,
}

/// Información visual asociada a cada tipo de elemento.
class ElementVisual {
  final IconData icon;
  final Color color;
  final String label;

  const ElementVisual({
    required this.icon,
    required this.color,
    required this.label,
  });
}

/// Mapa centralizado de tipo de elemento → icono + color.
///
/// Normaliza la apariencia visual entre todas las features para que
/// un poste siempre se muestre con el mismo icono y color sin importar
/// si está en el mapa, el historial o el dashboard del supervisor.
///
/// ```dart
/// final visual = ElementIcons.of(ElementType.poste);
/// Icon(visual.icon, color: visual.color);
/// ```
class ElementIcons {
  ElementIcons._();

  static const Map<ElementType, ElementVisual> _map = {
    ElementType.poste: ElementVisual(
      icon: Icons.electric_bolt,
      color: AppColors.poste,
      label: 'Poste',
    ),
    ElementType.transformador: ElementVisual(
      icon: Icons.transform,
      color: AppColors.transformador,
      label: 'Transformador',
    ),
    ElementType.arbol: ElementVisual(
      icon: Icons.park,
      color: AppColors.arbol,
      label: 'Arbol',
    ),
    ElementType.poda: ElementVisual(
      icon: Icons.content_cut,
      color: AppColors.poda,
      label: 'Poda',
    ),
    ElementType.claro: ElementVisual(
      icon: Icons.forest,
      color: AppColors.claro,
      label: 'Claro de linea',
    ),
    ElementType.foto: ElementVisual(
      icon: Icons.photo_camera,
      color: AppColors.foto,
      label: 'Foto',
    ),
  };

  /// Retorna la información visual para un tipo de elemento.
  static ElementVisual of(ElementType type) {
    return _map[type]!;
  }

  /// Retorna el icono para un tipo de elemento.
  static IconData iconOf(ElementType type) => _map[type]!.icon;

  /// Retorna el color para un tipo de elemento.
  static Color colorOf(ElementType type) => _map[type]!.color;

  /// Retorna la etiqueta para un tipo de elemento.
  static String labelOf(ElementType type) => _map[type]!.label;
}
