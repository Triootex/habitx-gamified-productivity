import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../entities/marketplace_entity.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';

// Get Marketplace Items Use Case
@injectable
class GetMarketplaceItemsUseCase implements UseCase<List<MarketplaceItemEntity>, GetMarketplaceItemsParams> {
  final MarketplaceRepository repository;

  GetMarketplaceItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MarketplaceItemEntity>>> call(GetMarketplaceItemsParams params) async {
    return await repository.getMarketplaceItems(
      category: params.category,
      rarity: params.rarity,
      minLevel: params.minLevel,
    );
  }
}

class GetMarketplaceItemsParams {
  final String? category;
  final String? rarity;
  final int? minLevel;

  GetMarketplaceItemsParams({this.category, this.rarity, this.minLevel});
}

// Create Marketplace Item Use Case
@injectable
class CreateMarketplaceItemUseCase implements UseCase<MarketplaceItemEntity, CreateMarketplaceItemParams> {
  final MarketplaceRepository repository;

  CreateMarketplaceItemUseCase(this.repository);

  @override
  Future<Either<Failure, MarketplaceItemEntity>> call(CreateMarketplaceItemParams params) async {
    return await repository.createItem(params.userId, params.itemData);
  }
}

class CreateMarketplaceItemParams {
  final String userId;
  final Map<String, dynamic> itemData;

  CreateMarketplaceItemParams({required this.userId, required this.itemData});
}

// Purchase Item Use Case
@injectable
class PurchaseItemUseCase implements UseCase<MarketplaceTransactionEntity, PurchaseItemParams> {
  final MarketplaceRepository repository;

  PurchaseItemUseCase(this.repository);

  @override
  Future<Either<Failure, MarketplaceTransactionEntity>> call(PurchaseItemParams params) async {
    return await repository.purchaseItem(params.userId, params.itemId, params.paymentMethod);
  }
}

class PurchaseItemParams {
  final String userId;
  final String itemId;
  final String paymentMethod;

  PurchaseItemParams({
    required this.userId,
    required this.itemId,
    required this.paymentMethod,
  });
}

// Get User Inventory Use Case
@injectable
class GetUserInventoryUseCase implements UseCase<UserInventoryEntity, String> {
  final MarketplaceRepository repository;

  GetUserInventoryUseCase(this.repository);

  @override
  Future<Either<Failure, UserInventoryEntity>> call(String userId) async {
    return await repository.getUserInventory(userId);
  }
}

// Equip Item Use Case
@injectable
class EquipItemUseCase implements UseCase<bool, EquipItemParams> {
  final MarketplaceRepository repository;

  EquipItemUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(EquipItemParams params) async {
    return await repository.equipItem(params.userId, params.itemId);
  }
}

class EquipItemParams {
  final String userId;
  final String itemId;

  EquipItemParams({required this.userId, required this.itemId});
}

// Search Marketplace Items Use Case
@injectable
class SearchMarketplaceItemsUseCase implements UseCase<List<MarketplaceItemEntity>, SearchMarketplaceItemsParams> {
  final MarketplaceRepository repository;

  SearchMarketplaceItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MarketplaceItemEntity>>> call(SearchMarketplaceItemsParams params) async {
    return await repository.searchItems(params.query, params.filters);
  }
}

class SearchMarketplaceItemsParams {
  final String query;
  final Map<String, dynamic> filters;

  SearchMarketplaceItemsParams({required this.query, required this.filters});
}

// Get Marketplace Analytics Use Case
@injectable
class GetMarketplaceAnalyticsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final MarketplaceRepository repository;

  GetMarketplaceAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getMarketplaceAnalytics();
  }
}

// Get Creator Profile Use Case
@injectable
class GetCreatorProfileUseCase implements UseCase<CreatorProfileEntity, String> {
  final MarketplaceRepository repository;

  GetCreatorProfileUseCase(this.repository);

  @override
  Future<Either<Failure, CreatorProfileEntity>> call(String creatorId) async {
    return await repository.getCreatorProfile(creatorId);
  }
}

// Generate AI Items Use Case
@injectable
class GenerateAIItemsUseCase implements UseCase<List<String>, GenerateAIItemsParams> {
  final MarketplaceRepository repository;

  GenerateAIItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(GenerateAIItemsParams params) async {
    return await repository.generateAIItems(params.category, params.theme, params.count);
  }
}

class GenerateAIItemsParams {
  final String category;
  final String theme;
  final int count;

  GenerateAIItemsParams({
    required this.category,
    required this.theme,
    required this.count,
  });
}

