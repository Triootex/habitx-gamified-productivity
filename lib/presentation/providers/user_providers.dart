import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/user_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) => getIt<RegisterUserUseCase>());
final loginUserUseCaseProvider = Provider<LoginUserUseCase>((ref) => getIt<LoginUserUseCase>());
final logoutUserUseCaseProvider = Provider<LogoutUserUseCase>((ref) => getIt<LogoutUserUseCase>());
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) => getIt<GetCurrentUserUseCase>());
final updateUserUseCaseProvider = Provider<UpdateUserUseCase>((ref) => getIt<UpdateUserUseCase>());
final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>((ref) => getIt<DeleteUserUseCase>());
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) => getIt<ChangePasswordUseCase>());
final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) => getIt<ResetPasswordUseCase>());
final verifyEmailUseCaseProvider = Provider<VerifyEmailUseCase>((ref) => getIt<VerifyEmailUseCase>());
final refreshUserDataUseCaseProvider = Provider<RefreshUserDataUseCase>((ref) => getIt<RefreshUserDataUseCase>());
final getUserAnalyticsUseCaseProvider = Provider<GetUserAnalyticsUseCase>((ref) => getIt<GetUserAnalyticsUseCase>());
final getUserAchievementsUseCaseProvider = Provider<GetUserAchievementsUseCase>((ref) => getIt<GetUserAchievementsUseCase>());
final updateUserPreferencesUseCaseProvider = Provider<UpdateUserPreferencesUseCase>((ref) => getIt<UpdateUserPreferencesUseCase>());
final syncUserDataUseCaseProvider = Provider<SyncUserDataUseCase>((ref) => getIt<SyncUserDataUseCase>());
final exportUserDataUseCaseProvider = Provider<ExportUserDataUseCase>((ref) => getIt<ExportUserDataUseCase>());
final importUserDataUseCaseProvider = Provider<ImportUserDataUseCase>((ref) => getIt<ImportUserDataUseCase>());
final calculateUserLevelUseCaseProvider = Provider<CalculateUserLevelUseCase>((ref) => getIt<CalculateUserLevelUseCase>());
final getUserProfileSummaryUseCaseProvider = Provider<GetUserProfileSummaryUseCase>((ref) => getIt<GetUserProfileSummaryUseCase>());

// Authentication State
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class UserState {
  final UserEntity? user;
  final AuthState authState;
  final Map<String, dynamic>? analytics;
  final List<String> achievements;
  final Map<String, dynamic>? levelData;
  final Map<String, dynamic>? profileSummary;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.authState = AuthState.initial,
    this.analytics,
    this.achievements = const [],
    this.levelData,
    this.profileSummary,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    UserEntity? user,
    AuthState? authState,
    Map<String, dynamic>? analytics,
    List<String>? achievements,
    Map<String, dynamic>? levelData,
    Map<String, dynamic>? profileSummary,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      authState: authState ?? this.authState,
      analytics: analytics ?? this.analytics,
      achievements: achievements ?? this.achievements,
      levelData: levelData ?? this.levelData,
      profileSummary: profileSummary ?? this.profileSummary,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isAuthenticated => authState == AuthState.authenticated && user != null;
  String? get userId => user?.id;
}

// User State Notifier
class UserNotifier extends StateNotifier<UserState> {
  final RegisterUserUseCase registerUserUseCase;
  final LoginUserUseCase loginUserUseCase;
  final LogoutUserUseCase logoutUserUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final RefreshUserDataUseCase refreshUserDataUseCase;
  final GetUserAnalyticsUseCase getUserAnalyticsUseCase;
  final GetUserAchievementsUseCase getUserAchievementsUseCase;
  final UpdateUserPreferencesUseCase updateUserPreferencesUseCase;
  final SyncUserDataUseCase syncUserDataUseCase;
  final ExportUserDataUseCase exportUserDataUseCase;
  final ImportUserDataUseCase importUserDataUseCase;
  final CalculateUserLevelUseCase calculateUserLevelUseCase;
  final GetUserProfileSummaryUseCase getUserProfileSummaryUseCase;

