import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const numberTriviaModel = NumberTriviaModel(text: 'Test Text', number: 1);
  test('should be a subclass of NumberTrivia entity', () async {
    expect(numberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON number is an integer',
        () async {
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, numberTriviaModel);
    });

    test(
        'should return a valid model when the JSON number is regarded as a double',
        () async {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, numberTriviaModel);
    });
  });

  group('toJson', () {
    test('should retrun a JSON map containing the proper data', () async {
      final result = numberTriviaModel.toJson();
      final expectedJsonMap = {
        "text": "Test Text",
        "number": 1,
      };
      expect(result, expectedJsonMap);
    });
  });
}
