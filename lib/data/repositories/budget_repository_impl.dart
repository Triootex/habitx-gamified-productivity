import 'package:injectable/injectable.dart';
import '../../domain/entities/budget_entity.dart';
import '../datasources/local/budget_local_data_source.dart';
import '../datasources/remote/budget_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class BudgetRepository {
  Future<Either<Failure, BudgetEntity>> createBudget(String userId, Map<String, dynamic> budgetData);
  Future<Either<Failure, TransactionEntity>> addTransaction(String userId, Map<String, dynamic> transactionData);
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions(String userId, {DateTime? startDate, DateTime? endDate});
  Future<Either<Failure, List<BudgetEntity>>> getUserBudgets(String userId);
  Future<Either<Failure, FinancialGoalEntity>> createGoal(String userId, Map<String, dynamic> goalData);
  Future<Either<Failure, List<FinancialGoalEntity>>> getUserGoals(String userId);
  Future<Either<Failure, Map<String, dynamic>>> getBudgetAnalytics(String userId, DateTime? startDate, DateTime? endDate);
  Future<Either<Failure, Map<String, dynamic>>> categorizeTransaction(String description, double amount);
  Future<Either<Failure, List<String>>> generateGroceryList(String userId, List<String> mealPlanIds);
  Future<Either<Failure, Map<String, dynamic>>> calculateNetWorth(String userId);
  Future<Either<Failure, bool>> syncBudgetData(String userId);
  Future<Either<Failure, bool>> syncWithBankAccounts(String userId);
}

