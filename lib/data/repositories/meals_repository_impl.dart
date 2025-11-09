import 'package:injectable/injectable.dart';
import '../../domain/entities/meals_entity.dart';
import '../datasources/local/meals_local_data_source.dart';
import '../datasources/remote/meals_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class MealsRepository {
  Future<Either<Failure, MealPlanEntity>> createMealPlan(String userId, Map<String, dynamic> planData);
  Future<Either<Failure, MealEntity>> addMeal(String userId, Map<String, dynamic> mealData);
  Future<Either<Failure, RecipeEntity>> createRecipe(String userId, Map<String, dynamic> recipeData);
  Future<Either<Failure, GroceryListEntity>> generateGroceryList(String userId, List<String> mealPlanIds);
  Future<Either<Failure, List<MealPlanEntity>>> getUserMealPlans(String userId);
  Future<Either<Failure, List<RecipeEntity>>> getUserRecipes(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getMealAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, Map<String, dynamic>>> scanBarcode(String barcode);
  Future<Either<Failure, List<RecipeEntity>>> searchRecipes(String query, Map<String, dynamic> filters);
  Future<Either<Failure, Map<String, dynamic>>> calculateNutritionalBalance(String userId, DateTime date);
  Future<Either<Failure, List<String>>> generateAIMealPlan(String userId, Map<String, dynamic> preferences);
  Future<Either<Failure, bool>> syncMealsData(String userId);
}

