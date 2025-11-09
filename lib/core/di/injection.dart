import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../permissions/permission_manager.dart';

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
  _registerUtilities();
}

void _registerDataSources() {
  // Register Firebase and network clients
  // Note: These will be implemented when Firebase is configured
  // getIt.registerLazySingleton<FirebaseManager>(() => FirebaseManagerImpl());
  // getIt.registerLazySingleton<NetworkClient>(() => NetworkClientImpl());
}

void _registerRepositories() {
  // Register all repository implementations
  getIt.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl());
  getIt.registerLazySingleton<HabitRepository>(() => HabitRepositoryImpl());
  getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  getIt.registerLazySingleton<AnalyticsRepository>(() => AnalyticsRepositoryImpl());
  getIt.registerLazySingleton<CareerRepository>(() => CareerRepositoryImpl());
  getIt.registerLazySingleton<CreativityRepository>(() => CreativityRepositoryImpl());
  getIt.registerLazySingleton<MentalHealthRepository>(() => MentalHealthRepositoryImpl());
  getIt.registerLazySingleton<MeditationRepository>(() => MeditationRepositoryImpl());
  getIt.registerLazySingleton<MealsRepository>(() => MealsRepositoryImpl());
  getIt.registerLazySingleton<MarketplaceRepository>(() => MarketplaceRepositoryImpl());
  getIt.registerLazySingleton<LanguageRepository>(() => LanguageRepositoryImpl());
  getIt.registerLazySingleton<JournalRepository>(() => JournalRepositoryImpl());
  getIt.registerLazySingleton<FocusRepository>(() => FocusRepositoryImpl());
  getIt.registerLazySingleton<FlashcardsRepository>(() => FlashcardsRepositoryImpl());
  getIt.registerLazySingleton<FitnessRepository>(() => FitnessRepositoryImpl());
  getIt.registerLazySingleton<BudgetRepository>(() => BudgetRepositoryImpl());
  getIt.registerLazySingleton<SubscriptionRepository>(() => SubscriptionRepositoryImpl());
  getIt.registerLazySingleton<SocialRepository>(() => SocialRepositoryImpl());
  getIt.registerLazySingleton<SleepRepository>(() => SleepRepositoryImpl());
  getIt.registerLazySingleton<ReadingRepository>(() => ReadingRepositoryImpl());
}

void _registerServices() {
  // Register all service implementations
  getIt.registerLazySingleton<TaskService>(() => TaskServiceImpl());
  getIt.registerLazySingleton<HabitService>(() => HabitServiceImpl());
  getIt.registerLazySingleton<UserService>(() => UserServiceImpl());
  getIt.registerLazySingleton<AuthService>(() => AuthServiceImpl());
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

void _registerEngines() {
  // Register specialized engines
  // Note: These are already registered above as services since they implement service interfaces
}

void _registerUseCases() {
  // Register all use case implementations
  getIt.registerLazySingleton<TaskUseCases>(() => TaskUseCases(
    repository: getIt<TaskRepository>(),
  ));
  getIt.registerLazySingleton<HabitUseCases>(() => HabitUseCases(
    repository: getIt<HabitRepository>(),
  ));
  getIt.registerLazySingleton<UserUseCases>(() => UserUseCases(
    repository: getIt<UserRepository>(),
  ));
  getIt.registerLazySingleton<FitnessUseCases>(() => FitnessUseCases(
    repository: getIt<FitnessRepository>(),
  ));
  getIt.registerLazySingleton<MeditationUseCases>(() => MeditationUseCases(
    repository: getIt<MeditationRepository>(),
  ));
  getIt.registerLazySingleton<JournalUseCases>(() => JournalUseCases(
    repository: getIt<JournalRepository>(),
  ));
  getIt.registerLazySingleton<SocialUseCases>(() => SocialUseCases(
    repository: getIt<SocialRepository>(),
  ));
  getIt.registerLazySingleton<MarketplaceUseCases>(() => MarketplaceUseCases(
    repository: getIt<MarketplaceRepository>(),
  ));
  getIt.registerLazySingleton<SubscriptionUseCases>(() => SubscriptionUseCases(
    repository: getIt<SubscriptionRepository>(),
  ));
  getIt.registerLazySingleton<MentalHealthUseCases>(() => MentalHealthUseCases(
    repository: getIt<MentalHealthRepository>(),
  ));
  getIt.registerLazySingleton<SleepUseCases>(() => SleepUseCases(
    repository: getIt<SleepRepository>(),
  ));
  getIt.registerLazySingleton<ReadingUseCases>(() => ReadingUseCases(
    repository: getIt<ReadingRepository>(),
  ));
  getIt.registerLazySingleton<MealsUseCases>(() => MealsUseCases(
    repository: getIt<MealsRepository>(),
  ));
  getIt.registerLazySingleton<LanguageUseCases>(() => LanguageUseCases(
    repository: getIt<LanguageRepository>(),
  ));
  getIt.registerLazySingleton<FocusUseCases>(() => FocusUseCases(
    repository: getIt<FocusRepository>(),
  ));
  getIt.registerLazySingleton<FlashcardsUseCases>(() => FlashcardsUseCases(
    repository: getIt<FlashcardsRepository>(),
  ));
  getIt.registerLazySingleton<BudgetUseCases>(() => BudgetUseCases(
    repository: getIt<BudgetRepository>(),
  ));
}

void _registerUtilities() {
  // Register utility classes and managers
  getIt.registerLazySingleton<PermissionManager>(() => PermissionManager());
}
