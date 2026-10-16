import 'package:equatable/equatable.dart';

/// Roles de usuario en el sistema
enum UserRole {
  tecnico,
  supervisor,
  admin,
}

/// Entidad de usuario del dominio
class User extends Equatable {
  final String id;
  final String uid;           // Firebase UID
  final String nombre;
  final String email;
  final UserRole role;
  final String? equipoId;     // FK → Crew
  final String? telefono;
  final String? fotoUrl;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final bool sincronizado;

  const User({
    required this.id,
    required this.uid,
    required this.nombre,
    required this.email,
    required this.role,
    this.equipoId,
    this.telefono,
    this.fotoUrl,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.sincronizado,
  });

  /// Nombre corto para avatar
  String get initials {
    final parts = nombre.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return nombre.substring(0, 1).toUpperCase();
  }

  /// Verificar si es admin
  bool get isAdmin => role == UserRole.admin;

  /// Verificar si es supervisor
  bool get isSupervisor => role == UserRole.supervisor;

  /// Verificar si es técnico
  bool get isTecnico => role == UserRole.tecnico;

  @override
  List<Object?> get props => [
    id,
    uid,
    nombre,
    email,
    role,
    equipoId,
    telefono,
    fotoUrl,
    activo,
    fechaCreacion,
    fechaActualizacion,
    sincronizado,
  ];

  User copyWith({
    String? id,
    String? uid,
    String? nombre,
    String? email,
    UserRole? role,
    String? equipoId,
    String? telefono,
    String? fotoUrl,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    bool? sincronizado,
  }) {
    return User(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      role: role ?? this.role,
      equipoId: equipoId ?? this.equipoId,
      telefono: telefono ?? this.telefono,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}

/// Estado de autenticación
enum AuthStatus {
  unknown,
  unauthenticated,
  authenticated,
  loading,
  error,
}

/// Estado del auth provider
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, user, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}