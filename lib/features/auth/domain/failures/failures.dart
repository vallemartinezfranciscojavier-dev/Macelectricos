import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Clase base para todos los fallos de la aplicación
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Fallos de autenticación
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthFailure('No existe una cuenta con este correo electrónico', code: 'user-not-found');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Contraseña incorrecta', code: 'wrong-password');
      case 'email-already-in-use':
        return const AuthFailure('Este correo ya está registrado', code: 'email-already-in-use');
      case 'weak-password':
        return const AuthFailure('La contraseña es muy débil (mínimo 6 caracteres)', code: 'weak-password');
      case 'invalid-email':
        return const AuthFailure('El formato del correo no es válido', code: 'invalid-email');
      case 'user-disabled':
        return const AuthFailure('Esta cuenta ha sido deshabilitada', code: 'user-disabled');
      case 'too-many-requests':
        return const AuthFailure('Demasiados intentos fallidos. Intenta más tarde', code: 'too-many-requests');
      case 'operation-not-allowed':
        return const AuthFailure('Operación no permitida', code: 'operation-not-allowed');
      case 'network-request-failed':
        return const AuthFailure('Error de conexión. Verifica tu internet', code: 'network-error');
      default:
        return AuthFailure('Error de autenticación: ${e.message}', code: e.code);
    }
  }

  factory AuthFailure.unknown(String message) {
    return AuthFailure(message, code: 'unknown');
  }
}

/// Fallos de red / conectividad
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});

  factory NetworkFailure.noConnection() {
    return const NetworkFailure('Sin conexión a internet', code: 'no-connection');
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure('Tiempo de espera agotado', code: 'timeout');
  }

  factory NetworkFailure.serverError() {
    return const NetworkFailure('Error del servidor. Intenta más tarde', code: 'server-error');
  }
}

/// Fallos de base de datos local
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure(super.message, {super.code});

  factory LocalDatabaseFailure.writeError(String details) {
    return LocalDatabaseFailure('Error guardando localmente: $details', code: 'write-error');
  }

  factory LocalDatabaseFailure.readError(String details) {
    return LocalDatabaseFailure('Error leyendo localmente: $details', code: 'read-error');
  }

  factory LocalDatabaseFailure.notFound(String entity) {
    return LocalDatabaseFailure('$entity no encontrado localmente', code: 'not-found');
  }
}

/// Fallos de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});

  factory ValidationFailure.emptyField(String field) {
    return ValidationFailure('El campo $field es obligatorio', code: 'empty-field');
  }

  factory ValidationFailure.invalidFormat(String field, String expected) {
    return ValidationFailure('$field tiene formato inválido. Se esperaba: $expected', code: 'invalid-format');
  }

  factory ValidationFailure.tooShort(String field, int minLength) {
    return ValidationFailure('$field debe tener al menos $minLength caracteres', code: 'too-short');
  }

  factory ValidationFailure.tooLong(String field, int maxLength) {
    return ValidationFailure('$field no puede exceder $maxLength caracteres', code: 'too-long');
  }
}

/// Fallos de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});

  factory PermissionFailure.denied(String permission) {
    return PermissionFailure('Permiso denegado: $permission', code: 'permission-denied');
  }

  factory PermissionFailure.insufficientRole(String requiredRole) {
    return PermissionFailure('Se requiere rol: $requiredRole', code: 'insufficient-role');
  }
}

/// Fallos de sincronización
class SyncFailure extends Failure {
  const SyncFailure(super.message, {super.code});

  factory SyncFailure.conflict(String entity) {
    return SyncFailure('Conflicto de sincronización en $entity. Requiere revisión manual', code: 'conflict');
  }

  factory SyncFailure.queueFull() {
    return const SyncFailure('Cola de sincronización llena', code: 'queue-full');
  }

  factory SyncFailure.maxRetriesExceeded(String entity) {
    return SyncFailure('Máximos reintentos excedidos para $entity', code: 'max-retries');
  }
}

/// Fallos de almacenamiento (Firebase Storage)
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});

  factory StorageFailure.uploadFailed(String details) {
    return StorageFailure('Error subiendo archivo: $details', code: 'upload-failed');
  }

  factory StorageFailure.downloadFailed(String details) {
    return StorageFailure('Error descargando archivo: $details', code: 'download-failed');
  }

  factory StorageFailure.fileNotFound(String path) {
    return StorageFailure('Archivo no encontrado: $path', code: 'file-not-found');
  }

  factory StorageFailure.unauthorized() {
    return const StorageFailure('No autorizado para acceder al almacenamiento', code: 'unauthorized');
  }
}

/// Fallos genéricos / desconocidos
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});

  factory UnexpectedFailure.fromException(Exception e) {
    return UnexpectedFailure('Error inesperado: $e', code: 'unexpected');
  }
}

