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

  Future<void> callService(Student student) async {
    await getQuestion(student);
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