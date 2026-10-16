import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/map_element.dart';
import '../../domain/repositories/map_element_repository.dart';

/// Estado de los elementos del mapa (postes, transformadores, árboles).
class MapElementsState extends Equatable {
  final List<MapElement> elements;
  final Set<MapElementType> visibleTypes;
  final bool isLoading;
  final String? error;

  const MapElementsState({
    this.elements = const [],
    this.visibleTypes = const {
      MapElementType.pole,
      MapElementType.transformer,
      MapElementType.tree,
    },
    this.isLoading = false,
    this.error,
  });

  /// Elementos visibles de acuerdo a las capas activas del mapa.
  List<MapElement> get filteredElements =>
      elements.where((e) => visibleTypes.contains(e.type)).toList();

  MapElementsState copyWith({
    List<MapElement>? elements,
    Set<MapElementType>? visibleTypes,
    bool? isLoading,
    String? error,
  }) {
    return MapElementsState(
      elements: elements ?? this.elements,
      visibleTypes: visibleTypes ?? this.visibleTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [elements, visibleTypes, isLoading, error];
}

/// Notifier que carga los elementos y controla la visibilidad por capas.
class MapElementsNotifier extends StateNotifier<MapElementsState> {
  MapElementsNotifier(this._repository) : super(const MapElementsState());

  final MapElementRepository _repository;

  /// Carga los elementos desde el repositorio.
  Future<void> loadElements() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getAllElements();
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (elements) => state = state.copyWith(isLoading: false, elements: elements),
    );
  }

  /// Activa o desactiva la capa de un tipo de elemento.
  void toggleLayer(MapElementType type, bool enabled) {
    final updated = Set<MapElementType>.from(state.visibleTypes);
    if (enabled) {
      updated.add(type);
    } else {
      updated.remove(type);
    }
    state = state.copyWith(visibleTypes: updated);
  }
}