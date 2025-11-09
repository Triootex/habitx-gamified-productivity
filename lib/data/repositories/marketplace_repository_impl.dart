import 'package:injectable/injectable.dart';
import '../../domain/entities/marketplace_entity.dart';
import '../datasources/local/marketplace_local_data_source.dart';
import '../datasources/remote/marketplace_remote_data_source.dart';
import '../../core/network/network_info.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<MarketplaceItemEntity>>> getMarketplaceItems({String? category, String? rarity, int? minLevel});
  Future<Either<Failure, MarketplaceItemEntity>> createItem(String userId, Map<String, dynamic> itemData);
  Future<Either<Failure, MarketplaceTransactionEntity>> purchaseItem(String userId, String itemId, String paymentMethod);
  Future<Either<Failure, UserInventoryEntity>> getUserInventory(String userId);
  Future<Either<Failure, bool>> equipItem(String userId, String itemId);
  Future<Either<Failure, List<MarketplaceItemEntity>>> searchItems(String query, Map<String, dynamic> filters);
  Future<Either<Failure, Map<String, dynamic>>> getMarketplaceAnalytics();
  Future<Either<Failure, CreatorProfileEntity>> getCreatorProfile(String creatorId);
  Future<Either<Failure, List<String>>> generateAIItems(String category, String theme, int count);
  Future<Either<Failure, Map<String, dynamic>>> validateItemPurchase(String userId, String itemId);
  Future<Either<Failure, bool>> syncMarketplaceData(String userId);
}

