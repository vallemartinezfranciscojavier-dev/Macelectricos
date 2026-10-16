import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/failures.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementación del repositorio de autenticación
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _localDataSource;
  final fb_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required fb_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _localDataSource = localDataSource,
        _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Autenticar con Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        return Left(AuthFailure.unknown('No se pudo obtener usuario de Firebase'));
      }

      // Obtener datos extendidos de Firestore
      final userDoc = await _firestore.collection('usuarios').doc(fbUser.uid).get();

      User user;
      if (userDoc.exists) {
        user = _userFromFirestore(userDoc);
      } else {
        // Usuario nuevo en Firebase pero sin documento en Firestore
        // Crear documento básico
        user = User(
          id: fbUser.uid,
          uid: fbUser.uid,
          nombre: fbUser.displayName ?? 'Usuario',
          email: fbUser.email ?? email,
          role: UserRole.tecnico,
          activo: true,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
          sincronizado: false,
        );
        await _createUserDocument(user);
      }

      // Guardar localmente
      await _localDataSource.saveAuthToken(await fbUser.getIdToken() ?? '');
      await _localDataSource.saveUserData(user);

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } on FirebaseException catch (e) {
      return Left(AuthFailure.unknown(e.message ?? 'Error de Firebase'));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    required UserRole role,
    String? equipoId,
  }) async {
    try {
      // Crear en Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser == null) {
        return Left(AuthFailure.unknown('No se pudo crear usuario en Firebase'));
      }

      // Actualizar display name
      await fbUser.updateDisplayName(nombre);

      // Crear documento en Firestore
      final user = User(
        id: fbUser.uid,
        uid: fbUser.uid,
        nombre: nombre,
        email: email,
        role: role,
        equipoId: equipoId,
        activo: true,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
        sincronizado: true,
      );

      await _createUserDocument(user);

      // Guardar localmente
      await _localDataSource.saveAuthToken(await fbUser.getIdToken() ?? '');
      await _localDataSource.saveUserData(user);

      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _localDataSource.clearAuthToken();
      await _localDataSource.clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Primero intentar desde local
      final localUserResult = await _localDataSource.getUserData();
      final localUser = localUserResult.fold((failure) => null, (user) => user);
      if (localUser != null) {
        // Verificar si el token sigue válido en Firebase
        final fbUser = _firebaseAuth.currentUser;
        if (fbUser != null && fbUser.uid == localUser.uid) {
          return Right(localUser);
        }
      }

      // Si no hay local o token inválido, intentar Firebase
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null) {
        return const Right(null);
      }

      // Obtener datos frescos de Firestore
      final userDoc = await _firestore.collection('usuarios').doc(fbUser.uid).get();
      if (!userDoc.exists) {
        return const Right(null);
      }

      final user = _userFromFirestore(userDoc);

      // Actualizar cache local
      await _localDataSource.saveAuthToken(await fbUser.getIdToken() ?? '');
      await _localDataSource.saveUserData(user);

      return Right(user);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) {
        await _localDataSource.clearAuthToken();
        await _localDataSource.clearUserData();
        return null;
      }

      // Usuario autenticado, obtener datos
      final result = await getCurrentUser();
      return result.fold(
        (failure) => null,
        (user) => user,
      );
    });
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? nombre,
    String? telefono,
    String? fotoUrl,
  }) async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null || fbUser.uid != userId) {
        return Left(AuthFailure.unknown('Usuario no autenticado'));
      }

      // Actualizar en Firebase Auth si hay nombre
      if (nombre != null && nombre != fbUser.displayName) {
        await fbUser.updateDisplayName(nombre);
      }

      // Actualizar en Firestore
      final updates = <String, dynamic>{};
      if (nombre != null) updates['nombre'] = nombre;
      if (telefono != null) updates['telefono'] = telefono;
      if (fotoUrl != null) updates['fotoUrl'] = fotoUrl;
      updates['fechaActualizacion'] = FieldValue.serverTimestamp();
      updates['sincronizado'] = true;

      await _firestore.collection('usuarios').doc(userId).update(updates);

      // Obtener usuario actualizado
      final userDoc = await _firestore.collection('usuarios').doc(userId).get();
      final user = _userFromFirestore(userDoc);

      // Actualizar cache local
      await _localDataSource.saveUserData(user);

      return Right(user);
    } on FirebaseException catch (e) {
      return Left(AuthFailure.unknown(e.message ?? 'Error actualizando perfil'));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final fbUser = _firebaseAuth.currentUser;
      if (fbUser == null || fbUser.email == null) {
        return Left(AuthFailure.unknown('Usuario no autenticado'));
      }

      // Re-autenticar
      final credential = fb_auth.EmailAuthProvider.credential(
        email: fbUser.email!,
        password: currentPassword,
      );
      await fbUser.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await fbUser.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromFirebaseAuthException(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, bool>> checkEmailExists(String email) async {
    try {
      // Usar fetchSignInMethodsForEmail para verificar si existe
      final methods = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return Right(methods.isNotEmpty);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByRole(UserRole role) async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .where('role', isEqualTo: role.name)
          .where('activo', isEqualTo: true)
          .get();

      final users = query.docs.map(_userFromFirestore).toList();
      return Right(users);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getUsersByEquipo(String equipoId) async {
    try {
      final query = await _firestore
          .collection('usuarios')
          .where('equipoId', isEqualTo: equipoId)
          .where('activo', isEqualTo: true)
          .get();

      final users = query.docs.map(_userFromFirestore).toList();
      return Right(users);
    } catch (e) {
      return Left(UnexpectedFailure.fromException(e as Exception));
    }
  }

  // Helpers
  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('usuarios').doc(user.uid).set({
      'id': user.id,
      'uid': user.uid,
      'nombre': user.nombre,
      'email': user.email,
      'role': user.role.name,
      'equipoId': user.equipoId,
      'telefono': user.telefono,
      'fotoUrl': user.fotoUrl,
      'activo': user.activo,
      'fechaCreacion': FieldValue.serverTimestamp(),
      'fechaActualizacion': FieldValue.serverTimestamp(),
      'sincronizado': user.sincronizado,
    });
  }

  User _userFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: data['id'] ?? doc.id,
      uid: data['uid'] ?? doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.byName(data['role'] ?? 'tecnico'),
      equipoId: data['equipoId'],
      telefono: data['telefono'],
      fotoUrl: data['fotoUrl'],
      activo: data['activo'] ?? true,
      fechaCreacion: (data['fechaCreacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaActualizacion: (data['fechaActualizacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sincronizado: data['sincronizado'] ?? false,
    );
  }
}