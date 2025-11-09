import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../permissions/permission_manager.dart';
import '../firebase/firebase_manager.dart';

// Import all existing services
import '../../data/services/task_service_impl.dart';
import '../../data/services/habit_service_impl.dart';
import '../../data/services/notification_service_impl.dart';
import '../../data/services/achievement_engine_impl.dart';
import '../../data/services/reward_calculator_impl.dart';
import '../../data/services/ali_assistant_impl.dart';
import '../../data/services/validation_engine_impl.dart';
import '../../data/services/fitness_service_impl.dart';
import '../../data/services/meditation_service_impl.dart';
import '../../data/services/journal_service_impl.dart';
import '../../data/services/social_service_impl.dart';
import '../../data/services/marketplace_service_impl.dart';
import '../../data/services/subscription_service_impl.dart';
import '../../data/services/mental_health_service_impl.dart';
import '../../data/services/sleep_service_impl.dart';
import '../../data/services/reading_service_impl.dart';
import '../../data/services/meals_service_impl.dart';
import '../../data/services/language_service_impl.dart';
import '../../data/services/focus_service_impl.dart';
import '../../data/services/flashcards_service_impl.dart';
import '../../data/services/budget_service_impl.dart';

final GetIt getIt = GetIt.instance;

// Simple dependency setup for existing services
Future<void> setupDependencies() async {
  await _registerFirebase();
  _registerServices();
  _registerUtilities();
}

void _registerServices() {
  // Register all service implementations that exist
  getIt.registerLazySingleton<TaskService>(() => TaskServiceImpl());
  getIt.registerLazySingleton<HabitService>(() => HabitServiceImpl());
  getIt.registerLazySingleton<NotificationService>(() => NotificationServiceImpl());
  getIt.registerLazySingleton<AchievementEngine>(() => AchievementEngineImpl());
  getIt.registerLazySingleton<RewardCalculator>(() => RewardCalculatorImpl());
  getIt.registerLazySingleton<ALIAssistant>(() => ALIAssistantImpl());
  getIt.registerLazySingleton<ValidationEngine>(() => ValidationEngineImpl());
  getIt.registerLazySingleton<FitnessService>(() => FitnessServiceImpl());
  getIt.registerLazySingleton<MeditationService>(() => MeditationServiceImpl());
  getIt.registerLazySingleton<JournalService>(() => JournalServiceImpl());
  getIt.registerLazySingleton<SocialService>(() => SocialServiceImpl());
  getIt.registerLazySingleton<MarketplaceService>(() => MarketplaceServiceImpl());
  getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionServiceImpl());
  getIt.registerLazySingleton<MentalHealthService>(() => MentalHealthServiceImpl());
  getIt.registerLazySingleton<SleepService>(() => SleepServiceImpl());
  getIt.registerLazySingleton<ReadingService>(() => ReadingServiceImpl());
  getIt.registerLazySingleton<MealsService>(() => MealsServiceImpl());
  getIt.registerLazySingleton<LanguageService>(() => LanguageServiceImpl());
  getIt.registerLazySingleton<FocusService>(() => FocusServiceImpl());
  getIt.registerLazySingleton<FlashcardsService>(() => FlashcardsServiceImpl());
  getIt.registerLazySingleton<BudgetService>(() => BudgetServiceImpl());
}

Future<void> _registerFirebase() async {
  // Register and initialize Firebase Manager
  final firebaseManager = FirebaseManager();
  await firebaseManager.initialize();
  getIt.registerLazySingleton<FirebaseManager>(() => firebaseManager);
}

void _registerUtilities() {
  // Register utility classes and managers
  getIt.registerLazySingleton<PermissionManager>(() => PermissionManager());
}
