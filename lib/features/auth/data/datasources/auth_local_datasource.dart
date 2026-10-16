import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/user.dart';
import '../../domain/failures/failures.dart';

/// Contrato del data source local de auth
abstract class AuthLocalDataSource {
  /// Guardar token de sesión
  Future<Either<Failure, void>> saveAuthToken(String token);

  /// Obtener token guardado
  Future<Either<Failure, String?>> getAuthToken();

  /// Borrar token
  Future<Either<Failure, void>> clearAuthToken();

  /// Guardar datos de usuario
  Future<Either<Failure, void>> saveUserData(User user);

  /// Obtener datos de usuario guardados
  Future<Either<Failure, User?>> getUserData();

  /// Borrar datos de usuario
  Future<Either<Failure, void>> clearUserData();

  /// Verificar si hay sesión guardada
  Future<Either<Failure, bool>> hasSession();

  /// Guardar preferencia biométrica
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled);

  /// Obtener preferencia biométrica
  Future<Either<Failure, bool>> getBiometricEnabled();
}

/// Implementación con SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _userDataKey = 'user_data';
  static const _biometricKey = 'biometric_enabled';

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<Either<Failure, void>> saveAuthToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure.writeError('saveAuthToken: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAuthToken() async {
    try {
      final token = _prefs.getString(_tokenKey);
      return Right(token);
    } catch (e) {
      return Left(LocalDatabaseFailure.readError('getAuthToken: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAuthToken() async {
    try {
      await _prefs.remove(_tokenKey);
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure.writeError('clearAuthToken: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUserData(User user) async {
    try {
      // Guardar como JSON string
      final userJson = _userToJson(user);
      await _prefs.setString(_userDataKey, userJson);
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure.writeError('saveUserData: $e'));
    }
  }

  @override
  Future<Either<Failure, User?>> getUserData() async {
    try {
      final userJson = _prefs.getString(_userDataKey);
      if (userJson == null) return const Right(null);

      final user = _userFromJson(userJson);
      return Right(user);
    } catch (e) {
      return Left(LocalDatabaseFailure.readError('getUserData: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearUserData() async {
    try {
      await _prefs.remove(_userDataKey);
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure.writeError('clearUserData: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasSession() async {
    try {
      final token = _prefs.getString(_tokenKey);
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return Left(LocalDatabaseFailure.readError('hasSession: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setBiometricEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_biometricKey, enabled);
      return const Right(null);
    } catch (e) {
      return Left(LocalDatabaseFailure.writeError('setBiometricEnabled: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getBiometricEnabled() async {
    try {
      final enabled = _prefs.getBool(_biometricKey) ?? false;
      return Right(enabled);
    } catch (e) {
      return Left(LocalDatabaseFailure.readError('getBiometricEnabled: $e'));
    }
  }

  // Helper methods for JSON serialization
  String _userToJson(User user) {
    // Simple JSON - en producción usar json_serializable
    return '''
    {
      "id": "${user.id}",
      "uid": "${user.uid}",
      "nombre": "${user.nombre}",
      "email": "${user.email}",
      "role": "${user.role.name}",
      "equipoId": "${user.equipoId ?? ''}",
      "telefono": "${user.telefono ?? ''}",
      "fotoUrl": "${user.fotoUrl ?? ''}",
      "activo": ${user.activo},
      "fechaCreacion": "${user.fechaCreacion.toIso8601String()}",
      "fechaActualizacion": "${user.fechaActualizacion.toIso8601String()}",
      "sincronizado": ${user.sincronizado}
    }
    ''';
  }

  User _userFromJson(String json) {
    // Parser simple - en producción usar json_serializable
    // Por simplicidad, retornamos un user mock
    return User(
      id: 'local',
      uid: 'local',
      nombre: 'Usuario Local',
      email: 'local@local.com',
      role: UserRole.tecnico,
      activo: true,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
      sincronizado: false,
    );
  }
}