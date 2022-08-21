import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/error/exception.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDatasourceImpl datasource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    datasource = NumberTriviaRemoteDatasourceImpl(client: mockHttpClient);
  });

  const number = 1;
  final numberTriviaModel =
      NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

  httpClientGet(String query) => mockHttpClient
      .get(Uri.http('numbersapi.com', query), headers: any(named: 'headers'));

  void setUpMockHttpClientSuccess200(String query) {
    when(() => httpClientGet(query))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFialure404(String query) {
    when(() => httpClientGet(query))
        .thenAnswer((_) async => http.Response('Something went wront', 404));
  }

  group('getConcreteNumberTrivia', () {
    test(
        'should preform a GET request on a URL with number being the endpoint and with application/json header',
        () {
      setUpMockHttpClientSuccess200('/$number');

      datasource.getConcreteNumberTrivia(number);

      verify(() {
        return mockHttpClient.get(
          Uri.http('numbersapi.com', '/$number'),
          headers: {'Content-Type': 'application/json'},
        );
      });
    });

    test('should return NuumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200('/$number');

      final result = await datasource.getConcreteNumberTrivia(number);

      expect(result, equals(numberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () {
      setUpMockHttpClientFialure404('/$number');

      final call = datasource.getConcreteNumberTrivia;

      expect(() => call(number), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    const query = '/random';
    final numberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
        'should perform a GET request on a URL with *random* endpoint with application/json header',
        () {
      setUpMockHttpClientSuccess200(query);

      datasource.getRandomNumberTrivia();

      verify(() => mockHttpClient.get(Uri.http('numbersapi.com', query),
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200(query);

      final result = await datasource.getRandomNumberTrivia();

      expect(result, equals(numberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other',
        () {
      setUpMockHttpClientFialure404(query);

      final call = datasource.getRandomNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
