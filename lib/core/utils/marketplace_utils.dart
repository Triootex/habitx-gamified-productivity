import '../constants/marketplace_constants.dart';
import 'math_utils.dart';
import 'string_utils.dart';

class MarketplaceUtils {
  /// Calculate item value based on rarity, abilities, and market demand
  static Map<String, int> calculateItemValue(
    String rarity,
    List<String> abilities,
    double marketDemand,
    String category,
  ) {
    // Base price from rarity
    final basePrice = MarketplaceConstants.pricingTiers[rarity] ?? 
        MarketplaceConstants.pricingTiers[MarketplaceConstants.common]!;
    
    // Calculate ability multiplier
    double abilityMultiplier = 1.0;
    for (final ability in abilities) {
      abilityMultiplier += _getAbilityValueMultiplier(ability);
    }
    
    // Apply market demand
    final demandMultiplier = (0.5 + marketDemand * 1.5).clamp(0.1, 3.0);
    
    // Category popularity adjustment
    final categoryMultiplier = _getCategoryPopularityMultiplier(category);
    
    final finalMultiplier = abilityMultiplier * demandMultiplier * categoryMultiplier;
    
    return {
      MarketplaceConstants.gold: (basePrice[MarketplaceConstants.gold]! * finalMultiplier).round(),
      MarketplaceConstants.gems: (basePrice[MarketplaceConstants.gems]! * finalMultiplier).round(),
      MarketplaceConstants.tokens: (basePrice[MarketplaceConstants.tokens]! * finalMultiplier).round(),
    };
  }
  
  static double _getAbilityValueMultiplier(String ability) {
    switch (ability) {
      case 'XP Boost':
        return 0.3;
      case 'Gold Magnet':
        return 0.5;
      case 'Streak Shield':
        return 0.7;
      case 'Time Warp':
        return 1.0;
      case 'Motivation Aura':
        return 1.5;
      case 'Master Key':
        return 2.0;
      default:
        return 0.1;
    }
  }
  
  static double _getCategoryPopularityMultiplier(String category) {
    final categoryData = MarketplaceConstants.marketplaceCategories
        .firstWhere((cat) => cat['category'] == category,
            orElse: () => {'popularity': 0.5});
    return categoryData['popularity'] as double? ?? 0.5;
  }
  
  /// Generate AI-powered item suggestions based on user preferences
  static List<Map<String, dynamic>> generateAIItemSuggestions(
    Map<String, dynamic> userProfile,
    List<String> ownedItems,
    String generationType,
  ) {
    final suggestions = <Map<String, dynamic>>[];
    
    // Analyze user preferences
    final favoriteCategories = userProfile['favorite_categories'] as List<String>? ?? [];
    final skillLevel = userProfile['creation_skill_level'] as String? ?? 'beginner';
    final preferredStyles = userProfile['preferred_styles'] as List<String>? ?? [];
    
    // Find appropriate AI generation category
    final aiCategory = MarketplaceConstants.aiGenerationCategories
        .firstWhere((cat) => cat['category'] == generationType,
            orElse: () => MarketplaceConstants.aiGenerationCategories.first);
    
    final styles = aiCategory['styles'] as List<String>;
    final attributes = aiCategory['attributes'] as List<String>;
    
    // Generate suggestions
    for (int i = 0; i < 5; i++) {
      final style = preferredStyles.isNotEmpty 
          ? preferredStyles[MathUtils.randomInt(0, preferredStyles.length - 1)]
          : styles[MathUtils.randomInt(0, styles.length - 1)];
      
      final randomAttributes = _selectRandomAttributes(attributes, skillLevel);
      
      suggestions.add({
        'id': 'ai_suggestion_${DateTime.now().millisecondsSinceEpoch}_$i',
        'type': generationType.toLowerCase().replaceAll(' ', '_'),
        'style': style,
        'attributes': randomAttributes,
        'estimated_rarity': _calculateEstimatedRarity(skillLevel, randomAttributes.length),
        'creation_time_hours': _estimateCreationTime(generationType, skillLevel),
        'suggested_price': _suggestPrice(generationType, skillLevel, randomAttributes.length),
      });
    }
    
    return suggestions;
  }
  