@LazySingleton(as: MealsRepository)
class MealsRepositoryImpl implements MealsRepository {
  final MealsLocalDataSource localDataSource;
  final MealsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MealsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MealPlanEntity>> createMealPlan(String userId, Map<String, dynamic> planData) async {
    try {
      // Create meal plan locally first for offline support
      final localPlan = await localDataSource.createMealPlan(userId, planData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remotePlan = await remoteDataSource.createMealPlan(userId, planData);
          // Update local with server ID and sync status
          await localDataSource.updateMealPlan(localPlan.id, {
            'server_id': remotePlan.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remotePlan);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateMealPlan(localPlan.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localPlan);
        }
      }
      
      return Right(localPlan);
    } on CacheException {
      return Left(CacheFailure('Failed to create meal plan locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create meal plan on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MealEntity>> addMeal(String userId, Map<String, dynamic> mealData) async {
    try {
      // Add meal locally first
      final localMeal = await localDataSource.addMeal(userId, mealData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteMeal = await remoteDataSource.addMeal(userId, mealData);
          // Update local with server ID and sync status
          await localDataSource.updateMeal(localMeal.id, {
            'server_id': remoteMeal.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteMeal);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateMeal(localMeal.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localMeal);
        }
      }
      
      return Right(localMeal);
    } on CacheException {
      return Left(CacheFailure('Failed to add meal locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to add meal on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity>> createRecipe(String userId, Map<String, dynamic> recipeData) async {
    try {
      // Create recipe locally first
      final localRecipe = await localDataSource.createRecipe(userId, recipeData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteRecipe = await remoteDataSource.createRecipe(userId, recipeData);
          // Update local with server ID and sync status
          await localDataSource.updateRecipe(localRecipe.id, {
            'server_id': remoteRecipe.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteRecipe);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateRecipe(localRecipe.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localRecipe);
        }
      }
      
      return Right(localRecipe);
    } on CacheException {
      return Left(CacheFailure('Failed to create recipe locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create recipe on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, GroceryListEntity>> generateGroceryList(String userId, List<String> mealPlanIds) async {
    try {
      // Generate grocery list locally first
      final localList = await localDataSource.generateGroceryList(userId, mealPlanIds);
      
      if (await networkInfo.isConnected) {
        try {
          // Enhance with remote data (prices, store locations, etc.)
          final remoteList = await remoteDataSource.generateGroceryList(userId, mealPlanIds);
          // Update local cache with enhanced data
          await localDataSource.cacheGroceryList(remoteList);
          return Right(remoteList);
        } catch (e) {
          // Return local list if remote fails
          return Right(localList);
        }
      }
      
      return Right(localList);
    } on CacheException {
      return Left(CacheFailure('Failed to generate grocery list locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MealPlanEntity>>> getUserMealPlans(String userId) async {
    try {
      // Always return local meal plans first for immediate UI response
      List<MealPlanEntity> localPlans = [];
      
      try {
        localPlans = await localDataSource.getUserMealPlans(userId);
      } on CacheException {
        // No local plans, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remotePlans = await remoteDataSource.getUserMealPlans(userId);
          
          // Update local cache with remote data
          await localDataSource.cacheMealPlans(remotePlans);
          
          return Right(remotePlans);
        } catch (e) {
          // Return local plans if remote fails
          if (localPlans.isNotEmpty) {
            return Right(localPlans);
          } else {
            return Left(ServerFailure('Failed to fetch meal plans and no local cache available'));
          }
        }
      }
      
      return Right(localPlans);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> getUserRecipes(String userId) async {
    try {
      List<RecipeEntity> localRecipes = [];
      
      try {
        localRecipes = await localDataSource.getUserRecipes(userId);
      } on CacheException {
        // No local recipes
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteRecipes = await remoteDataSource.getUserRecipes(userId);
          await localDataSource.cacheRecipes(remoteRecipes);
          return Right(remoteRecipes);
        } catch (e) {
          if (localRecipes.isNotEmpty) {
            return Right(localRecipes);
          } else {
            return Left(ServerFailure('Failed to fetch recipes'));
          }
        }
      }
      
      return Right(localRecipes);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMealAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getMealAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheMealAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getMealAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getMealAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> scanBarcode(String barcode) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteResult = await remoteDataSource.scanBarcode(barcode);
          // Cache barcode scan result locally
          await localDataSource.cacheBarcodeResult(barcode, remoteResult);
          return Right(remoteResult);
        } catch (e) {
          // Fall back to local barcode cache
          try {
            final localResult = await localDataSource.getBarcodeResult(barcode);
            return Right(localResult);
          } on CacheException {
            return Left(ServerFailure('Failed to scan barcode and no cached data available'));
          }
        }
      } else {
        // Offline - check local barcode cache
        try {
          final localResult = await localDataSource.getBarcodeResult(barcode);
          return Right(localResult);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no cached barcode data available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<RecipeEntity>>> searchRecipes(String query, Map<String, dynamic> filters) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteResults = await remoteDataSource.searchRecipes(query, filters);
          // Cache search results locally
          await localDataSource.cacheRecipeSearchResults(query, filters, remoteResults);
          return Right(remoteResults);
        } catch (e) {
          // Fall back to local search
          try {
            final localResults = await localDataSource.searchRecipes(query, filters);
            return Right(localResults);
          } on CacheException {
            return Left(ServerFailure('Failed to search recipes and no local search capability available'));
          }
        }
      } else {
        // Offline - use local search
        final localResults = await localDataSource.searchRecipes(query, filters);
        return Right(localResults);
      }
    } on CacheException {
      return Left(CacheFailure('No recipe search capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> calculateNutritionalBalance(String userId, DateTime date) async {
    try {
      // Calculate nutritional balance locally first
      final localBalance = await localDataSource.calculateNutritionalBalance(userId, date);
      
      if (await networkInfo.isConnected) {
        try {
          // Get enhanced nutritional analysis from remote
          final remoteBalance = await remoteDataSource.calculateNutritionalBalance(userId, date);
          // Cache enhanced analysis locally
          await localDataSource.cacheNutritionalBalance(userId, date, remoteBalance);
          return Right(remoteBalance);
        } catch (e) {
          // Return local balance if remote fails
          return Right(localBalance);
        }
      }
      
      return Right(localBalance);
    } on CacheException {
      return Left(CacheFailure('Cannot calculate nutritional balance locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> generateAIMealPlan(String userId, Map<String, dynamic> preferences) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteMealPlan = await remoteDataSource.generateAIMealPlan(userId, preferences);
          // Cache AI-generated meal plan locally
          await localDataSource.cacheAIMealPlan(userId, preferences, remoteMealPlan);
          return Right(remoteMealPlan);
        } catch (e) {
          // Fall back to local AI generation if available
          try {
            final localMealPlan = await localDataSource.generateAIMealPlan(userId, preferences);
            return Right(localMealPlan);
          } on CacheException {
            return Left(ServerFailure('Failed to generate AI meal plan and no local capability available'));
          }
        }
      } else {
        // Offline - use local AI generation if available
        try {
          final localMealPlan = await localDataSource.generateAIMealPlan(userId, preferences);
          return Right(localMealPlan);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no local AI meal planning available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncMealsData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get meals data that needs sync
      final unsyncedPlans = await localDataSource.getUnsyncedMealPlans(userId);
      final unsyncedMeals = await localDataSource.getUnsyncedMeals(userId);
      final unsyncedRecipes = await localDataSource.getUnsyncedRecipes(userId);

      // Sync meal plans
      for (final plan in unsyncedPlans) {
        try {
          if (plan.serverId == null) {
            // Create on server
            final remotePlan = await remoteDataSource.createMealPlan(userId, plan.toJson());
            await localDataSource.updateMealPlan(plan.id, {
              'server_id': remotePlan.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateMealPlan(plan.serverId!, plan.toJson());
            await localDataSource.updateMealPlan(plan.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync meals
      for (final meal in unsyncedMeals) {
        try {
          if (meal.serverId == null) {
            final remoteMeal = await remoteDataSource.addMeal(userId, meal.toJson());
            await localDataSource.updateMeal(meal.id, {
              'server_id': remoteMeal.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync recipes
      for (final recipe in unsyncedRecipes) {
        try {
          if (recipe.serverId == null) {
            final remoteRecipe = await remoteDataSource.createRecipe(userId, recipe.toJson());
            await localDataSource.updateRecipe(recipe.id, {
              'server_id': remoteRecipe.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Fetch latest from server and update local cache
      final remotePlans = await remoteDataSource.getUserMealPlans(userId);
      final remoteRecipes = await remoteDataSource.getUserRecipes(userId);
      await localDataSource.cacheMealPlans(remotePlans);
      await localDataSource.cacheRecipes(remoteRecipes);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync meals data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }
}
