import 'package:dartz/dartz.dart';
import 'package:camera_app/core/error/failure.dart';
import 'package:camera_app/core/network/network_info.dart';
import 'package:camera_app/features/feedback/data/data_source/feedback_datasource.dart';
import 'package:camera_app/features/feedback/domain_layer/entity/feedback_entity.dart';
import 'package:camera_app/features/feedback/domain_layer/repository/feedback_repository.dart';

import '../models/feedback_model.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;
  final NetworkInfo _networkInfo;

  FeedbackRepositoryImpl({
    required this.remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> sendFeedback(FeedbackEntity feedback) async {
  
    if (await _networkInfo.isConnected) {
      try {
        final model = FeedbackModel(message: feedback.message);
        final result = await remoteDataSource.sendFeedback(model);
       
        return Right(result);
      } catch (e) {
        
        return Left(ServerFailure(message: e.toString())); 
      }
    } else {
     
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
