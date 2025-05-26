part of 'feedback_bloc.dart';


abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {}

class FeedbackFailure extends FeedbackState {
  final String message;

  FeedbackFailure(this.message);

  @override
  List<Object?> get props => [message];
}
