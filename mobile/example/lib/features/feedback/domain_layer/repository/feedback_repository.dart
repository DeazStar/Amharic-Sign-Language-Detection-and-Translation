import 'package:dartz/dartz.dart';
import 'package:camera_app/core/error/failure.dart';
import 'package:camera_app/features/feedback/domain_layer/entity/feedback_entity.dart';


abstract class FeedbackRepository {
  Future<Either<Failure, bool>> sendFeedback(FeedbackEntity feedback);
}