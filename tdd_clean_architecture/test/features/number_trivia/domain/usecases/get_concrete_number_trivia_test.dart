import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(text: 'test', number: 1);

  test(
    'should get trivia for the number from the repository',
    () async {
      final MockNumberTriviaRepository repository = MockNumberTriviaRepository();
      final GetConcreteNumberTrivia usecase = GetConcreteNumberTrivia(repository);

      when(() => repository.getConcreteNumberTrivia(any<int>()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      final result = await usecase.execute(number: tNumber);

      expect(result, const Right(tNumberTrivia));
    },
  );
}
