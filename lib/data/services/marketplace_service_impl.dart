import 'package:injectable/injectable.dart';
import '../../domain/entities/marketplace_entity.dart';
import '../../core/utils/marketplace_utils.dart';
import '../../core/utils/date_utils.dart';

abstract class MarketplaceService {
  Future<List<MarketplaceItemEntity>> getMarketplaceItems({String? category, String? rarity, int? minLevel});
  Future<MarketplaceItemEntity> createItem(String userId, Map<String, dynamic> itemData);
  Future<MarketplaceTransactionEntity> purchaseItem(String userId, String itemId, String paymentMethod);
  Future<UserInventoryEntity> getUserInventory(String userId);
  Future<bool> equipItem(String userId, String itemId);
  Future<List<MarketplaceItemEntity>> searchItems(String query, Map<String, dynamic> filters);
  Future<Map<String, dynamic>> getMarketplaceAnalytics();
  Future<CreatorProfileEntity> getCreatorProfile(String creatorId);
  Future<List<String>> generateAIItems(String category, String theme, int count);
  Future<Map<String, dynamic>> validateItemPurchase(String userId, String itemId);
}

@LazySingleton(as: MarketplaceService)
class MarketplaceServiceImpl implements MarketplaceService {
  @override
  Future<List<MarketplaceItemEntity>> getMarketplaceItems({String? category, String? rarity, int? minLevel}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final mockItems = _generateMockMarketplaceItems();
      
      List<MarketplaceItemEntity> filteredItems = mockItems;
      
      if (category != null) {
        filteredItems = filteredItems.where((item) => item.category == category).toList();
      }
      
      if (rarity != null) {
        filteredItems = filteredItems.where((item) => item.rarity == rarity).toList();
      }
      
      if (minLevel != null) {
        filteredItems = filteredItems.where((item) => item.requiredLevel <= minLevel).toList();
      }
      
      // Sort by featured, then by popularity
      filteredItems.sort((a, b) {
        if (a.isFeatured && !b.isFeatured) return -1;
        if (!a.isFeatured && b.isFeatured) return 1;
        return b.purchaseCount.compareTo(a.purchaseCount);
      });
      
      return filteredItems;
    } catch (e) {
      throw Exception('Failed to get marketplace items: ${e.toString()}');
    }
  }

  @override
  Future<MarketplaceItemEntity> createItem(String userId, Map<String, dynamic> itemData) async {
    try {
      final now = DateTime.now();
      final itemId = 'item_${now.millisecondsSinceEpoch}';
      
      final item = MarketplaceItemEntity(
        id: itemId,
        creatorId: userId,
        name: itemData['name'] as String,
        description: itemData['description'] as String,
        category: itemData['category'] as String,
        subcategory: itemData['subcategory'] as String?,
        itemType: itemData['item_type'] as String? ?? 'cosmetic',
        rarity: itemData['rarity'] as String? ?? 'common',
        price: itemData['price'] as double? ?? 0.0,
        premiumPrice: itemData['premium_price'] as double?,
        currency: itemData['currency'] as String? ?? 'coins',
        tags: (itemData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        previewUrl: itemData['preview_url'] as String?,
        assetUrls: Map<String, String>.from(itemData['asset_urls'] ?? {}),
        requiredLevel: itemData['required_level'] as int? ?? 1,
        isLimitedTime: itemData['is_limited_time'] as bool? ?? false,
        limitedTimeEnd: itemData['limited_time_end'] != null
            ? DateTime.parse(itemData['limited_time_end'] as String)
            : null,
        isExclusive: itemData['is_exclusive'] as bool? ?? false,
        exclusiveRequirement: itemData['exclusive_requirement'] as String?,
        aiGenerationData: Map<String, dynamic>.from(itemData['ai_generation_data'] ?? {}),
        status: 'pending_approval',
        createdAt: now,
      );
      
      return item;
    } catch (e) {
      throw Exception('Failed to create marketplace item: ${e.toString()}');
    }
  }

  @override
  Future<MarketplaceTransactionEntity> purchaseItem(String userId, String itemId, String paymentMethod) async {
    try {
      final validation = await validateItemPurchase(userId, itemId);
      
      if (!validation['can_purchase']) {
        throw Exception(validation['reason'] as String);
      }
      
      final item = await _getItemById(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }
      
      final now = DateTime.now();
      final transactionId = 'txn_${now.millisecondsSinceEpoch}';
      
      final transaction = MarketplaceTransactionEntity(
        id: transactionId,
        itemId: itemId,
        buyerId: userId,
        sellerId: item.creatorId,
        amount: item.price,
        currency: item.currency,
        paymentMethod: paymentMethod,
        status: 'completed',
        transactionType: 'purchase',
        platformFee: _calculatePlatformFee(item.price),
        creatorEarnings: item.price - _calculatePlatformFee(item.price),
        createdAt: now,
      );
      
      // Add item to user's inventory
      await _addToInventory(userId, itemId);
      
      // Update item purchase count
      await _updateItemStats(itemId);
      
      return transaction;
    } catch (e) {
      throw Exception('Failed to purchase item: ${e.toString()}');
    }
  }

  @override
  Future<UserInventoryEntity> getUserInventory(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final mockInventory = _generateMockInventory(userId);
      return mockInventory;
    } catch (e) {
      throw Exception('Failed to get user inventory: ${e.toString()}');
    }
  }

  @override
  Future<bool> equipItem(String userId, String itemId) async {
    try {
      final inventory = await getUserInventory(userId);
      final inventoryItem = inventory.items.firstWhere(
        (item) => item.itemId == itemId,
        orElse: () => throw Exception('Item not found in inventory'),
      );
      
      if (!inventoryItem.isUnlocked) {
        throw Exception('Item is not unlocked');
      }
      
      // Update equipped items in inventory
      final updatedItems = inventory.items.map((item) {
        if (item.category == inventoryItem.category) {
          return item.copyWith(isEquipped: item.itemId == itemId);
        }
        return item;
      }).toList();
      
      // In real implementation, would update database
      return true;
    } catch (e) {
      throw Exception('Failed to equip item: ${e.toString()}');
    }
  }

  @override
  Future<List<MarketplaceItemEntity>> searchItems(String query, Map<String, dynamic> filters) async {
    try {
      final allItems = await getMarketplaceItems();
      
      List<MarketplaceItemEntity> filteredItems = allItems;
      
      // Apply text search
      if (query.isNotEmpty) {
        filteredItems = filteredItems.where((item) {
          return item.name.toLowerCase().contains(query.toLowerCase()) ||
                 item.description.toLowerCase().contains(query.toLowerCase()) ||
                 item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
      
      // Apply filters
      if (filters['min_price'] != null) {
        filteredItems = filteredItems.where((item) => item.price >= filters['min_price']).toList();
      }
      
      if (filters['max_price'] != null) {
        filteredItems = filteredItems.where((item) => item.price <= filters['max_price']).toList();
      }
      
      if (filters['creator_id'] != null) {
        filteredItems = filteredItems.where((item) => item.creatorId == filters['creator_id']).toList();
      }
      
      if (filters['is_animated'] != null) {
        filteredItems = filteredItems.where((item) => item.isAnimated == filters['is_animated']).toList();
      }
      
      return filteredItems;
    } catch (e) {
      throw Exception('Failed to search items: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMarketplaceAnalytics() async {
    try {
      final allItems = await getMarketplaceItems();
      
      final totalItems = allItems.length;
      final totalTransactions = allItems.fold<int>(0, (sum, item) => sum + item.purchaseCount);
      final totalRevenue = allItems.fold<double>(0, (sum, item) => sum + (item.price * item.purchaseCount));
      
      // Category breakdown
      final categoryBreakdown = <String, int>{};
      for (final item in allItems) {
        categoryBreakdown[item.category] = (categoryBreakdown[item.category] ?? 0) + 1;
      }
      
      // Rarity distribution
      final rarityDistribution = <String, int>{};
      for (final item in allItems) {
        rarityDistribution[item.rarity] = (rarityDistribution[item.rarity] ?? 0) + 1;
      }
      
      // Top selling items
      final topItems = allItems.toList()
        ..sort((a, b) => b.purchaseCount.compareTo(a.purchaseCount));
      
      return {
        'summary': {
          'total_items': totalItems,
          'total_transactions': totalTransactions,
          'total_revenue': totalRevenue,
          'average_item_price': totalItems > 0 ? 
              allItems.fold<double>(0, (sum, item) => sum + item.price) / totalItems : 0.0,
        },
        'breakdown': {
          'by_category': categoryBreakdown,
          'by_rarity': rarityDistribution,
        },
        'top_items': topItems.take(10).map((item) => {
          'id': item.id,
          'name': item.name,
          'purchase_count': item.purchaseCount,
          'revenue': item.price * item.purchaseCount,
        }).toList(),
        'trends': {
          'featured_items': allItems.where((item) => item.isFeatured).length,
          'limited_time_items': allItems.where((item) => item.isLimitedTime).length,
          'ai_generated_items': allItems.where((item) => item.isAIGenerated).length,
        },
      };
    } catch (e) {
      throw Exception('Failed to get marketplace analytics: ${e.toString()}');
    }
  }

  @override
  Future<CreatorProfileEntity> getCreatorProfile(String creatorId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 150));
      return _generateMockCreatorProfile(creatorId);
    } catch (e) {
      throw Exception('Failed to get creator profile: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> generateAIItems(String category, String theme, int count) async {
    try {
      return MarketplaceUtils.generateAIItems(
        category: category,
        theme: theme,
        count: count,
        style: 'modern',
        complexity: 'medium',
      );
    } catch (e) {
      throw Exception('Failed to generate AI items: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> validateItemPurchase(String userId, String itemId) async {
    try {
      final item = await _getItemById(itemId);
      if (item == null) {
        return {'can_purchase': false, 'reason': 'Item not found'};
      }
      
      if (!item.isAvailable) {
        return {'can_purchase': false, 'reason': 'Item is not available'};
      }
      
      // Check user level requirement
      final userLevel = await _getUserLevel(userId);
      if (userLevel < item.requiredLevel) {
        return {
          'can_purchase': false, 
          'reason': 'Requires level ${item.requiredLevel}. You are level $userLevel.'
        };
      }
      
      // Check if already owned
      final inventory = await getUserInventory(userId);
      final alreadyOwned = inventory.items.any((invItem) => invItem.itemId == itemId);
      if (alreadyOwned) {
        return {'can_purchase': false, 'reason': 'You already own this item'};
      }
      
      // Check currency balance
      final hasEnoughCurrency = await _checkUserCurrency(userId, item.currency, item.price);
      if (!hasEnoughCurrency) {
        return {
          'can_purchase': false, 
          'reason': 'Insufficient ${item.currency}. Need ${item.price} ${item.currency}.'
        };
      }
      
      // Check limited time availability
      if (item.isLimitedTime && item.limitedTimeEnd != null) {
        if (DateTime.now().isAfter(item.limitedTimeEnd!)) {
          return {'can_purchase': false, 'reason': 'Limited time offer has expired'};
        }
      }
      
      return {'can_purchase': true, 'item': item};
    } catch (e) {
      throw Exception('Failed to validate item purchase: ${e.toString()}');
    }
  }

  // Private helper methods
  List<MarketplaceItemEntity> _generateMockMarketplaceItems() {
    final now = DateTime.now();
    
    return [
      MarketplaceItemEntity(
        id: 'item_1',
        creatorId: 'creator_1',
        name: 'Golden Phoenix Avatar',
        description: 'Majestic phoenix avatar with golden wings and fire effects',
        category: 'avatars',
        subcategory: 'mythical',
        itemType: 'avatar',
        rarity: 'legendary',
        price: 500.0,
        currency: 'gems',
        tags: ['phoenix', 'golden', 'fire', 'mythical'],
        previewUrl: 'https://example.com/phoenix_preview.gif',
        assetUrls: {
          'animation': 'https://example.com/phoenix_animation.json',
          'static': 'https://example.com/phoenix_static.png',
        },
        requiredLevel: 25,
        rating: 4.8,
        ratingCount: 156,
        purchaseCount: 89,
        isAnimated: true,
        isFeatured: true,
        isAIGenerated: false,
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      MarketplaceItemEntity(
        id: 'item_2',
        creatorId: 'creator_2',
        name: 'Neon Cyberpunk Theme',
        description: 'Futuristic neon theme with cyberpunk aesthetics',
        category: 'themes',
        subcategory: 'cyberpunk',
        itemType: 'theme',
        rarity: 'rare',
        price: 200.0,
        currency: 'coins',
        tags: ['neon', 'cyberpunk', 'futuristic', 'dark'],
        previewUrl: 'https://example.com/cyberpunk_preview.jpg',
        assetUrls: {
          'background': 'https://example.com/cyberpunk_bg.jpg',
          'ui_elements': 'https://example.com/cyberpunk_ui.zip',
        },
        requiredLevel: 15,
        rating: 4.6,
        ratingCount: 203,
        purchaseCount: 145,
        isAnimated: false,
        isFeatured: false,
        isAIGenerated: true,
        status: 'approved',
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  UserInventoryEntity _generateMockInventory(String userId) {
    final now = DateTime.now();
    
    return UserInventoryEntity(
      id: 'inv_$userId',
      userId: userId,
      items: [
        UserInventoryItemEntity(
          id: 'inv_item_1',
          itemId: 'item_default_avatar',
          category: 'avatars',
          isEquipped: true,
          isUnlocked: true,
          unlockedAt: now.subtract(const Duration(days: 365)),
          source: 'default',
        ),
        UserInventoryItemEntity(
          id: 'inv_item_2',
          itemId: 'item_2',
          category: 'themes',
          isEquipped: false,
          isUnlocked: true,
          unlockedAt: now.subtract(const Duration(days: 15)),
          source: 'purchase',
          purchasePrice: 200.0,
        ),
      ],
      totalValue: 200.0,
      itemCount: 2,
      favoriteItems: ['item_2'],
      recentlyUnlocked: ['item_2'],
      updatedAt: now,
    );
  }

  CreatorProfileEntity _generateMockCreatorProfile(String creatorId) {
    final now = DateTime.now();
    
    return CreatorProfileEntity(
      id: creatorId,
      userId: creatorId,
      displayName: 'Digital Artist Pro',
      bio: 'Creating amazing digital content for the HabitX community',
      profileImageUrl: 'https://example.com/creator_avatar.jpg',
      bannerImageUrl: 'https://example.com/creator_banner.jpg',
      specialties: ['avatars', 'themes', 'animations'],
      totalItems: 25,
      totalSales: 1450,
      totalRevenue: 15800.0,
      averageRating: 4.7,
      followerCount: 234,
      isVerified: true,
      verificationBadge: 'verified_creator',
      commissionInfo: {
        'accepts_commissions': true,
        'base_price': 50.0,
        'turnaround_days': 7,
      },
      socialLinks: {
        'twitter': '@digitalartistpro',
        'instagram': '@digitalartistpro',
      },
      joinedAt: now.subtract(const Duration(days: 180)),
      lastActive: now.subtract(const Duration(hours: 2)),
    );
  }

  Future<MarketplaceItemEntity?> _getItemById(String itemId) async {
    final items = _generateMockMarketplaceItems();
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  Future<int> _getUserLevel(String userId) async {
    // Mock user level - in real implementation, would query user data
    return 20;
  }

  Future<bool> _checkUserCurrency(String userId, String currency, double amount) async {
    // Mock currency check - in real implementation, would check user's currency balance
    final mockBalances = {
      'coins': 1000.0,
      'gems': 250.0,
      'premium_currency': 50.0,
    };
    
    final balance = mockBalances[currency] ?? 0.0;
    return balance >= amount;
  }

  double _calculatePlatformFee(double price) {
    // 15% platform fee
    return price * 0.15;
  }

  Future<void> _addToInventory(String userId, String itemId) async {
    // Mock inventory addition - in real implementation, would update database
    print('Added item $itemId to user $userId inventory');
  }

  Future<void> _updateItemStats(String itemId) async {
    // Mock stats update - in real implementation, would increment purchase count
    print('Updated purchase stats for item $itemId');
  }
}
