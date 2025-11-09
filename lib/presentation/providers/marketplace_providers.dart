import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/marketplace_entity.dart';
import '../../domain/usecases/marketplace_usecases.dart';
import '../../core/di/injection.dart';

// Use Case Providers
final getMarketplaceItemsUseCaseProvider = Provider<GetMarketplaceItemsUseCase>((ref) => getIt<GetMarketplaceItemsUseCase>());
final createMarketplaceItemUseCaseProvider = Provider<CreateMarketplaceItemUseCase>((ref) => getIt<CreateMarketplaceItemUseCase>());
final purchaseItemUseCaseProvider = Provider<PurchaseItemUseCase>((ref) => getIt<PurchaseItemUseCase>());
final getUserInventoryUseCaseProvider = Provider<GetUserInventoryUseCase>((ref) => getIt<GetUserInventoryUseCase>());
final equipItemUseCaseProvider = Provider<EquipItemUseCase>((ref) => getIt<EquipItemUseCase>());
final searchMarketplaceItemsUseCaseProvider = Provider<SearchMarketplaceItemsUseCase>((ref) => getIt<SearchMarketplaceItemsUseCase>());
final getMarketplaceAnalyticsUseCaseProvider = Provider<GetMarketplaceAnalyticsUseCase>((ref) => getIt<GetMarketplaceAnalyticsUseCase>());
final getCreatorProfileUseCaseProvider = Provider<GetCreatorProfileUseCase>((ref) => getIt<GetCreatorProfileUseCase>());
final generateAIItemsUseCaseProvider = Provider<GenerateAIItemsUseCase>((ref) => getIt<GenerateAIItemsUseCase>());
final validateItemPurchaseUseCaseProvider = Provider<ValidateItemPurchaseUseCase>((ref) => getIt<ValidateItemPurchaseUseCase>());
final syncMarketplaceDataUseCaseProvider = Provider<SyncMarketplaceDataUseCase>((ref) => getIt<SyncMarketplaceDataUseCase>());
final calculateItemValueUseCaseProvider = Provider<CalculateItemValueUseCase>((ref) => getIt<CalculateItemValueUseCase>());
final getTrendingItemsUseCaseProvider = Provider<GetTrendingItemsUseCase>((ref) => getIt<GetTrendingItemsUseCase>());

// State Classes
class MarketplaceState {
  final List<MarketplaceItemEntity> items;
  final List<MarketplaceItemEntity> trendingItems;
  final UserInventoryEntity? userInventory;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? itemValue;
  final Map<String, dynamic>? trendingData;
  final List<MarketplaceItemEntity> searchResults;
  final String searchQuery;
  final Map<String, dynamic> searchFilters;
  final bool isLoading;
  final String? error;

  const MarketplaceState({
    this.items = const [],
    this.trendingItems = const [],
    this.userInventory,
    this.analytics,
    this.itemValue,
    this.trendingData,
    this.searchResults = const [],
    this.searchQuery = '',
    this.searchFilters = const {},
    this.isLoading = false,
    this.error,
  });

  MarketplaceState copyWith({
    List<MarketplaceItemEntity>? items,
    List<MarketplaceItemEntity>? trendingItems,
    UserInventoryEntity? userInventory,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? itemValue,
    Map<String, dynamic>? trendingData,
    List<MarketplaceItemEntity>? searchResults,
    String? searchQuery,
    Map<String, dynamic>? searchFilters,
    bool? isLoading,
    String? error,
  }) {
    return MarketplaceState(
      items: items ?? this.items,
      trendingItems: trendingItems ?? this.trendingItems,
      userInventory: userInventory ?? this.userInventory,
      analytics: analytics ?? this.analytics,
      itemValue: itemValue ?? this.itemValue,
      trendingData: trendingData ?? this.trendingData,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      searchFilters: searchFilters ?? this.searchFilters,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get totalItems => items.length;
  int get inventoryValue => userInventory?.totalValue?.round() ?? 0;
  int get inventoryItemCount => userInventory?.items.length ?? 0;
}

// Marketplace State Notifier
class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final GetMarketplaceItemsUseCase getItemsUseCase;
  final CreateMarketplaceItemUseCase createItemUseCase;
  final PurchaseItemUseCase purchaseItemUseCase;
  final GetUserInventoryUseCase getUserInventoryUseCase;
  final EquipItemUseCase equipItemUseCase;
  final SearchMarketplaceItemsUseCase searchItemsUseCase;
  final GetMarketplaceAnalyticsUseCase getAnalyticsUseCase;
  final GetCreatorProfileUseCase getCreatorProfileUseCase;
  final GenerateAIItemsUseCase generateAIItemsUseCase;
  final ValidateItemPurchaseUseCase validatePurchaseUseCase;
  final SyncMarketplaceDataUseCase syncDataUseCase;
  final CalculateItemValueUseCase calculateValueUseCase;
  final GetTrendingItemsUseCase getTrendingItemsUseCase;

  MarketplaceNotifier({
    required this.getItemsUseCase,
    required this.createItemUseCase,
    required this.purchaseItemUseCase,
    required this.getUserInventoryUseCase,
    required this.equipItemUseCase,
    required this.searchItemsUseCase,
    required this.getAnalyticsUseCase,
    required this.getCreatorProfileUseCase,
    required this.generateAIItemsUseCase,
    required this.validatePurchaseUseCase,
    required this.syncDataUseCase,
    required this.calculateValueUseCase,
    required this.getTrendingItemsUseCase,
  }) : super(const MarketplaceState());

  String? _currentUserId;

  void setUserId(String userId) {
    _currentUserId = userId;
    loadUserData();
  }

  Future<void> loadUserData() async {
    await loadItems();
    await loadUserInventory();
    await loadAnalytics();
    await loadItemValue();
    await loadTrendingItems();
  }

  Future<void> loadItems({String? category, String? rarity, int? minLevel}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getItemsUseCase(GetMarketplaceItemsParams(
      category: category,
      rarity: rarity,
      minLevel: minLevel,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
        error: null,
      ),
    );
  }

  Future<void> loadUserInventory() async {
    if (_currentUserId == null) return;
    
    final result = await getUserInventoryUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (inventory) => state = state.copyWith(userInventory: inventory),
    );
  }

