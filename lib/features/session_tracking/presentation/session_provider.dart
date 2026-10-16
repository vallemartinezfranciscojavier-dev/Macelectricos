import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macelectricos/core/models/session_models.dart';
import 'package:macelectricos/features/session_tracking/data/local_storage.dart';
import 'package:macelectricos/features/session_tracking/data/remote_sync.dart';
import 'package:macelectricos/features/session_tracking/data/session_service.dart';
import 'package:macelectricos/features/session_tracking/domain/session_repository.dart';

/// Providers de dependencias
final sessionLocalStorageProvider = Provider<SessionLocalStorage>((ref) {
  return SessionLocalStorageImpl();
});

final sessionRemoteSyncProvider = Provider<SessionRemoteSync>((ref) {
  return SessionRemoteSyncImpl();
});

final graphGeneratorProvider = Provider<GraphGenerator>((ref) {
  final storage = ref.watch(sessionLocalStorageProvider);
  return GraphGenerator(storage);
});

final sessionServiceProvider = Provider<SessionRepository>((ref) {
  return SessionService(
    localStorage: ref.watch(sessionLocalStorageProvider),
    remoteSync: ref.watch(sessionRemoteSyncProvider),
    graphGenerator: ref.watch(graphGeneratorProvider),
  );
});

/// Estado de la sesión actual
class SessionState {
  final Session? sesionActiva;
  final SessionSummary? resumen;
  final SessionGraph? grafo;
  final List<SessionElement> elementos;
  final SessionContadores contadores;
  final bool cargando;
  final String? error;
  final double progresoSincronizacion;

  const SessionState({
    this.sesionActiva,
    this.resumen,
    this.grafo,
    this.elementos = const [],
    this.contadores = const SessionContadores(),
    this.cargando = false,
    this.error,
    this.progresoSincronizacion = 0.0,
  });

  SessionState copyWith({
    Session? sesionActiva,
    SessionSummary? resumen,
    SessionGraph? grafo,
    List<SessionElement>? elementos,
    SessionContadores? contadores,
    bool? cargando,
    String? error,
    double? progresoSincronizacion,
  }) => SessionState(
    sesionActiva: sesionActiva ?? this.sesionActiva,
    resumen: resumen ?? this.resumen,
    grafo: grafo ?? this.grafo,
    elementos: elementos ?? this.elementos,
    contadores: contadores ?? this.contadores,
    cargando: cargando ?? this.cargando,
    error: error,
    progresoSincronizacion: progresoSincronizacion ?? this.progresoSincronizacion,
  );

  bool get haySesionActiva => sesionActiva != null && sesionActiva!.estado == SessionEstado.activa;
}

/// Notifier para manejo de sesión
class SessionNotifier extends StateNotifier<SessionState> {
  final SessionRepository _repository;
  StreamSubscription? _contadoresSubscription;

  SessionNotifier(this._repository) : super(const SessionState());

  /// Iniciar nueva sesión
  Future<void> iniciarSesion({
    required String userId,
    required String cuadrillaId,
  }) async {
    state = state.copyWith(cargando: true, error: null);

    final result = await _repository.iniciarSesion(userId: userId, cuadrillaId: cuadrillaId);

    result.fold(
      (failure) => state = state.copyWith(cargando: false, error: failure.mensaje),
      (sesion) {
        state = state.copyWith(
          cargando: false,
          sesionActiva: sesion,
          contadores: sesion.contadores,
          elementos: [],
        );
        _iniciarEscuchaContadores(sesion.id);
      },
    );
  }

  /// Finalizar sesión y generar grafo
  Future<SessionSummary?> finalizarSesion() async {
    final sesion = state.sesionActiva;
    if (sesion == null) return null;

    state = state.copyWith(cargando: true, error: null);

    final result = await _repository.finalizarSesion(sessionId: sesion.id);

    return result.fold(
      (failure) {
        state = state.copyWith(cargando: false, error: failure.mensaje);
        return null;
      },
      (resumen) async {
        final grafoResult = await _repository.generarGrafoRecorrido(sesion.id);
        final grafo = grafoResult.fold(
          (l) => null,
          (r) => r,
        );

        state = state.copyWith(
          cargando: false,
          sesionActiva: sesion.copyWith(estado: SessionEstado.finalizada, fechaFin: DateTime.now()),
          resumen: resumen,
          grafo: grafo,
          contadores: sesion.contadores,
        );
        _detenerEscuchaContadores();
        return resumen;
      },
    );
  }

