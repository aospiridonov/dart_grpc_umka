import 'dart:async';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:umka/generated/umka.pbgrpc.dart';

class UmkaTerminalClient {
  late final ClientChannel channel;
  late final UmkaClient stub;

  UmkaTerminalClient() {
    channel = ClientChannel(
      '127.0.0.1',
      port: 5555,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = UmkaClient(channel);
  }

  Future<Question> getQuestion(Student student) async {
    final question = await stub.getQuestion(student);
    print('Received question: $question');
    return question;
  }

  Future<void> sendAnswer(Student student, Question question) async {
    final answer = Answer()
      ..question = question
      ..student = student;
    print('Enter your answer:');
    answer.text = stdin.readLineSync()!;
    final evaluation = await stub.sendAnswer(answer);
    print('Evaluation for the answer: ${answer.text} '
        '\non the question ${question.text}:'
        '\n$evaluation');
  }

  Future<void> takeTutorial(Student student) async {
    await for (var answeredQuestion in stub.getTutorial(student)) {
      print(answeredQuestion);
    }
  }

  Future<Evaluation> takeExam(Student student) async {
    final exam = await stub.getExam(student);
    final questions = exam.questions;
    final answerStream = StreamController<Answer>();
    final evaluationFuture = stub.takeExam(
      answerStream.stream,
      options: CallOptions(metadata: {'student_name': student.name}),
    );
    for (var question in questions) {
      final answer = Answer()
        ..question = question
        ..student = student;
      print('Enter the answer for the question: ${question.text}');
      answer.text = stdin.readLineSync()!;
      answerStream.add(answer);
      await Future.delayed(Duration(milliseconds: 1));
    }
    unawaited(answerStream.close());
    return evaluationFuture;
  }

  Future<void> techInterview(String candidateName) async {
    final candidateStream = StreamController<InterviewMessage>();
    final interviewerStream = stub.techInterview(candidateStream.stream);
    candidateStream.add(InterviewMessage()
      ..name = candidateName
      ..body = 'I am ready!');
    await for (var message in interviewerStream) {
      print('\nMessage from the ${message.name}:\n${message.body}\n');
      print('Enter your answer:');
      final answer = stdin.readLineSync()!;
      candidateStream.add(InterviewMessage()..body = answer);
    }
    unawaited(candidateStream.close());
  }

  Future<void> callService(Student student) async {
    await techInterview(student.name);
    await channel.shutdown();
  }
}

Future<void> main() async {
  final clientApp = UmkaTerminalClient();
  final student = Student()
    ..id = 42
    ..name = 'Alice Bobich';
  await clientApp.callService(student);
}