  Future<void> loadAnalytics() async {
    final result = await getAnalyticsUseCase(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (analytics) => state = state.copyWith(analytics: analytics),
    );
  }

  Future<void> loadItemValue() async {
    if (_currentUserId == null) return;
    
    final result = await calculateValueUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (value) => state = state.copyWith(itemValue: value),
    );
  }

  Future<void> loadTrendingItems() async {
    final result = await getTrendingItemsUseCase(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.toString()),
      (data) {
        final trendingItems = (data['trending_items'] as List<dynamic>?)
            ?.map((item) => MarketplaceItemEntity.fromJson(item))
            .toList() ?? [];
        
        state = state.copyWith(
          trendingItems: trendingItems,
          trendingData: data,
        );
      },
    );
  }

  Future<bool> createItem(Map<String, dynamic> itemData) async {
    if (_currentUserId == null) return false;
    
    state = state.copyWith(isLoading: true);
    
    final result = await createItemUseCase(CreateMarketplaceItemParams(
      userId: _currentUserId!,
      itemData: itemData,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (item) {
        state = state.copyWith(
          isLoading: false,
          items: [...state.items, item],
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> purchaseItem(String itemId, String paymentMethod) async {
    if (_currentUserId == null) return false;
    
    // Validate purchase first
    final validationResult = await validatePurchaseUseCase(ValidateItemPurchaseParams(
      userId: _currentUserId!,
      itemId: itemId,
    ));
    
    final isValid = validationResult.fold(
      (failure) => false,
      (validation) => validation['is_valid'] ?? false,
    );
    
    if (!isValid) {
      state = state.copyWith(error: 'Purchase validation failed');
      return false;
    }
    
    state = state.copyWith(isLoading: true);
    
    final result = await purchaseItemUseCase(PurchaseItemParams(
      userId: _currentUserId!,
      itemId: itemId,
      paymentMethod: paymentMethod,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.toString(),
        );
        return false;
      },
      (transaction) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
        // Reload inventory after purchase
        loadUserInventory();
        loadItemValue();
        return true;
      },
    );
  }

  Future<bool> equipItem(String itemId) async {
    if (_currentUserId == null) return false;
    
    final result = await equipItemUseCase(EquipItemParams(
      userId: _currentUserId!,
      itemId: itemId,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return false;
      },
      (success) {
        if (success) {
          loadUserInventory(); // Reload to reflect equipped status
        }
        return success;
      },
    );
  }

  Future<void> searchItems(String query, Map<String, dynamic> filters) async {
    state = state.copyWith(
      searchQuery: query,
      searchFilters: filters,
      isLoading: true,
    );
    
    final result = await searchItemsUseCase(SearchMarketplaceItemsParams(
      query: query,
      filters: filters,
    ));
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        searchResults: items,
        error: null,
      ),
    );
  }

  Future<List<String>> generateAIItems(String category, String theme, int count) async {
    final result = await generateAIItemsUseCase(GenerateAIItemsParams(
      category: category,
      theme: theme,
      count: count,
    ));
    
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.toString());
        return [];
      },
      (items) => items,
    );
  }

  Future<void> syncData() async {
    if (_currentUserId == null) return;
    
    state = state.copyWith(isLoading: true);
    
    final result = await syncDataUseCase(_currentUserId!);
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (success) {
        state = state.copyWith(isLoading: false);
        if (success) {
          loadUserData();
        }
      },
    );
  }

  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
      searchFilters: {},
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Marketplace Provider
final marketplaceProvider = StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  return MarketplaceNotifier(
    getItemsUseCase: ref.read(getMarketplaceItemsUseCaseProvider),
    createItemUseCase: ref.read(createMarketplaceItemUseCaseProvider),
    purchaseItemUseCase: ref.read(purchaseItemUseCaseProvider),
    getUserInventoryUseCase: ref.read(getUserInventoryUseCaseProvider),
    equipItemUseCase: ref.read(equipItemUseCaseProvider),
    searchItemsUseCase: ref.read(searchMarketplaceItemsUseCaseProvider),
    getAnalyticsUseCase: ref.read(getMarketplaceAnalyticsUseCaseProvider),
    getCreatorProfileUseCase: ref.read(getCreatorProfileUseCaseProvider),
    generateAIItemsUseCase: ref.read(generateAIItemsUseCaseProvider),
    validatePurchaseUseCase: ref.read(validateItemPurchaseUseCaseProvider),
    syncDataUseCase: ref.read(syncMarketplaceDataUseCaseProvider),
    calculateValueUseCase: ref.read(calculateItemValueUseCaseProvider),
    getTrendingItemsUseCase: ref.read(getTrendingItemsUseCaseProvider),
  );
});