// Validate Item Purchase Use Case
@injectable
class ValidateItemPurchaseUseCase implements UseCase<Map<String, dynamic>, ValidateItemPurchaseParams> {
  final MarketplaceRepository repository;

  ValidateItemPurchaseUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(ValidateItemPurchaseParams params) async {
    return await repository.validateItemPurchase(params.userId, params.itemId);
  }
}

class ValidateItemPurchaseParams {
  final String userId;
  final String itemId;

  ValidateItemPurchaseParams({required this.userId, required this.itemId});
}

// Sync Marketplace Data Use Case
@injectable
class SyncMarketplaceDataUseCase implements UseCase<bool, String> {
  final MarketplaceRepository repository;

  SyncMarketplaceDataUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String userId) async {
    return await repository.syncMarketplaceData(userId);
  }
}

// Calculate Item Value Use Case
@injectable
class CalculateItemValueUseCase implements UseCase<Map<String, dynamic>, String> {
  final MarketplaceRepository repository;

  CalculateItemValueUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    try {
      final inventoryResult = await repository.getUserInventory(userId);
      
      return inventoryResult.fold(
        (failure) => Left(failure),
        (inventory) {
          final valueData = _calculateItemValue(inventory);
          return Right(valueData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to calculate item value: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _calculateItemValue(UserInventoryEntity inventory) {
    if (inventory.items.isEmpty) {
      return {
        'total_value': 0,
        'item_count': 0,
        'rarity_distribution': {},
        'most_valuable_item': null,
        'investment_return': 0.0,
        'recommendations': [
          'Start collecting items to build your inventory value',
          'Look for limited edition items for better investment potential'
        ],
      };
    }
    
    var totalValue = 0.0;
    final rarityCount = <String, int>{};
    final rarityValue = <String, double>{};
    
    MarketplaceItemEntity? mostValuableItem;
    double highestValue = 0.0;
    
    for (final item in inventory.items) {
      final value = item.currentPrice ?? item.originalPrice ?? 0.0;
      totalValue += value;
      
      // Track rarity distribution
      final rarity = item.rarity ?? 'common';
      rarityCount[rarity] = (rarityCount[rarity] ?? 0) + 1;
      rarityValue[rarity] = (rarityValue[rarity] ?? 0) + value;
      
      // Find most valuable item
      if (value > highestValue) {
        highestValue = value;
        mostValuableItem = item;
      }
    }
    
    // Calculate investment return (simplified)
    final originalValue = inventory.items.fold<double>(0, (sum, item) => sum + (item.originalPrice ?? 0));
    final investmentReturn = originalValue > 0 ? ((totalValue - originalValue) / originalValue) * 100 : 0.0;
    
    // Generate recommendations
    final recommendations = _generateValueRecommendations(
      inventory.items, rarityCount, investmentReturn
    );
    
    return {
      'total_value': totalValue.round(),
      'item_count': inventory.items.length,
      'average_item_value': inventory.items.isNotEmpty ? (totalValue / inventory.items.length).round() : 0,
      'rarity_distribution': rarityCount,
      'rarity_values': rarityValue.map((key, value) => MapEntry(key, value.round())),
      'most_valuable_item': mostValuableItem != null ? {
        'id': mostValuableItem.id,
        'name': mostValuableItem.name,
        'value': (mostValuableItem.currentPrice ?? mostValuableItem.originalPrice ?? 0).round(),
        'rarity': mostValuableItem.rarity,
      } : null,
      'investment_return': double.parse(investmentReturn.toStringAsFixed(1)),
      'recommendations': recommendations,
    };
  }

  List<String> _generateValueRecommendations(
    List<MarketplaceItemEntity> items,
    Map<String, int> rarityCount,
    double investmentReturn,
  ) {
    final recommendations = <String>[];
    
    // Check rarity distribution
    final legendaryCount = rarityCount['legendary'] ?? 0;
    final epicCount = rarityCount['epic'] ?? 0;
    
    if (legendaryCount == 0 && items.length > 5) {
      recommendations.add('Consider investing in legendary items for higher value potential');
    }
    
    if (epicCount < items.length * 0.2) {
      recommendations.add('Add more epic items to improve your collection\'s value');
    }
    
    // Investment performance
    if (investmentReturn > 20) {
      recommendations.add('Great investment performance! Keep an eye on market trends');
    } else if (investmentReturn < -10) {
      recommendations.add('Some items may have decreased in value - consider diversifying');
    }
    
    recommendations.addAll([
      'Monitor market trends to buy low and sell high',
      'Limited edition items often appreciate over time',
      'Consider the utility vs collectible value of items',
    ]);
    
    return recommendations.take(4).toList();
  }
}

// Get Trending Items Use Case
@injectable
class GetTrendingItemsUseCase implements UseCase<Map<String, dynamic>, NoParams> {
  final MarketplaceRepository repository;

  GetTrendingItemsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    try {
      final itemsResult = await repository.getMarketplaceItems();
      
      return itemsResult.fold(
        (failure) => Left(failure),
        (items) {
          final trendingData = _analyzeTrendingItems(items);
          return Right(trendingData);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get trending items: ${e.toString()}'));
    }
  }

  Map<String, dynamic> _analyzeTrendingItems(List<MarketplaceItemEntity> items) {
    if (items.isEmpty) {
      return {
        'trending_items': [],
        'price_gainers': [],
        'popular_categories': [],
        'market_insights': ['No items available for trend analysis'],
      };
    }
    
    // Sort by popularity (views, purchases, ratings)
    final popularItems = items.where((item) => 
        (item.totalViews ?? 0) > 0 || (item.totalPurchases ?? 0) > 0
    ).toList();
    
    popularItems.sort((a, b) {
      final aPopularity = (a.totalViews ?? 0) + (a.totalPurchases ?? 0) * 10 + (a.averageRating ?? 0) * 5;
      final bPopularity = (b.totalViews ?? 0) + (b.totalPurchases ?? 0) * 10 + (b.averageRating ?? 0) * 5;
      return bPopularity.compareTo(aPopularity);
    });
    
    // Find price gainers (items with significant price increases)
    final priceGainers = items.where((item) {
      final original = item.originalPrice ?? 0;
      final current = item.currentPrice ?? original;
      return original > 0 && (current - original) / original > 0.2; // 20% increase
    }).toList();
    
    priceGainers.sort((a, b) {
      final aGain = ((a.currentPrice ?? 0) - (a.originalPrice ?? 0)) / (a.originalPrice ?? 1);
      final bGain = ((b.currentPrice ?? 0) - (b.originalPrice ?? 0)) / (b.originalPrice ?? 1);
      return bGain.compareTo(aGain);
    });
    
    // Analyze popular categories
    final categoryPopularity = <String, int>{};
    for (final item in items) {
      final category = item.category ?? 'other';
      categoryPopularity[category] = (categoryPopularity[category] ?? 0) + (item.totalPurchases ?? 0);
    }
    
    final popularCategories = categoryPopularity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Generate market insights
    final insights = _generateMarketInsights(items, popularItems, priceGainers);
    
    return {
      'trending_items': popularItems.take(10).map((item) => {
        'id': item.id,
        'name': item.name,
        'category': item.category,
        'price': item.currentPrice ?? item.originalPrice,
        'rarity': item.rarity,
        'popularity_score': (item.totalViews ?? 0) + (item.totalPurchases ?? 0) * 10,
      }).toList(),
      'price_gainers': priceGainers.take(5).map((item) => {
        'id': item.id,
        'name': item.name,
        'original_price': item.originalPrice,
        'current_price': item.currentPrice,
        'price_change_percent': item.originalPrice! > 0 
            ? (((item.currentPrice ?? 0) - item.originalPrice!) / item.originalPrice! * 100).round()
            : 0,
      }).toList(),
      'popular_categories': popularCategories.take(5).map((entry) => {
        'category': entry.key,
        'total_purchases': entry.value,
      }).toList(),
      'market_insights': insights,
    };
  }

  List<String> _generateMarketInsights(
    List<MarketplaceItemEntity> allItems,
    List<MarketplaceItemEntity> popularItems,
    List<MarketplaceItemEntity> priceGainers,
  ) {
    final insights = <String>[];
    
    if (popularItems.isNotEmpty) {
      final topItem = popularItems.first;
      insights.add('${topItem.name} is currently the most popular item in the marketplace');
    }
    
    if (priceGainers.isNotEmpty) {
      insights.add('${priceGainers.length} items have gained significant value recently');
    }
    
    // Analyze rarity trends
    final rarityCount = <String, int>{};
    for (final item in allItems) {
      final rarity = item.rarity ?? 'common';
      rarityCount[rarity] = (rarityCount[rarity] ?? 0) + 1;
    }
    
    final rareItems = (rarityCount['legendary'] ?? 0) + (rarityCount['epic'] ?? 0);
    final totalItems = allItems.length;
    
    if (rareItems > 0 && totalItems > 0) {
      final rarePercentage = (rareItems / totalItems * 100).round();
      insights.add('$rarePercentage% of marketplace items are epic or legendary rarity');
    }
    
    insights.add('Consider investing in trending categories for better returns');
    
    return insights;
  }
}