  /// Cargar sesión activa existente
  Future<void> cargarSesionActiva(String userId) async {
    state = state.copyWith(cargando: true, error: null);

    final result = await _repository.obtenerSesionActiva(userId);

    result.fold(
      (failure) => state = state.copyWith(cargando: false, error: failure.mensaje),
      (sesion) async {
        if (sesion != null) {
          final elementosResult = await _repository.obtenerElementosSesion(sesion.id);
          final elementos = elementosResult.fold((l) => <SessionElement>[], (r) => r);

          final resumenResult = await _repository.obtenerResumenSesion(sesion.id);
          final resumen = resumenResult.fold((l) => null, (r) => r);

          final grafoResult = await _repository.generarGrafoRecorrido(sesion.id);
          final grafo = grafoResult.fold((l) => null, (r) => r);

          state = state.copyWith(
            cargando: false,
            sesionActiva: sesion,
            elementos: elementos,
            contadores: sesion.contadores,
            resumen: resumen,
            grafo: grafo,
          );
          _iniciarEscuchaContadores(sesion.id);
        } else {
          state = state.copyWith(cargando: false);
        }
      },
    );
  }

  /// Registrar elemento en la sesión
  Future<void> registrarElemento(SessionElement elemento) async {
    if (!state.haySesionActiva) {
      state = state.copyWith(error: 'No hay sesión activa');
      return;
    }

    final result = await _repository.guardarElemento(elemento);

    result.fold(
      (failure) => state = state.copyWith(error: failure.mensaje),
      (_) {
        final nuevosElementos = [...state.elementos, elemento];
        state = state.copyWith(
          elementos: nuevosElementos,
          error: null,
        );
      },
    );
  }

  /// Actualizar contadores manualmente
  Future<void> refrescarContadores() async {
    final sesion = state.sesionActiva;
    if (sesion == null) return;

    final result = await _repository.actualizarContadores(sesion.id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.mensaje),
      (_) async {
        final sesionActualizada = await _repository.obtenerSesionActiva(sesion.userId);
        sesionActualizada.fold(
          (l) => null,
          (r) {
            if (r != null) {
              state = state.copyWith(contadores: r.contadores);
            }
          },
        );
      },
    );
  }

  /// Exportar sesión
  Future<String?> exportarSesion(ExportFormat formato) async {
    final sesion = state.sesionActiva;
    if (sesion == null) return null;

    state = state.copyWith(cargando: true, error: null);

    final result = await _repository.exportarSesion(sesion.id, formato);

    return result.fold(
      (failure) {
        state = state.copyWith(cargando: false, error: failure.mensaje);
        return null;
      },
      (ruta) {
        state = state.copyWith(cargando: false, error: null);
        return ruta;
      },
    );
  }

  /// Sincronizar sesión
  Future<void> sincronizarSesion() async {
    final sesion = state.sesionActiva;
    if (sesion == null) return;

    state = state.copyWith(cargando: true, progresoSincronizacion: 0.0, error: null);

    final result = await _repository.sincronizarSesion(sesion.id);

    result.fold(
      (failure) => state = state.copyWith(cargando: false, error: failure.mensaje, progresoSincronizacion: 0.0),
      (_) {
        state = state.copyWith(
          cargando: false,
          progresoSincronizacion: 1.0,
          sesionActiva: sesion.copyWith(sincronizada: true),
        );
      },
    );
  }

  /// Obtener elementos por tipo
  Future<List<SessionElement>> obtenerElementosPorTipo(SessionElementType tipo) async {
    final sesion = state.sesionActiva;
    if (sesion == null) return [];

    final result = await _repository.obtenerElementosPorTipo(sesion.id, tipo);
    return result.fold((l) => [], (r) => r);
  }

  void _iniciarEscuchaContadores(String sessionId) {
    _detenerEscuchaContadores();
    // En implementación real, escuchar cambios en tiempo real
    // _contadoresSubscription = _repository.watchContadores(sessionId).listen(...);
  }

  void _detenerEscuchaContadores() {
    _contadoresSubscription?.cancel();
    _contadoresSubscription = null;
  }

  @override
  void dispose() {
    _detenerEscuchaContadores();
    super.dispose();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref.watch(sessionServiceProvider));
});

/// Provider para contadores en tiempo real (para UI)
final contadoresStreamProvider = StreamProvider<SessionContadores>((ref) {
  // TODO: Implementar stream real desde repositorio
  return Stream.value(const SessionContadores());
});