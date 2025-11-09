import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../permissions/permission_manager.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

// Manual registration for complex dependencies
Future<void> setupDependencies() async {
  await configureDependencies();
  
  // Register additional dependencies that need manual setup
  _registerDataSources();
  _registerRepositories();
  _registerServices();
  _registerEngines();
  _registerUseCases();
}

void _registerDataSources() {
  // All data sources will be registered here
}

void _registerRepositories() {
  // All repositories will be registered here  
}

void _registerServices() {
  // All services will be registered here
}

void _registerEngines() {
  // All engines will be registered here
}

void _registerUseCases() {
  // All use cases will be registered here
}
