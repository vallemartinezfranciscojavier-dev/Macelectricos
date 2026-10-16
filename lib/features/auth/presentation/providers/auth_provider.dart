import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/failures.dart';

/// Notifier del estado de autenticación
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier({
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(const AuthState()) {
    _checkInitialAuth();
  }

  /// Verificar autenticación al inicio
  Future<void> _checkInitialAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: failure.message,
      ),
      (user) {
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  /// Iniciar sesión
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _signInUseCase(email: email, password: password);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ),
    );
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signOutUseCase();
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = const AuthState(status: AuthStatus.unauthenticated),
    );
  }

  /// Refrescar usuario actual
  Future<void> refreshUser() async {
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) {
        // Si falla, mantener usuario actual pero mostrar error si no hay usuario
        if (state.user == null) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: failure.message,
          );
        }
      },
      (user) {
        if (user != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      },
    );
  }

  /// Actualizar perfil
  Future<void> updateProfile({
    String? nombre,
    String? telefono,
    String? fotoUrl,
  }) async {
    // TODO: Implementar con UpdateProfileUseCase
    // Por ahora actualizar localmente
    if (state.user != null) {
      final updatedUser = state.user!.copyWith(
        nombre: nombre ?? state.user!.nombre,
        telefono: telefono ?? state.user!.telefono,
        fotoUrl: fotoUrl ?? state.user!.fotoUrl,
        fechaActualizacion: DateTime.now(),
      );
      state = state.copyWith(user: updatedUser);
    }
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}