import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../failures/failures.dart';
import '../entities/user.dart';

/// Caso de uso: Iniciar sesión
class SignInUseCase {
  final AuthRepository _repository;

  SignInUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validaciones básicas
    if (email.trim().isEmpty) {
      return Left(ValidationFailure.emptyField('correo electrónico'));
    }
    if (password.isEmpty) {
      return Left(ValidationFailure.emptyField('contraseña'));
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      return Left(ValidationFailure.invalidFormat('correo electrónico', 'usuario@dominio.com'));
    }
    if (password.length < 6) {
      return Left(ValidationFailure.tooShort('contraseña', 6));
    }

    return await _repository.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }
}