import 'package:dartz/dartz.dart';

import '../entities/user.dart';
import '../failures/failures.dart';

/// Contrato del repositorio de autenticación
abstract class AuthRepository {
  /// Iniciar sesión con email y contraseña
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registrar nuevo usuario (solo admin)
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    required UserRole role,
    String? equipoId,
  });

  /// Cerrar sesión
  Future<Either<Failure, void>> signOut();

  /// Obtener usuario actual (desde cache local o Firebase)
  Future<Either<Failure, User?>> getCurrentUser();

  /// Escuchar cambios de autenticación (stream)
  Stream<User?> authStateChanges();

  /// Actualizar perfil de usuario
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? nombre,
    String? telefono,
    String? fotoUrl,
  });

  /// Cambiar contraseña
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Recuperar contraseña
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Verificar si email existe
  Future<Either<Failure, bool>> checkEmailExists(String email);

  /// Obtener usuarios por rol (para admin)
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role);

  /// Obtener usuarios por equipo
  Future<Either<Failure, List<User>>> getUsersByEquipo(String equipoId);
}