
// lib/core/error/failure.dart
import 'package:equatable/equatable.dart';

/// Base class for representing failures/errors in the application.
/// Specific failure types (e.g., ServerFailure, CacheFailure) should extend this.
abstract class Failure extends Equatable {
  // If you want to pass properties to the Failure object, use this:
  // final List properties;
  // const Failure([this.properties = const <dynamic>[]]);
  // @override
  // List<Object> get props => [properties];

  // Simpler version without properties:
  const Failure();
  @override
  List<Object> get props => [];

  get message => null; // Ensure Equatable works even without properties
}

// Example specific failure:
class ServerFailure extends Failure {
  final String? message; // Optional message for more details
  const ServerFailure({this.message, int? statusCode});

   @override
  List<Object> get props => [message ?? 'ServerFailure']; // Include message if present
}

class LocalStorageFailure extends Failure {
   final String? message;
   const LocalStorageFailure({this.message});
    @override
   List<Object> get props => [message ?? 'LocalStorageFailure'];
}

class NetworkFailure extends Failure {
  final String? message;
  const NetworkFailure({this.message});
   @override
  List<Object> get props => [message ?? 'NetworkFailure'];
}