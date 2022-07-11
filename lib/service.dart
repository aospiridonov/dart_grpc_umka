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
  Future<Evaluation> sendAnswer(ServiceCall call, Answer request) {
    // TODO: implement sendAnswer
    throw UnimplementedError();
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
