import 'dart:math';

import 'package:grpc/grpc.dart' as grpc;
import 'package:grpc/service_api.dart';
import 'package:umka/generated/umka.pbgrpc.dart';
import 'package:umka/questions_db_driver.dart';

class UmkaService extends UmkaServiceBase {
  @override
  Future<Question> getQuestion(ServiceCall call, Student request) async {
    print('Received question request from: $request');
    return questionsDb[Random().nextInt(questionsDb.length)];
  }

  @override
  Future<Evaluation> sendAnswer(ServiceCall call, Answer request) async {
    print('Received answer for the question: $request');
    final correctAnswer = getCorrectAnswerById(request.question.id);
    if (correctAnswer == null) {
      throw grpc.GrpcError.invalidArgument('Invalid question id!');
    }
    final evaluation = Evaluation()
      ..id = 1
      ..answerId = request.id
      ..mark = (correctAnswer == request.text ? 5 : 2);
    return evaluation;
  }

  @override
  Stream<AnsweredQuestion> getTutorial(
      ServiceCall call, Student request) async* {
    for (var question in questionsDb) {
      final answeredQuestion = AnsweredQuestion()
        ..question = question
        ..answer = getCorrectAnswerById(question.id)!;
      yield answeredQuestion;
      await Future.delayed(Duration(seconds: 2));
    }
  }
}

class Server {
  Future<void> run() async {
    final server = grpc.Server([UmkaService()]);
    await server.serve(port: 5555);
    print('Servering on the port: ${server.port}');
  }
}

Future<void> main() async {
  await Server().run();
}
