import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:submee/models/environment.dart';

final environmentService = Provider((ref) {
  final service = EnvironmentService();
  service.loadEnvironment();
  return service;
});

class EnvironmentService {
  late final Environment environment;

  void loadEnvironment() {
    environment = Environment.fromDotEnv(dotenv.env);
  }
}
