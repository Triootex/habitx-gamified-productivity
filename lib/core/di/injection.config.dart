// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../../data/datasources/local/habit_local_datasource.dart' as _i3;
import '../../data/datasources/local/task_local_datasource.dart' as _i4;
import '../../data/datasources/local/user_local_datasource.dart' as _i5;
import '../../data/datasources/remote/firebase_manager.dart' as _i6;
import '../../data/datasources/remote/network_client.dart' as _i7;
import '../../data/datasources/remote/task_remote_datasource.dart' as _i8;
import '../../data/datasources/remote/user_remote_datasource.dart' as _i9;
import '../../data/repositories/analytics_repository_impl.dart' as _i10;
import '../../data/repositories/career_repository_impl.dart' as _i11;
import '../../data/repositories/creativity_repository_impl.dart' as _i12;
import '../../data/repositories/habit_repository_impl.dart' as _i13;
import '../../data/repositories/task_repository_impl.dart' as _i14;
import '../../data/repositories/user_repository_impl.dart' as _i15;
import '../../domain/repositories/analytics_repository.dart' as _i16;
import '../../domain/repositories/career_repository.dart' as _i17;
import '../../domain/repositories/creativity_repository.dart' as _i18;
import '../../domain/repositories/habit_repository.dart' as _i19;
import '../../domain/repositories/task_repository.dart' as _i20;
import '../../domain/repositories/user_repository.dart' as _i21;
import '../../domain/usecases/achievement_usecases.dart' as _i22;
import '../../domain/usecases/habit_usecases.dart' as _i23;
import '../../domain/usecases/task_usecases.dart' as _i24;
import '../../domain/usecases/user_usecases.dart' as _i25;
import '../../services/achievement_engine.dart' as _i26;
import '../../services/ad_manager.dart' as _i27;
import '../../services/ali_assistant.dart' as _i28;
import '../../services/background_service.dart' as _i29;
import '../../services/billing_manager.dart' as _i30;
import '../../services/notification_service.dart' as _i31;
import '../../services/reminder_service.dart' as _i32;
import '../../services/reward_calculator.dart' as _i33;
import '../../services/smart_notification_manager.dart' as _i34;
import '../../services/validation_engine.dart' as _i35;

extension GetItInjectableX on _i1.GetIt {
  // initializes the registration of main dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    
    // Data Sources
    gh.lazySingleton<_i7.NetworkClient>(() => _i7.NetworkClientImpl());
    gh.lazySingleton<_i6.FirebaseManager>(() => _i6.FirebaseManagerImpl());
    
    // Local Data Sources
    gh.lazySingleton<_i5.UserLocalDataSource>(() => _i5.UserLocalDataSourceImpl());
    gh.lazySingleton<_i4.TaskLocalDataSource>(() => _i4.TaskLocalDataSourceImpl());
    gh.lazySingleton<_i3.HabitLocalDataSource>(() => _i3.HabitLocalDataSourceImpl());
    
    // Remote Data Sources
    gh.lazySingleton<_i9.UserRemoteDataSource>(() => _i9.UserRemoteDataSourceImpl(
      firebaseManager: gh<_i6.FirebaseManager>(),
      networkClient: gh<_i7.NetworkClient>(),
    ));
    gh.lazySingleton<_i8.TaskRemoteDataSource>(() => _i8.TaskRemoteDataSourceImpl(
      firebaseManager: gh<_i6.FirebaseManager>(),
    ));
    
    // Repositories
    gh.lazySingleton<_i21.UserRepository>(() => _i15.UserRepositoryImpl(
      localDataSource: gh<_i5.UserLocalDataSource>(),
      remoteDataSource: gh<_i9.UserRemoteDataSource>(),
    ));
    gh.lazySingleton<_i20.TaskRepository>(() => _i14.TaskRepositoryImpl(
      localDataSource: gh<_i4.TaskLocalDataSource>(),
      remoteDataSource: gh<_i8.TaskRemoteDataSource>(),
    ));
    gh.lazySingleton<_i19.HabitRepository>(() => _i13.HabitRepositoryImpl(
      localDataSource: gh<_i3.HabitLocalDataSource>(),
    ));
    gh.lazySingleton<_i17.CareerRepository>(() => _i11.CareerRepositoryImpl());
    gh.lazySingleton<_i18.CreativityRepository>(() => _i12.CreativityRepositoryImpl());
    gh.lazySingleton<_i16.AnalyticsRepository>(() => _i10.AnalyticsRepositoryImpl());
    
    // Services
    gh.lazySingleton<_i33.RewardCalculator>(() => _i33.RewardCalculatorImpl());
    gh.lazySingleton<_i26.AchievementEngine>(() => _i26.AchievementEngineImpl());
    gh.lazySingleton<_i28.ALIAssistant>(() => _i28.ALIAssistantImpl());
    gh.lazySingleton<_i31.NotificationService>(() => _i31.NotificationServiceImpl());
    gh.lazySingleton<_i29.BackgroundService>(() => _i29.BackgroundServiceImpl());
    gh.lazySingleton<_i32.ReminderService>(() => _i32.ReminderServiceImpl());
    gh.lazySingleton<_i34.SmartNotificationManager>(() => _i34.SmartNotificationManagerImpl());
    gh.lazySingleton<_i27.AdManager>(() => _i27.AdManagerImpl());
    gh.lazySingleton<_i30.BillingManager>(() => _i30.BillingManagerImpl());
    gh.lazySingleton<_i35.ValidationEngine>(() => _i35.ValidationEngineImpl());
    
    // Use Cases
    gh.lazySingleton<_i25.UserUseCases>(() => _i25.UserUseCases(
      repository: gh<_i21.UserRepository>(),
    ));
    gh.lazySingleton<_i24.TaskUseCases>(() => _i24.TaskUseCases(
      repository: gh<_i20.TaskRepository>(),
    ));
    gh.lazySingleton<_i23.HabitUseCases>(() => _i23.HabitUseCases(
      repository: gh<_i19.HabitRepository>(),
    ));
    gh.lazySingleton<_i22.AchievementUseCases>(() => _i22.AchievementUseCases(
      achievementEngine: gh<_i26.AchievementEngine>(),
    ));
    
    return this;
  }
}