@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;
  final BudgetRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BudgetRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BudgetEntity>> createBudget(String userId, Map<String, dynamic> budgetData) async {
    try {
      // Create budget locally first for offline support
      final localBudget = await localDataSource.createBudget(userId, budgetData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteBudget = await remoteDataSource.createBudget(userId, budgetData);
          // Update local with server ID and sync status
          await localDataSource.updateBudget(localBudget.id, {
            'server_id': remoteBudget.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteBudget);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateBudget(localBudget.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localBudget);
        }
      }
      
      return Right(localBudget);
    } on CacheException {
      return Left(CacheFailure('Failed to create budget locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create budget on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction(String userId, Map<String, dynamic> transactionData) async {
    try {
      // Add transaction locally first
      final localTransaction = await localDataSource.addTransaction(userId, transactionData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteTransaction = await remoteDataSource.addTransaction(userId, transactionData);
          // Update local with server ID and sync status
          await localDataSource.updateTransaction(localTransaction.id, {
            'server_id': remoteTransaction.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteTransaction);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateTransaction(localTransaction.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localTransaction);
        }
      }
      
      return Right(localTransaction);
    } on CacheException {
      return Left(CacheFailure('Failed to add transaction locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to add transaction on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      // Always return local transactions first for immediate UI response
      List<TransactionEntity> localTransactions = [];
      
      try {
        localTransactions = await localDataSource.getUserTransactions(userId, startDate: startDate, endDate: endDate);
      } on CacheException {
        // No local transactions, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteTransactions = await remoteDataSource.getUserTransactions(userId, startDate: startDate, endDate: endDate);
          
          // Update local cache with remote data
          await localDataSource.cacheTransactions(remoteTransactions);
          
          return Right(remoteTransactions);
        } catch (e) {
          // Return local transactions if remote fails
          if (localTransactions.isNotEmpty) {
            return Right(localTransactions);
          } else {
            return Left(ServerFailure('Failed to fetch transactions and no local cache available'));
          }
        }
      }
      
      return Right(localTransactions);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getUserBudgets(String userId) async {
    try {
      // Always return local budgets first for immediate UI response
      List<BudgetEntity> localBudgets = [];
      
      try {
        localBudgets = await localDataSource.getUserBudgets(userId);
      } on CacheException {
        // No local budgets, continue to remote
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Fetch from remote and update local cache
          final remoteBudgets = await remoteDataSource.getUserBudgets(userId);
          
          // Update local cache with remote data
          await localDataSource.cacheBudgets(remoteBudgets);
          
          return Right(remoteBudgets);
        } catch (e) {
          // Return local budgets if remote fails
          if (localBudgets.isNotEmpty) {
            return Right(localBudgets);
          } else {
            return Left(ServerFailure('Failed to fetch budgets and no local cache available'));
          }
        }
      }
      
      return Right(localBudgets);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FinancialGoalEntity>> createGoal(String userId, Map<String, dynamic> goalData) async {
    try {
      // Create goal locally first
      final localGoal = await localDataSource.createGoal(userId, goalData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteGoal = await remoteDataSource.createGoal(userId, goalData);
          // Update local with server ID and sync status
          await localDataSource.updateGoal(localGoal.id, {
            'server_id': remoteGoal.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteGoal);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateGoal(localGoal.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localGoal);
        }
      }
      
      return Right(localGoal);
    } on CacheException {
      return Left(CacheFailure('Failed to create goal locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create goal on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<FinancialGoalEntity>>> getUserGoals(String userId) async {
    try {
      List<FinancialGoalEntity> localGoals = [];
      
      try {
        localGoals = await localDataSource.getUserGoals(userId);
      } on CacheException {
        // No local goals
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteGoals = await remoteDataSource.getUserGoals(userId);
          await localDataSource.cacheGoals(remoteGoals);
          return Right(remoteGoals);
        } catch (e) {
          if (localGoals.isNotEmpty) {
            return Right(localGoals);
          } else {
            return Left(ServerFailure('Failed to fetch goals'));
          }
        }
      }
      
      return Right(localGoals);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBudgetAnalytics(String userId, DateTime? startDate, DateTime? endDate) async {
    try {
      // Try to get analytics from remote for most accurate data
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getBudgetAnalytics(userId, startDate, endDate);
          // Cache analytics locally
          await localDataSource.cacheBudgetAnalytics(userId, remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getBudgetAnalytics(userId, startDate, endDate);
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getBudgetAnalytics(userId, startDate, endDate);
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> categorizeTransaction(String description, double amount) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteCategory = await remoteDataSource.categorizeTransaction(description, amount);
          // Cache categorization for similar transactions
          await localDataSource.cacheCategorization(description, amount, remoteCategory);
          return Right(remoteCategory);
        } catch (e) {
          // Fall back to local categorization
          try {
            final localCategory = await localDataSource.categorizeTransaction(description, amount);
            return Right(localCategory);
          } on CacheException {
            return Left(ServerFailure('Failed to categorize transaction and no local capability available'));
          }
        }
      } else {
        // Offline - use local categorization
        final localCategory = await localDataSource.categorizeTransaction(description, amount);
        return Right(localCategory);
      }
    } on CacheException {
      return Left(CacheFailure('No categorization capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> generateGroceryList(String userId, List<String> mealPlanIds) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteList = await remoteDataSource.generateGroceryList(userId, mealPlanIds);
          // Cache grocery list
          await localDataSource.cacheGroceryList(userId, mealPlanIds, remoteList);
          return Right(remoteList);
        } catch (e) {
          // Fall back to local grocery list generation
          try {
            final localList = await localDataSource.generateGroceryList(userId, mealPlanIds);
            return Right(localList);
          } on CacheException {
            return Left(ServerFailure('Failed to generate grocery list and no local capability available'));
          }
        }
      } else {
        // Offline - use local grocery list generation
        final localList = await localDataSource.generateGroceryList(userId, mealPlanIds);
        return Right(localList);
      }
    } on CacheException {
      return Left(CacheFailure('Cannot generate grocery list locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> calculateNetWorth(String userId) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteNetWorth = await remoteDataSource.calculateNetWorth(userId);
          // Cache net worth calculation
          await localDataSource.cacheNetWorth(userId, remoteNetWorth);
          return Right(remoteNetWorth);
        } catch (e) {
          // Fall back to local net worth calculation
          try {
            final localNetWorth = await localDataSource.calculateNetWorth(userId);
            return Right(localNetWorth);
          } on CacheException {
            return Left(ServerFailure('Failed to calculate net worth and no local data available'));
          }
        }
      } else {
        // Offline - use local net worth calculation
        final localNetWorth = await localDataSource.calculateNetWorth(userId);
        return Right(localNetWorth);
      }
    } on CacheException {
      return Left(CacheFailure('Cannot calculate net worth locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncBudgetData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get budget data that needs sync
      final unsyncedBudgets = await localDataSource.getUnsyncedBudgets(userId);
      final unsyncedTransactions = await localDataSource.getUnsyncedTransactions(userId);
      final unsyncedGoals = await localDataSource.getUnsyncedGoals(userId);

      // Sync budgets
      for (final budget in unsyncedBudgets) {
        try {
          if (budget.serverId == null) {
            // Create on server
            final remoteBudget = await remoteDataSource.createBudget(userId, budget.toJson());
            await localDataSource.updateBudget(budget.id, {
              'server_id': remoteBudget.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateBudget(budget.serverId!, budget.toJson());
            await localDataSource.updateBudget(budget.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync transactions
      for (final transaction in unsyncedTransactions) {
        try {
          if (transaction.serverId == null) {
            final remoteTransaction = await remoteDataSource.addTransaction(userId, transaction.toJson());
            await localDataSource.updateTransaction(transaction.id, {
              'server_id': remoteTransaction.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync goals
      for (final goal in unsyncedGoals) {
        try {
          if (goal.serverId == null) {
            final remoteGoal = await remoteDataSource.createGoal(userId, goal.toJson());
            await localDataSource.updateGoal(goal.id, {
              'server_id': remoteGoal.id,
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
      final remoteBudgets = await remoteDataSource.getUserBudgets(userId);
      final remoteTransactions = await remoteDataSource.getUserTransactions(userId);
      await localDataSource.cacheBudgets(remoteBudgets);
      await localDataSource.cacheTransactions(remoteTransactions);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync budget data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncWithBankAccounts(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for bank sync'));
      }

      // Sync with connected bank accounts
      final bankAccounts = await localDataSource.getConnectedBankAccounts(userId);
      
      for (final account in bankAccounts) {
        try {
          // Fetch latest transactions from bank
          final bankTransactions = await remoteDataSource.fetchBankTransactions(account['account_id']);
          
          // Process and store bank transactions
          for (final bankTransaction in bankTransactions) {
            // Check if transaction already exists
            final existingTransaction = await localDataSource.findTransactionByBankId(
              bankTransaction['bank_transaction_id']
            );
            
            if (existingTransaction == null) {
              // Add new transaction from bank
              await localDataSource.addTransaction(userId, {
                ...bankTransaction,
                'source': 'bank_sync',
                'is_verified': true,
              });
            }
          }
          
          // Update last sync timestamp for account
          await localDataSource.updateBankAccountSyncTimestamp(account['account_id'], DateTime.now());
        } catch (e) {
          // Continue with other accounts if one fails
          continue;
        }
      }
      
      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync with bank accounts'));
    } catch (e) {
      return Left(UnexpectedFailure('Bank sync failed: ${e.toString()}'));
    }
  }
}