  UserNotifier({
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.logoutUserUseCase,
    required this.getCurrentUserUseCase,
    required this.updateUserUseCase,
    required this.deleteUserUseCase,
    required this.changePasswordUseCase,
    required this.resetPasswordUseCase,
    required this.verifyEmailUseCase,
    required this.refreshUserDataUseCase,
    required this.getUserAnalyticsUseCase,
    required this.getUserAchievementsUseCase,
    required this.updateUserPreferencesUseCase,
    required this.syncUserDataUseCase,
    required this.exportUserDataUseCase,
    required this.importUserDataUseCase,
    required this.calculateUserLevelUseCase,
    required this.getUserProfileSummaryUseCase,
  }) : super(const UserState());

  Future<void> initialize() async {
    state = state.copyWith(authState: AuthState.loading);
    
    final result = await getCurrentUserUseCase(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(
        authState: AuthState.unauthenticated,
        error: failure.toString(),
      ),
      (user) {
        state = state.copyWith(
          user: user,
          authState: AuthState.authenticated,
          error: null,
        );
        _loadUserData();
      },
    );
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    state = state.copyWith(
      authState: AuthState.loading,
      isLoading: true,
      error: null,
    );
    
    final result = await registerUserUseCase(RegisterUserParams(userData: userData));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          authState: AuthState.error,
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          authState: AuthState.authenticated,
          isLoading: false,
          error: null,
        );
        _loadUserData();
        return true;
      },
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(
      authState: AuthState.loading,
      isLoading: true,
      error: null,
    );
    
    final result = await loginUserUseCase(LoginUserParams(
      email: email,
      password: password,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          authState: AuthState.error,
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          authState: AuthState.authenticated,
          isLoading: false,
          error: null,
        );
        _loadUserData();
        return true;
      },
    );
  }

  Future<bool> logout() async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await logoutUserUseCase(state.user!.id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        state = const UserState(authState: AuthState.unauthenticated);
        return success;
      },
    );
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await updateUserUseCase(UpdateUserParams(
      userId: state.user!.id,
      updates: updates,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (updatedUser) {
        state = state.copyWith(
          user: updatedUser,
          isLoading: false,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await changePasswordUseCase(ChangePasswordParams(
      userId: state.user!.id,
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return success;
      },
    );
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true);
    
    final result = await resetPasswordUseCase(email);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return success;
      },
    );
  }

  Future<bool> verifyEmail(String token) async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await verifyEmailUseCase(VerifyEmailParams(
      userId: state.user!.id,
      token: token,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        if (success) {
          refreshUser();
        }
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        return success;
      },
    );
  }

  Future<void> refreshUser() async {
    if (state.user == null) return;
    
    final result = await refreshUserDataUseCase(state.user!.id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (user) => state = state.copyWith(user: user, error: null),
    );
  }

  Future<void> loadAnalytics() async {
    if (state.user == null) return;
    
    final result = await getUserAnalyticsUseCase(state.user!.id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadAchievements() async {
    if (state.user == null) return;
    
    final result = await getUserAchievementsUseCase(state.user!.id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (achievements) => state = state.copyWith(achievements: achievements),
    );
  }

  Future<void> loadLevelData() async {
    if (state.user == null) return;
    
    final result = await calculateUserLevelUseCase(state.user!.id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (levelData) => state = state.copyWith(levelData: levelData),
    );
  }

  Future<void> loadProfileSummary() async {
    if (state.user == null) return;
    
    final result = await getUserProfileSummaryUseCase(state.user!.id);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (summary) => state = state.copyWith(profileSummary: summary),
    );
  }

  Future<bool> updatePreferences(Map<String, dynamic> preferences) async {
    if (state.user == null) return false;
    
    final result = await updateUserPreferencesUseCase(UpdateUserPreferencesParams(
      userId: state.user!.id,
      preferences: preferences,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return false;
      },
      (success) {
        if (success) {
          refreshUser();
        }
        return success;
      },
    );
  }

  Future<void> syncUserData() async {
    if (state.user == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncUserDataUseCase(state.user!.id);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          refreshUser();
          _loadUserData();
        }
      },
    );
  }

  Future<Map<String, dynamic>?> exportUserData() async {
    if (state.user == null) return null;
    
    final result = await exportUserDataUseCase(state.user!.id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return null;
      },
      (data) => data,
    );
  }

  Future<bool> importUserData(Map<String, dynamic> userData) async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await importUserDataUseCase(ImportUserDataParams(
      userId: state.user!.id,
      userData: userData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          refreshUser();
          _loadUserData();
        }
        return success;
      },
    );
  }

  Future<bool> deleteAccount() async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await deleteUserUseCase(state.user!.id);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (success) {
        state = const UserState(authState: AuthState.unauthenticated);
        return success;
      },
    );
  }

  void _loadUserData() {
    loadAnalytics();
    loadAchievements();
    loadLevelData();
    loadProfileSummary();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// User Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    registerUserUseCase: ref.read(registerUserUseCaseProvider),
    loginUserUseCase: ref.read(loginUserUseCaseProvider),
    logoutUserUseCase: ref.read(logoutUserUseCaseProvider),
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    updateUserUseCase: ref.read(updateUserUseCaseProvider),
    deleteUserUseCase: ref.read(deleteUserUseCaseProvider),
    changePasswordUseCase: ref.read(changePasswordUseCaseProvider),
    resetPasswordUseCase: ref.read(resetPasswordUseCaseProvider),
    verifyEmailUseCase: ref.read(verifyEmailUseCaseProvider),
    refreshUserDataUseCase: ref.read(refreshUserDataUseCaseProvider),
    getUserAnalyticsUseCase: ref.read(getUserAnalyticsUseCaseProvider),
    getUserAchievementsUseCase: ref.read(getUserAchievementsUseCaseProvider),
    updateUserPreferencesUseCase: ref.read(updateUserPreferencesUseCaseProvider),
    syncUserDataUseCase: ref.read(syncUserDataUseCaseProvider),
    exportUserDataUseCase: ref.read(exportUserDataUseCaseProvider),
    importUserDataUseCase: ref.read(importUserDataUseCaseProvider),
    calculateUserLevelUseCase: ref.read(calculateUserLevelUseCaseProvider),
    getUserProfileSummaryUseCase: ref.read(getUserProfileSummaryUseCaseProvider),
  );
});

// Computed Providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  return userState.isAuthenticated;
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final userState = ref.watch(userProvider);
  return userState.user;
});

final userIdProvider = Provider<String?>((ref) {
  final userState = ref.watch(userProvider);
  return userState.userId;
});

final userLevelProvider = Provider<int>((ref) {
  final userState = ref.watch(userProvider);
  return userState.levelData?['current_level'] ?? 1;
});

final userXPProvider = Provider<int>((ref) {
  final userState = ref.watch(userProvider);
  return userState.user?.totalXP ?? 0;
});

final userStreakProvider = Provider<int>((ref) {
  final userState = ref.watch(userProvider);
  return userState.user?.currentStreak ?? 0;
});

final userAchievementCountProvider = Provider<int>((ref) {
  final userState = ref.watch(userProvider);
  return userState.achievements.length;
});

final isEmailVerifiedProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  return userState.user?.isEmailVerified ?? false;
});

// Auth Guard Provider
final authGuardProvider = Provider<bool>((ref) {
  final userState = ref.watch(userProvider);
  
  // Initialize user if not done yet
  if (userState.authState == AuthState.initial) {
    Future.microtask(() => ref.read(userProvider.notifier).initialize());
    return false;
  }
  
  return userState.isAuthenticated;
});