// Computed Providers
final itemsByCategoryProvider = Provider<Map<String, List<MarketplaceItemEntity>>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  final itemsByCategory = <String, List<MarketplaceItemEntity>>{};
  
  for (final item in marketplaceState.items) {
    final category = item.category ?? 'other';
    itemsByCategory[category] ??= [];
    itemsByCategory[category]!.add(item);
  }
  
  return itemsByCategory;
});

final itemsByRarityProvider = Provider<Map<String, List<MarketplaceItemEntity>>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  final itemsByRarity = <String, List<MarketplaceItemEntity>>{};
  
  for (final item in marketplaceState.items) {
    final rarity = item.rarity ?? 'common';
    itemsByRarity[rarity] ??= [];
    itemsByRarity[rarity]!.add(item);
  }
  
  return itemsByRarity;
});

final equippedItemsProvider = Provider<List<MarketplaceItemEntity>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.userInventory?.items.where((item) => item.isEquipped).toList() ?? [];
});

final unequippedItemsProvider = Provider<List<MarketplaceItemEntity>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.userInventory?.items.where((item) => !item.isEquipped).toList() ?? [];
});

final totalInventoryValueProvider = Provider<int>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.itemValue?['total_value'] ?? 0;
});

final inventoryRarityDistributionProvider = Provider<Map<String, int>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return Map<String, int>.from(marketplaceState.itemValue?['rarity_distribution'] ?? {});
});

final mostValuableItemProvider = Provider<Map<String, dynamic>?>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.itemValue?['most_valuable_item'];
});

final investmentReturnProvider = Provider<double>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.itemValue?['investment_return']?.toDouble() ?? 0.0;
});

final priceGainersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  final gainers = marketplaceState.trendingData?['price_gainers'] as List<dynamic>?;
  return gainers?.cast<Map<String, dynamic>>() ?? [];
});

final popularCategoriesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  final categories = marketplaceState.trendingData?['popular_categories'] as List<dynamic>?;
  return categories?.cast<Map<String, dynamic>>() ?? [];
});

final marketInsightsProvider = Provider<List<String>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  final insights = marketplaceState.trendingData?['market_insights'] as List<dynamic>?;
  return insights?.cast<String>() ?? [];
});

final affordableItemsProvider = Provider<List<MarketplaceItemEntity>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  // Assuming user has coins/currency - this would come from user state
  const userCoins = 1000; // This should come from user provider
  
  return marketplaceState.items
      .where((item) => (item.currentPrice ?? item.originalPrice ?? 0) <= userCoins)
      .toList();
});

final newItemsProvider = Provider<List<MarketplaceItemEntity>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
  
  return marketplaceState.items
      .where((item) => item.createdAt.isAfter(oneDayAgo))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final featuredItemsProvider = Provider<List<MarketplaceItemEntity>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.items.where((item) => item.isFeatured ?? false).toList();
});

final limitedEditionItemsProvider = Provider<List<MarketplaceItemEntity>>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.items.where((item) => item.isLimitedEdition ?? false).toList();
});

// Search-related providers
final hasSearchResultsProvider = Provider<bool>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.searchResults.isNotEmpty;
});

final isSearchingProvider = Provider<bool>((ref) {
  final marketplaceState = ref.watch(marketplaceProvider);
  return marketplaceState.searchQuery.isNotEmpty;
});

// Creator Profile Provider
final creatorProfileProvider = FutureProvider.family<CreatorProfileEntity?, String>((ref, creatorId) async {
  final getCreatorProfileUseCase = ref.read(getCreatorProfileUseCaseProvider);
  final result = await getCreatorProfileUseCase(creatorId);
  
  return result.fold(
    (failure) => null,
    (profile) => profile,
  );
});
