import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd_clean_architecture/core/error/exception.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDatasourceImpl datasource;
  late MockSharedPreferences mockSharedPreference;

  setUp(() {
    mockSharedPreference = MockSharedPreferences();
    datasource = NumberTriviaLocalDatasourceImpl(
        sharedPreferences: mockSharedPreference);
  });

  group('getLastNumberTrivia', () {
    final numberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      when(() => mockSharedPreference.getString(any()))
          .thenReturn(fixture('trivia_cached.json'));

      final result = await datasource.getLastNumberTrivia();

      expect(result, equals(numberTriviaModel));
    });

    test('should throw a CachedException when there is not a cached value',
        () async {
      when(() => mockSharedPreference.getString(any())).thenReturn(null);

      final call = datasource.getLastNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
    });
  });

  group('cachedNumberTrivia', () {
    const numberTriviaModel =
        NumberTriviaModel(text: 'test trivia', number: 1);

    test('should call SharedPreferences to cache the data', () {
      when(() => mockSharedPreference.setString(any(), any()))
          .thenAnswer((_) => Future.value(true));

      datasource.cacheNumberTrivia(numberTriviaModel);

      final expectedJsonString = json.encode(numberTriviaModel.toJson());

      verify(() => mockSharedPreference.setString(
          keyCachedNumberTrivia, expectedJsonString));
    });
  });
}
