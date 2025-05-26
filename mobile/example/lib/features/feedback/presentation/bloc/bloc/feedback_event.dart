// import 'package:equatable/equatable.dart';
part of 'feedback_bloc.dart';


class FeedbackEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitFeedbackEvent extends FeedbackEvent {
  final String message;

  SubmitFeedbackEvent(this.message);

  @override
  List<Object?> get props => [message];
}
