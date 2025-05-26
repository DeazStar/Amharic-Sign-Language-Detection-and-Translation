import 'package:bloc/bloc.dart';
import 'package:camera_app/core/error/failure.dart';
import 'package:camera_app/features/feedback/domain_layer/entity/feedback_entity.dart';
import 'package:camera_app/features/feedback/domain_layer/usecase/send_feedback_usecase.dart';

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SendFeedbackUseCase sendFeedback;

  FeedbackBloc({required this.sendFeedback}) : super(FeedbackInitial()) {
    on<SubmitFeedbackEvent>((event, emit) async {
      emit(FeedbackLoading());

      final result = await sendFeedback(FeedbackEntity(message: event.message));

      result.fold(
        (failure) => emit(FeedbackFailure(_mapFailureToMessage(failure))),
        (success) => emit(FeedbackSuccess()),
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'No internet connection.';
    } else if (failure is ServerFailure) {
      return 'Server error. Try again later.';
    } else {
      return 'Unexpected error.';
    }
  }
}
