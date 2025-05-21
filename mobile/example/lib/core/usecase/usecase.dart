// lib/core/usecases/usecase.dart
import 'package:dartz/dartz.dart';
import '../error/failure.dart';
import 'package:equatable/equatable.dart';

/// Abstract base class for Use Cases in Clean Architecture.
///
/// Defines a standard `call` method for executing the use case logic.
/// [Type] represents the successful return type of the use case.
/// [Params] represents the parameters required to execute the use case.
abstract class UseCase<Type, Params> {
  /// Executes the use case logic.
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when a use case doesn't require any parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}


