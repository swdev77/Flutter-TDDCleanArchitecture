import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/bloc/bloc/number_trivia_bloc.dart';
import 'package:tdd_clean_architecture/injection_container.dart';

import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_display.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }
}

BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
  return BlocProvider(
    create: (_) => sl.get<NumberTriviaBloc>(),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            //Top half
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state is Empty) {
                  return const MessageDisplay(message: 'Start searching!');
                } else if (state is Loading) {
                  return const LoadingWidget();
                } else if (state is Loaded) {
                  return TriviaDisplay(numberTrivia: state.trivia);
                } else if (state is Error) {
                  return MessageDisplay(message: state.message);
                } else {
                  return const MessageDisplay(message: 'Test');
                }
              },
            ),
            const SizedBox(height: 20),
            //Bottom half
            const TriviaControls(),
          ],
        ),
      ),
    ),
  );
}

class TriviaControls extends StatefulWidget {
  const TriviaControls({super.key});

  @override
  TriviaControlsState createState() => TriviaControlsState();
}

class TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  late String inputStr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) => inputStr = value,
          onSubmitted: (_) => dispatchConcrete,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: dispatchConcrete,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextButton(
                onPressed: dispatchRandom,
                child: const Text('Get random trivia'),
              ),
            ),
          ],
        )
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputStr));
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
