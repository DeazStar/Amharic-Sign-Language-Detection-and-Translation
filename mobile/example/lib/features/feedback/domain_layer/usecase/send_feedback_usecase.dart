import 'package:dartz/dartz.dart';
import 'package:camera_app/core/error/failure.dart';
import 'package:camera_app/features/feedback/domain_layer/entity/feedback_entity.dart';
import 'package:camera_app/features/feedback/domain_layer/repository/feedback_repository.dart';


class SendFeedbackUseCase {
  final FeedbackRepository repository;

  SendFeedbackUseCase(this.repository);

  Future<Either<Failure, bool>> call(FeedbackEntity feedback) {
    
    return repository.sendFeedback(feedback);
  }
}