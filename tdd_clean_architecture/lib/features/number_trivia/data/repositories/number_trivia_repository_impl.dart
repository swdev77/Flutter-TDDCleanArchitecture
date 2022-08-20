import 'package:dartz/dartz.dart';

import '../../../../core/error/exception.dart';
import '../datasources/number_trivia_local_datasource.dart';
import '../datasources/number_trivia_remote_datasource.dart';
import '../models/number_trivia_model.dart';
import '../../domain/entities/number_trivia.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../../../../core/network/network_info.dart';

typedef _ConcreteOrRandonChooser = Future<NumberTrivia> Function();

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDatasource remoteDatasource;
  final NumberTriviaLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
        () => remoteDatasource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => remoteDatasource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
    _ConcreteOrRandonChooser getConcreteOrRandom,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConcreteOrRandom();
        localDatasource.cacheNumberTrivia(remoteTrivia as NumberTriviaModel);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDatasource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
