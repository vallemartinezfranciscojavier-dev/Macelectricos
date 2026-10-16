import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../failures/failures.dart';
import '../entities/user.dart';

/// Caso de uso: Obtener usuario actual
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase({required AuthRepository repository}) : _repository = repository;

  Future<Either<Failure, User?>> call() async {
    return await _repository.getCurrentUser();
  }
}