  static Map<String, dynamic> _selectRandomAttributes(List<String> available, String skillLevel) {
    final attributeCount = _getAttributeCountForSkill(skillLevel);
    final selectedAttributes = <String, dynamic>{};
    
    final shuffled = List<String>.from(available)..shuffle();
    
    for (int i = 0; i < attributeCount && i < shuffled.length; i++) {
      selectedAttributes[shuffled[i]] = _generateAttributeValue(shuffled[i], skillLevel);
    }
    
    return selectedAttributes;
  }
  
  static int _getAttributeCountForSkill(String skillLevel) {
    switch (skillLevel) {
      case 'beginner':
        return MathUtils.randomInt(2, 4);
      case 'intermediate':
        return MathUtils.randomInt(3, 6);
      case 'advanced':
        return MathUtils.randomInt(5, 8);
      default:
        return 3;
    }
  }
  
  static dynamic _generateAttributeValue(String attribute, String skillLevel) {
    switch (attribute) {
      case 'color':
      case 'color_scheme':
        return _generateRandomColor();
      case 'size':
        return ['small', 'medium', 'large'][MathUtils.randomInt(0, 2)];
      case 'complexity':
        return skillLevel == 'advanced' ? 'high' : 
               skillLevel == 'intermediate' ? 'medium' : 'low';
      case 'mood':
        return ['energetic', 'calm', 'mysterious', 'playful'][MathUtils.randomInt(0, 3)];
      default:
        return 'custom_value_${MathUtils.randomInt(1, 100)}';
    }
  }
  
  static String _generateRandomColor() {
    final colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7', '#DDA0DD', '#98D8C8'];
    return colors[MathUtils.randomInt(0, colors.length - 1)];
  }
  
  static String _calculateEstimatedRarity(String skillLevel, int attributeCount) {
    int rarityScore = 0;
    
    switch (skillLevel) {
      case 'beginner':
        rarityScore += 1;
        break;
      case 'intermediate':
        rarityScore += 3;
        break;
      case 'advanced':
        rarityScore += 5;
        break;
    }
    
    rarityScore += attributeCount;
    
    if (rarityScore <= 3) return MarketplaceConstants.common;
    if (rarityScore <= 5) return MarketplaceConstants.uncommon;
    if (rarityScore <= 7) return MarketplaceConstants.rare;
    if (rarityScore <= 9) return MarketplaceConstants.epic;
    if (rarityScore <= 11) return MarketplaceConstants.legendary;
    return MarketplaceConstants.mythical;
  }
  
  static int _estimateCreationTime(String type, String skillLevel) {
    final baseTime = MarketplaceConstants.creationRequirements[type]?['time_hours'] as int? ?? 2;
    
    switch (skillLevel) {
      case 'beginner':
        return (baseTime * 1.5).round();
      case 'intermediate':
        return baseTime;
      case 'advanced':
        return (baseTime * 0.7).round();
      default:
        return baseTime;
    }
  }
  
  static Map<String, int> _suggestPrice(String type, String skillLevel, int attributeCount) {
    final rarity = _calculateEstimatedRarity(skillLevel, attributeCount);
    return MarketplaceConstants.pricingTiers[rarity]!;
  }
  
