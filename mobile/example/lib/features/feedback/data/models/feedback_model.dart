import 'package:camera_app/features/feedback/domain_layer/entity/feedback_entity.dart';


class FeedbackModel extends FeedbackEntity {
  FeedbackModel({required String message}) : super(message: message);

  Map<String, dynamic> toJson() => {
        'message': message,
      };
}
