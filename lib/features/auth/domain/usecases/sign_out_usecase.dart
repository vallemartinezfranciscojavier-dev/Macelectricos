import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../failures/failures.dart';

/// Caso de uso: Cerrar sesión
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}