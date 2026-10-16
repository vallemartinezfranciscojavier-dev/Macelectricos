import 'dart:async';
import 'package:dartz/dartz.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/failures.dart';

/// Repositorio de autenticación mock para pruebas sin Firebase.
/// Credenciales: admin@macelectricos.com / admin123
class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  final _authStateController = StreamController<User?>.broadcast();

  // Usuarios mock predefinidos
  static const _mockUsers = <String, Map<String, dynamic>>{
    'admin@macelectricos.com': {
      'password': 'admin123',
      'nombre': 'Administrador',
      'role': 'admin',
    },
    'tecnico@macelectricos.com': {
      'password': 'tecnico123',
      'nombre': 'Técnico Demo',
      'role': 'tecnico',
    },
    'supervisor@macelectricos.com': {
      'password': 'super123',
      'nombre': 'Supervisor Demo',
      'role': 'supervisor',
    },
  };

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simular latencia de red
    await Future.delayed(const Duration(milliseconds: 800));

    final mockUser = _mockUsers[email.toLowerCase()];
    if (mockUser == null) {
      return const Left(AuthFailure('Correo o contraseña incorrectos', code: 'wrong-credentials'));
    }
    if (mockUser['password'] != password) {
      return const Left(AuthFailure('Correo o contraseña incorrectos', code: 'wrong-credentials'));
    }

    final roleStr = mockUser['role'] as String;
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => UserRole.tecnico,
    );

    _currentUser = User(
      id: 'mock-${email.hashCode}',
      uid: 'mock-${email.hashCode}',
      nombre: mockUser['nombre'] as String,
      email: email,
      role: role,
      activo: true,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
      sincronizado: false,
    );

    _authStateController.add(_currentUser);
    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    required UserRole role,
    String? equipoId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    _currentUser = User(
      id: 'mock-${email.hashCode}',
      uid: 'mock-${email.hashCode}',
      nombre: nombre,
      email: email,
      role: role,
      equipoId: equipoId,
      activo: true,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
      sincronizado: false,
    );

    _authStateController.add(_currentUser);
    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStateController.add(null);
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    return Right(_currentUser);
  }

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? nombre,
    String? telefono,
    String? fotoUrl,
  }) async {
    if (_currentUser == null || _currentUser!.uid != userId) {
      return Left(AuthFailure.unknown('Usuario no autenticado'));
    }
    _currentUser = _currentUser!.copyWith(
      nombre: nombre ?? _currentUser!.nombre,
      telefono: telefono ?? _currentUser!.telefono,
      fotoUrl: fotoUrl ?? _currentUser!.fotoUrl,
      fechaActualizacion: DateTime.now(),
    );
    return Right(_currentUser!);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    return Right(_mockUsers.containsKey(email.toLowerCase()));
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByEquipo(String equipoId) async {
    return const Right([]);
  }

  void dispose() {
    _authStateController.close();
  }
}