@LazySingleton(as: MarketplaceRepository)
class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceLocalDataSource localDataSource;
  final MarketplaceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MarketplaceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MarketplaceItemEntity>>> getMarketplaceItems({String? category, String? rarity, int? minLevel}) async {
    try {
      List<MarketplaceItemEntity> localItems = [];
      
      try {
        localItems = await localDataSource.getMarketplaceItems(category: category, rarity: rarity, minLevel: minLevel);
      } on CacheException {
        // No local items
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteItems = await remoteDataSource.getMarketplaceItems(category: category, rarity: rarity, minLevel: minLevel);
          // Update local cache with remote data
          await localDataSource.cacheMarketplaceItems(remoteItems);
          return Right(remoteItems);
        } catch (e) {
          if (localItems.isNotEmpty) {
            return Right(localItems);
          } else {
            return Left(ServerFailure('Failed to fetch marketplace items and no local cache available'));
          }
        }
      }
      
      return Right(localItems);
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MarketplaceItemEntity>> createItem(String userId, Map<String, dynamic> itemData) async {
    try {
      // Create item locally first for offline creation
      final localItem = await localDataSource.createItem(userId, itemData);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          final remoteItem = await remoteDataSource.createItem(userId, itemData);
          // Update local with server ID and sync status
          await localDataSource.updateItem(localItem.id, {
            'server_id': remoteItem.id,
            'is_synced': true,
            'last_synced': DateTime.now().toIso8601String(),
          });
          return Right(remoteItem);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.updateItem(localItem.id, {
            'is_synced': false,
            'needs_sync': true,
          });
          return Right(localItem);
        }
      }
      
      return Right(localItem);
    } on CacheException {
      return Left(CacheFailure('Failed to create item locally'));
    } on ServerException {
      return Left(ServerFailure('Failed to create item on server'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MarketplaceTransactionEntity>> purchaseItem(String userId, String itemId, String paymentMethod) async {
    try {
      // Validate purchase first
      final validation = await validateItemPurchase(userId, itemId);
      final validationResult = validation.fold((failure) => null, (result) => result);
      
      if (validationResult == null || !validationResult['can_purchase']) {
        return Left(ValidationFailure(validationResult?['reason'] ?? 'Purchase validation failed'));
      }
      
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('Internet connection required for purchases'));
      }

      // Process purchase on server
      final remoteTransaction = await remoteDataSource.purchaseItem(userId, itemId, paymentMethod);
      
      // Update local inventory and cache transaction
      await localDataSource.addToInventory(userId, itemId);
      await localDataSource.cacheTransaction(remoteTransaction);
      
      return Right(remoteTransaction);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Purchase failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserInventoryEntity>> getUserInventory(String userId) async {
    try {
      UserInventoryEntity? localInventory;
      
      try {
        localInventory = await localDataSource.getUserInventory(userId);
      } on CacheException {
        // No local inventory
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteInventory = await remoteDataSource.getUserInventory(userId);
          // Update local cache with remote data
          await localDataSource.cacheInventory(remoteInventory);
          return Right(remoteInventory);
        } catch (e) {
          if (localInventory != null) {
            return Right(localInventory);
          } else {
            return Left(ServerFailure('Failed to fetch inventory and no local cache available'));
          }
        }
      }
      
      if (localInventory != null) {
        return Right(localInventory);
      } else {
        return Left(CacheFailure('No inventory data available'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> equipItem(String userId, String itemId) async {
    try {
      // Equip item locally first for immediate UI response
      await localDataSource.equipItem(userId, itemId);
      
      if (await networkInfo.isConnected) {
        try {
          // Sync to remote
          await remoteDataSource.equipItem(userId, itemId);
        } catch (e) {
          // Mark for later sync if remote fails
          await localDataSource.markEquipForSync(userId, itemId);
        }
      } else {
        // Mark for sync when back online
        await localDataSource.markEquipForSync(userId, itemId);
      }
      
      return const Right(true);
    } on CacheException {
      return Left(CacheFailure('Failed to equip item locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<MarketplaceItemEntity>>> searchItems(String query, Map<String, dynamic> filters) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteResults = await remoteDataSource.searchItems(query, filters);
          // Cache search results locally
          await localDataSource.cacheSearchResults(query, filters, remoteResults);
          return Right(remoteResults);
        } catch (e) {
          // Fall back to local search
          try {
            final localResults = await localDataSource.searchItems(query, filters);
            return Right(localResults);
          } on CacheException {
            return Left(ServerFailure('Failed to search items and no local search capability available'));
          }
        }
      } else {
        // Offline - use local search
        final localResults = await localDataSource.searchItems(query, filters);
        return Right(localResults);
      }
    } on CacheException {
      return Left(CacheFailure('No item search capability available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMarketplaceAnalytics() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteAnalytics = await remoteDataSource.getMarketplaceAnalytics();
          // Cache analytics locally
          await localDataSource.cacheMarketplaceAnalytics(remoteAnalytics);
          return Right(remoteAnalytics);
        } catch (e) {
          // Fall back to local analytics
          try {
            final localAnalytics = await localDataSource.getMarketplaceAnalytics();
            return Right(localAnalytics);
          } on CacheException {
            return Left(ServerFailure('Failed to fetch analytics and no local cache available'));
          }
        }
      } else {
        // Offline - use local analytics
        final localAnalytics = await localDataSource.getMarketplaceAnalytics();
        return Right(localAnalytics);
      }
    } on CacheException {
      return Left(CacheFailure('No analytics data available locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CreatorProfileEntity>> getCreatorProfile(String creatorId) async {
    try {
      CreatorProfileEntity? localProfile;
      
      try {
        localProfile = await localDataSource.getCreatorProfile(creatorId);
      } on CacheException {
        // No local profile
      }
      
      if (await networkInfo.isConnected) {
        try {
          final remoteProfile = await remoteDataSource.getCreatorProfile(creatorId);
          // Update local cache
          await localDataSource.cacheCreatorProfile(remoteProfile);
          return Right(remoteProfile);
        } catch (e) {
          if (localProfile != null) {
            return Right(localProfile);
          } else {
            return Left(ServerFailure('Failed to fetch creator profile'));
          }
        }
      }
      
      if (localProfile != null) {
        return Right(localProfile);
      } else {
        return Left(CacheFailure('Creator profile not found'));
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> generateAIItems(String category, String theme, int count) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remoteItems = await remoteDataSource.generateAIItems(category, theme, count);
          // Cache AI-generated items locally
          await localDataSource.cacheAIItems(category, theme, count, remoteItems);
          return Right(remoteItems);
        } catch (e) {
          // Fall back to local AI generation if available
          try {
            final localItems = await localDataSource.generateAIItems(category, theme, count);
            return Right(localItems);
          } on CacheException {
            return Left(ServerFailure('Failed to generate AI items and no local capability available'));
          }
        }
      } else {
        // Offline - use local AI generation if available
        try {
          final localItems = await localDataSource.generateAIItems(category, theme, count);
          return Right(localItems);
        } on CacheException {
          return Left(NetworkFailure('No internet connection and no local AI generation available'));
        }
      }
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validateItemPurchase(String userId, String itemId) async {
    try {
      // Validate locally first for immediate feedback
      final localValidation = await localDataSource.validateItemPurchase(userId, itemId);
      
      if (!localValidation['can_purchase']) {
        return Right(localValidation);
      }
      
      if (await networkInfo.isConnected) {
        try {
          // Get server-side validation for currency balance and item availability
          final remoteValidation = await remoteDataSource.validateItemPurchase(userId, itemId);
          return Right(remoteValidation);
        } catch (e) {
          // Return local validation if remote fails
          return Right(localValidation);
        }
      }
      
      return Right(localValidation);
    } on CacheException {
      return Left(CacheFailure('Cannot validate purchase locally'));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> syncMarketplaceData(String userId) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection for sync'));
      }

      // Get marketplace data that needs sync
      final unsyncedItems = await localDataSource.getUnsyncedItems(userId);
      final unsyncedEquips = await localDataSource.getUnsyncedEquips(userId);

      // Sync created items
      for (final item in unsyncedItems) {
        try {
          if (item.serverId == null) {
            // Create on server
            final remoteItem = await remoteDataSource.createItem(userId, item.toJson());
            await localDataSource.updateItem(item.id, {
              'server_id': remoteItem.id,
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          } else {
            // Update on server
            await remoteDataSource.updateItem(item.serverId!, item.toJson());
            await localDataSource.updateItem(item.id, {
              'is_synced': true,
              'needs_sync': false,
              'last_synced': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          continue;
        }
      }

      // Sync equipment changes
      for (final equipData in unsyncedEquips) {
        try {
          await remoteDataSource.equipItem(equipData['user_id'], equipData['item_id']);
          await localDataSource.markEquipSynced(equipData['id']);
        } catch (e) {
          continue;
        }
      }

      // Fetch latest marketplace items and inventory
      final remoteItems = await remoteDataSource.getMarketplaceItems();
      final remoteInventory = await remoteDataSource.getUserInventory(userId);
      await localDataSource.cacheMarketplaceItems(remoteItems);
      await localDataSource.cacheInventory(remoteInventory);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure('Failed to sync marketplace data with server'));
    } catch (e) {
      return Left(UnexpectedFailure('Sync failed: ${e.toString()}'));
    }
  }
}
