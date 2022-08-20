import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/error/exception.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/platform/network_info.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDatasource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDatasource: mockRemoteDataSource,
      localDatasource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const number = 1;
  const numberTriviaModel = NumberTriviaModel(
    text: 'test text',
    number: number,
  );
  const NumberTrivia numberTrivia = numberTriviaModel;

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getConcreteNumberTrivia(number))
          .thenAnswer((_) async => numberTriviaModel);
      when(() => mockLocalDataSource.cacheNumberTrivia(numberTriviaModel))
          .thenAnswer((_) async => _);

      repository.getConcreteNumberTrivia(number);

      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
          'should return data when the call to remote data source is successful',
          () async {
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(number))
            .thenAnswer((_) async => numberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(numberTriviaModel))
            .thenAnswer((_) async => _);

        final result = await repository.getConcreteNumberTrivia(number);

        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(number));
        expect(result, equals(const Right(numberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(number))
            .thenAnswer((_) async => numberTriviaModel);
        when(() => mockLocalDataSource.cacheNumberTrivia(numberTriviaModel))
            .thenAnswer((_) async => _);

        await repository.getConcreteNumberTrivia(number);

        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(number));
        verify(() => mockLocalDataSource.cacheNumberTrivia(numberTriviaModel));
      });

      test(
          'should return server failure when the call to remote data source is unsuccessful',
          () async {
        when(() => mockRemoteDataSource.getConcreteNumberTrivia(number))
            .thenThrow(ServerException());

        final result = await repository.getConcreteNumberTrivia(number);

        verify(() => mockRemoteDataSource.getConcreteNumberTrivia(number));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => numberTriviaModel);

        final result = await repository.getConcreteNumberTrivia(number);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(const Right(numberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        final result = await repository.getConcreteNumberTrivia(number);

        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    setUp(() {
      when(() => mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => numberTriviaModel);
      when(() => mockLocalDataSource.cacheNumberTrivia(numberTriviaModel))
          .thenAnswer((_) async => _);
    });

    test('should check if the device is online', () {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      repository.getRandomNumberTrivia();
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
          () async {
        final result = await repository.getRandomNumberTrivia();

        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, equals(const Right(numberTrivia)));
      });

      test(
          'should cache the data locally when the call to remote data source is successful',
          () async {
        await repository.getRandomNumberTrivia();

        verify(() => mockRemoteDataSource.getRandomNumberTrivia());
        verify(() => mockLocalDataSource.cacheNumberTrivia(numberTriviaModel));
      });

      test(
          'should retrun server failure when the call to remote data source is unsuccessful',
          () async {
        when(() => mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());

        final result = await repository.getRandomNumberTrivia();

        expect(result, equals(Left(ServerFailure())));
      });
    });

    runTestsOffline(() {
      test(
          'should return last locally cached data when the cached data is present',
          () async {
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => numberTriviaModel);

        final result = await repository.getRandomNumberTrivia();

        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());

        expect(result, equals(const Right(numberTrivia)));
      });

      test('should return CacheFailure when there is no cached data present',
          () async {
        when(() => mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());

        final result = await repository.getRandomNumberTrivia();

        verifyZeroInteractions(mockRemoteDataSource);
        verify(() => mockLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