  /// Process and validate item trades between users
  static Map<String, dynamic> validateTrade(
    Map<String, dynamic> tradeOffer,
    Map<String, dynamic> userAProfile,
    Map<String, dynamic> userBProfile,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Check user levels
    final userALevel = userAProfile['level'] as int? ?? 1;
    final userBLevel = userBProfile['level'] as int? ?? 1;
    
    if (userALevel < MarketplaceConstants.tradingRules['min_user_level']) {
      errors.add('User A must be level ${MarketplaceConstants.tradingRules['min_user_level']} to trade');
    }
    
    if (userBLevel < MarketplaceConstants.tradingRules['min_user_level']) {
      errors.add('User B must be level ${MarketplaceConstants.tradingRules['min_user_level']} to trade');
    }
    
    // Check item limits
    final userAItems = tradeOffer['user_a_items'] as List<String>? ?? [];
    final userBItems = tradeOffer['user_b_items'] as List<String>? ?? [];
    
    if (userAItems.length > MarketplaceConstants.tradingRules['max_items_per_trade']) {
      errors.add('User A is offering too many items');
    }
    
    if (userBItems.length > MarketplaceConstants.tradingRules['max_items_per_trade']) {
      errors.add('User B is offering too many items');
    }
    
    // Check trade cooldown
    final userALastTrade = userAProfile['last_trade_time'] as DateTime?;
    final userBLastTrade = userBProfile['last_trade_time'] as DateTime?;
    final cooldownHours = MarketplaceConstants.tradingRules['trade_cooldown_hours'] as int;
    
    if (userALastTrade != null) {
      final hoursSinceLastTrade = DateTime.now().difference(userALastTrade).inHours;
      if (hoursSinceLastTrade < cooldownHours) {
        errors.add('User A must wait ${cooldownHours - hoursSinceLastTrade} hours before trading again');
      }
    }
    
    if (userBLastTrade != null) {
      final hoursSinceLastTrade = DateTime.now().difference(userBLastTrade).inHours;
      if (hoursSinceLastTrade < cooldownHours) {
        errors.add('User B must wait ${cooldownHours - hoursSinceLastTrade} hours before trading again');
      }
    }
    
    // Calculate trade fairness
    final fairnessScore = _calculateTradeFairness(tradeOffer);
    if (fairnessScore < 0.7) {
      warnings.add('This trade appears to be significantly unbalanced');
    }
    
    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'fairness_score': fairnessScore,
      'recommended_escrow_hours': MarketplaceConstants.tradingRules['escrow_duration_hours'],
    };
  }
  
  static double _calculateTradeFairness(Map<String, dynamic> tradeOffer) {
    // This would calculate the total value of items on each side
    // For now, return a mock fairness score
    return MathUtils.randomDouble(0.6, 1.0);
  }
  
  /// Generate featured items for marketplace rotation
  static List<Map<String, dynamic>> selectFeaturedItems(
    List<Map<String, dynamic>> availableItems,
    Map<String, double> selectionCriteria,
  ) {
    final scoredItems = <Map<String, dynamic>>[];
    
    for (final item in availableItems) {
      final score = _calculateFeaturedScore(item, selectionCriteria);
      scoredItems.add({
        ...item,
        'featured_score': score,
      });
    }
    
    // Sort by score and select top items
    scoredItems.sort((a, b) => (b['featured_score'] as double).compareTo(a['featured_score'] as double));
    
    final maxItems = MarketplaceConstants.featuredItemsConfig['max_featured_items'] as int;
    return scoredItems.take(maxItems).toList();
  }
  
  static double _calculateFeaturedScore(
    Map<String, dynamic> item,
    Map<String, double> criteria,
  ) {
    double score = 0.0;
    
    // Popularity weight
    final popularity = item['popularity_score'] as double? ?? 0.5;
    score += popularity * (criteria['popularity_weight'] ?? 0.4);
    
    // Recent sales weight
    final recentSales = item['recent_sales'] as int? ?? 0;
    final salesScore = (recentSales / 100.0).clamp(0.0, 1.0);
    score += salesScore * (criteria['recent_sales_weight'] ?? 0.3);
    
    // Creator level weight
    final creatorLevel = item['creator_level'] as int? ?? 1;
    final levelScore = (creatorLevel / 10.0).clamp(0.0, 1.0);
    score += levelScore * (criteria['creator_level_weight'] ?? 0.2);
    
    // Randomness for variety
    final randomScore = MathUtils.randomDouble(0.0, 1.0);
    score += randomScore * (criteria['randomness_weight'] ?? 0.1);
    
    return score;
  }
  
  /// Calculate creator tier and benefits
  static Map<String, dynamic> calculateCreatorTier(Map<String, dynamic> creatorStats) {
    final itemsCreated = creatorStats['items_created'] as int? ?? 0;
    final totalSales = creatorStats['total_sales'] as int? ?? 0;
    
    // Find appropriate tier
    final tiers = MarketplaceConstants.creatorTiers;
    Map<String, dynamic> currentTier = tiers.first;
    
    for (final tier in tiers.reversed) {
      final requirements = tier['requirements'] as Map<String, dynamic>;
      final requiredItems = requirements['items_created'] as int;
      final requiredSales = requirements['total_sales'] as int;
      
      if (itemsCreated >= requiredItems && totalSales >= requiredSales) {
        currentTier = tier;
        break;
      }
    }
    
    // Calculate progress to next tier
    Map<String, dynamic>? nextTier;
    final currentTierIndex = tiers.indexOf(currentTier);
    if (currentTierIndex < tiers.length - 1) {
      nextTier = tiers[currentTierIndex + 1];
    }
    
    Map<String, double>? progressToNext;
    if (nextTier != null) {
      final nextRequirements = nextTier['requirements'] as Map<String, dynamic>;
      final nextRequiredItems = nextRequirements['items_created'] as int;
      final nextRequiredSales = nextRequirements['total_sales'] as int;
      
      progressToNext = {
        'items_progress': itemsCreated / nextRequiredItems,
        'sales_progress': totalSales / nextRequiredSales,
      };
    }
    
    return {
      'current_tier': currentTier,
      'next_tier': nextTier,
      'progress_to_next': progressToNext,
      'tier_benefits': currentTier['benefits'],
      'revenue_share': currentTier['revenue_share'],
    };
  }
  
  /// Generate seasonal event items
  static List<Map<String, dynamic>> generateSeasonalItems(
    Map<String, dynamic> eventConfig,
    List<String> userInterests,
  ) {
    final seasonalItems = <Map<String, dynamic>>[];
    final eventItems = eventConfig['special_items'] as List<String>? ?? [];
    
    for (final itemType in eventItems) {
      seasonalItems.add({
        'id': 'seasonal_${DateTime.now().millisecondsSinceEpoch}_${seasonalItems.length}',
        'name': StringUtils.capitalizeWords(itemType.replaceAll('_', ' ')),
        'type': itemType,
        'rarity': _getSeasonalRarity(eventConfig),
        'event_exclusive': true,
        'available_until': DateTime.now().add(Duration(days: eventConfig['duration_days'] as int)),
        'special_effects': eventConfig['bonus_effects'],
        'price_modifier': 0.8, // 20% discount for seasonal items
      });
    }
    
    return seasonalItems;
  }
  
  static String _getSeasonalRarity(Map<String, dynamic> eventConfig) {
    // Seasonal items tend to be more special
    final rarities = [
      MarketplaceConstants.uncommon,
      MarketplaceConstants.rare,
      MarketplaceConstants.epic,
    ];
    return rarities[MathUtils.randomInt(0, rarities.length - 1)];
  }
  
  /// Validate item creation
  static Map<String, String?> validateItemCreation(Map<String, dynamic> itemData) {
    final errors = <String, String?>{};
    
    final name = itemData['name'] as String?;
    if (name == null || name.trim().isEmpty) {
      errors['name'] = 'Item name is required';
    } else if (name.length > MarketplaceConstants.maxItemNameLength) {
      errors['name'] = 'Item name is too long';
    }
    
    final description = itemData['description'] as String?;
    if (description != null && description.length > MarketplaceConstants.maxItemDescriptionLength) {
      errors['description'] = 'Description is too long';
    }
    
    final price = itemData['price'] as double?;
    if (price != null) {
      if (price < MarketplaceConstants.minItemPrice) {
        errors['price'] = 'Price is too low';
      } else if (price > MarketplaceConstants.maxItemPrice) {
        errors['price'] = 'Price is too high';
      }
    }
    
    final tags = itemData['tags'] as List<String>?;
    if (tags != null && tags.length > MarketplaceConstants.maxTagsPerItem) {
      errors['tags'] = 'Too many tags';
    }
    
    final images = itemData['images'] as List<String>?;
    if (images != null && images.length > MarketplaceConstants.maxImagesPerItem) {
      errors['images'] = 'Too many images';
    }
    
    return errors;
  }
  
  /// Get rarity color for UI display
  static String getRarityColor(String rarity) {
    switch (rarity) {
      case MarketplaceConstants.common:
        return '#74B9FF';
      case MarketplaceConstants.uncommon:
        return '#00B894';
      case MarketplaceConstants.rare:
        return '#FFB020';
      case MarketplaceConstants.epic:
        return '#6C5CE7';
      case MarketplaceConstants.legendary:
        return '#E17055';
      case MarketplaceConstants.mythical:
        return '#FF7675';
      default:
        return '#95A5A6';
    }
  }
  
  /// Format price for display
  static String formatPrice(Map<String, int> price) {
    final parts = <String>[];
    
    if (price[MarketplaceConstants.gold]! > 0) {
      parts.add('${StringUtils.formatNumber(price[MarketplaceConstants.gold]!)} Gold');
    }
    
    if (price[MarketplaceConstants.gems]! > 0) {
      parts.add('${price[MarketplaceConstants.gems]!} Gems');
    }
    
    if (price[MarketplaceConstants.tokens]! > 0) {
      parts.add('${price[MarketplaceConstants.tokens]!} Tokens');
    }
    
    return parts.join(' + ');
  }
}
