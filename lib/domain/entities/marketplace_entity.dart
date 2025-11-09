import 'package:equatable/equatable.dart';

class MarketplaceItemEntity extends Equatable {
  final String id;
  final String creatorId;
  final String name;
  final String description;
  final String category; // avatar, theme, sound, animation, sticker, etc.
  final String itemType; // cosmetic, functional, consumable
  final String rarity; // common, uncommon, rare, epic, legendary
  final List<String> tags;
  
  // Pricing and currency
  final Map<String, int> price; // currency_type -> amount
  final bool isFree;
  final bool isPremiumOnly;
  final double? discountPercentage;
  final DateTime? discountValidUntil;
  final bool isLimitedEdition;
  final int? maxQuantity;
  final int currentStock;
  
  // Digital assets
  final List<String> assetUrls; // Images, animations, sounds
  final Map<String, dynamic> assetMetadata;
  final String? previewUrl;
  final List<String> thumbnails;
  final String? animationUrl;
  final String? soundUrl;
  
  // Item abilities and effects
  final Map<String, dynamic> abilities; // Special powers or effects
  final Map<String, double> statBoosts; // XP boost, luck boost, etc.
  final Duration? effectDuration;
  final bool isConsumable;
  final int? usageLimit;
  
  // AI generation data
  final bool isAIGenerated;
  final Map<String, dynamic> aiGenerationPrompt;
  final double? aiQualityScore;
  final String? aiModel;
  final List<String> aiGenerationSteps;
  
  // Creation and approval
  final String status; // draft, pending_review, approved, rejected, banned
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final List<String> moderationFlags;
  final Map<String, dynamic> qualityMetrics;
  
  // Market performance
  final int downloadCount;
  final int purchaseCount;
  final double rating;
  final int ratingCount;
  final List<String> reviews;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final int viewCount;
  final int favoriteCount;
  
  // Revenue and royalties
  final double revenueShare; // Percentage for creator
  final double totalRevenue;
  final double creatorEarnings;
  final Map<String, dynamic> salesData;
  
  // Compatibility and requirements
  final List<String> compatiblePlatforms;
  final Map<String, dynamic> systemRequirements;
  final String minAppVersion;
  final List<String> dependencies;
  
  final DateTime? updatedAt;

  const MarketplaceItemEntity({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.category,
    this.itemType = 'cosmetic',
    this.rarity = 'common',
    this.tags = const [],
    this.price = const {},
    this.isFree = true,
    this.isPremiumOnly = false,
    this.discountPercentage,
    this.discountValidUntil,
    this.isLimitedEdition = false,
    this.maxQuantity,
    this.currentStock = 999999,
    this.assetUrls = const [],
    this.assetMetadata = const {},
    this.previewUrl,
    this.thumbnails = const [],
    this.animationUrl,
    this.soundUrl,
    this.abilities = const {},
    this.statBoosts = const {},
    this.effectDuration,
    this.isConsumable = false,
    this.usageLimit,
    this.isAIGenerated = false,
    this.aiGenerationPrompt = const {},
    this.aiQualityScore,
    this.aiModel,
    this.aiGenerationSteps = const [],
    this.status = 'draft',
    required this.createdAt,
    this.approvedAt,
    this.rejectionReason,
    this.moderationFlags = const [],
    this.qualityMetrics = const {},
    this.downloadCount = 0,
    this.purchaseCount = 0,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.reviews = const [],
    this.isFeatured = false,
    this.featuredUntil,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.revenueShare = 0.7,
    this.totalRevenue = 0.0,
    this.creatorEarnings = 0.0,
    this.salesData = const {},
    this.compatiblePlatforms = const [],
    this.systemRequirements = const {},
    this.minAppVersion = '1.0.0',
    this.dependencies = const [],
    this.updatedAt,
  });

  bool get isApproved => status == 'approved';
  bool get isAvailable => isApproved && currentStock > 0;
  bool get hasDiscount => discountPercentage != null && discountValidUntil != null && 
      DateTime.now().isBefore(discountValidUntil!);
  bool get isPopular => downloadCount > 1000 || rating > 4.5;
  bool get isOutOfStock => !isFree && currentStock <= 0;

  int getDiscountedPrice(String currency) {
    final originalPrice = price[currency] ?? 0;
    if (!hasDiscount) return originalPrice;
    return (originalPrice * (1 - discountPercentage! / 100)).round();
  }

  MarketplaceItemEntity copyWith({
    String? id,
    String? creatorId,
    String? name,
    String? description,
    String? category,
    String? itemType,
    String? rarity,
    List<String>? tags,
    Map<String, int>? price,
    bool? isFree,
    bool? isPremiumOnly,
    double? discountPercentage,
    DateTime? discountValidUntil,
    bool? isLimitedEdition,
    int? maxQuantity,
    int? currentStock,
    List<String>? assetUrls,
    Map<String, dynamic>? assetMetadata,
    String? previewUrl,
    List<String>? thumbnails,
    String? animationUrl,
    String? soundUrl,
    Map<String, dynamic>? abilities,
    Map<String, double>? statBoosts,
    Duration? effectDuration,
    bool? isConsumable,
    int? usageLimit,
    bool? isAIGenerated,
    Map<String, dynamic>? aiGenerationPrompt,
    double? aiQualityScore,
    String? aiModel,
    List<String>? aiGenerationSteps,
    String? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? rejectionReason,
    List<String>? moderationFlags,
    Map<String, dynamic>? qualityMetrics,
    int? downloadCount,
    int? purchaseCount,
    double? rating,
    int? ratingCount,
    List<String>? reviews,
    bool? isFeatured,
    DateTime? featuredUntil,
    int? viewCount,
    int? favoriteCount,
    double? revenueShare,
    double? totalRevenue,
    double? creatorEarnings,
    Map<String, dynamic>? salesData,
    List<String>? compatiblePlatforms,
    Map<String, dynamic>? systemRequirements,
    String? minAppVersion,
    List<String>? dependencies,
    DateTime? updatedAt,
  }) {
    return MarketplaceItemEntity(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      itemType: itemType ?? this.itemType,
      rarity: rarity ?? this.rarity,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      isPremiumOnly: isPremiumOnly ?? this.isPremiumOnly,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountValidUntil: discountValidUntil ?? this.discountValidUntil,
      isLimitedEdition: isLimitedEdition ?? this.isLimitedEdition,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      currentStock: currentStock ?? this.currentStock,
      assetUrls: assetUrls ?? this.assetUrls,
      assetMetadata: assetMetadata ?? this.assetMetadata,
      previewUrl: previewUrl ?? this.previewUrl,
      thumbnails: thumbnails ?? this.thumbnails,
      animationUrl: animationUrl ?? this.animationUrl,
      soundUrl: soundUrl ?? this.soundUrl,
      abilities: abilities ?? this.abilities,
      statBoosts: statBoosts ?? this.statBoosts,
      effectDuration: effectDuration ?? this.effectDuration,
      isConsumable: isConsumable ?? this.isConsumable,
      usageLimit: usageLimit ?? this.usageLimit,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      aiGenerationPrompt: aiGenerationPrompt ?? this.aiGenerationPrompt,
      aiQualityScore: aiQualityScore ?? this.aiQualityScore,
      aiModel: aiModel ?? this.aiModel,
      aiGenerationSteps: aiGenerationSteps ?? this.aiGenerationSteps,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      moderationFlags: moderationFlags ?? this.moderationFlags,
      qualityMetrics: qualityMetrics ?? this.qualityMetrics,
      downloadCount: downloadCount ?? this.downloadCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      reviews: reviews ?? this.reviews,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredUntil: featuredUntil ?? this.featuredUntil,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      revenueShare: revenueShare ?? this.revenueShare,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      creatorEarnings: creatorEarnings ?? this.creatorEarnings,
      salesData: salesData ?? this.salesData,
      compatiblePlatforms: compatiblePlatforms ?? this.compatiblePlatforms,
      systemRequirements: systemRequirements ?? this.systemRequirements,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      dependencies: dependencies ?? this.dependencies,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        name,
        description,
        category,
        itemType,
        rarity,
        tags,
        price,
        isFree,
        isPremiumOnly,
        discountPercentage,
        discountValidUntil,
        isLimitedEdition,
        maxQuantity,
        currentStock,
        assetUrls,
        assetMetadata,
        previewUrl,
        thumbnails,
        animationUrl,
        soundUrl,
        abilities,
        statBoosts,
        effectDuration,
        isConsumable,
        usageLimit,
        isAIGenerated,
        aiGenerationPrompt,
        aiQualityScore,
        aiModel,
        aiGenerationSteps,
        status,
        createdAt,
        approvedAt,
        rejectionReason,
        moderationFlags,
        qualityMetrics,
        downloadCount,
        purchaseCount,
        rating,
        ratingCount,
        reviews,
        isFeatured,
        featuredUntil,
        viewCount,
        favoriteCount,
        revenueShare,
        totalRevenue,
        creatorEarnings,
        salesData,
        compatiblePlatforms,
        systemRequirements,
        minAppVersion,
        dependencies,
        updatedAt,
      ];
}

class UserInventoryEntity extends Equatable {
  final String id;
  final String userId;
  final String itemId;
  final DateTime acquiredAt;
  final String acquisitionMethod; // purchase, reward, gift, promotion
  final int quantity;
  final int? usageCount;
  final DateTime? lastUsed;
  final bool isActive; // Currently equipped/using
  final bool isFavorite;
  final Map<String, dynamic> customization; // User customizations to the item
  final DateTime? expiresAt; // For time-limited items
  final String? giftedBy; // User ID if received as gift
  final Map<String, dynamic> metadata;

  const UserInventoryEntity({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.acquiredAt,
    this.acquisitionMethod = 'purchase',
    this.quantity = 1,
    this.usageCount,
    this.lastUsed,
    this.isActive = false,
    this.isFavorite = false,
    this.customization = const {},
    this.expiresAt,
    this.giftedBy,
    this.metadata = const {},
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get hasUsageLimit => usageCount != null;
  bool get isAvailable => !isExpired && quantity > 0;

  UserInventoryEntity copyWith({
    String? id,
    String? userId,
    String? itemId,
    DateTime? acquiredAt,
    String? acquisitionMethod,
    int? quantity,
    int? usageCount,
    DateTime? lastUsed,
    bool? isActive,
    bool? isFavorite,
    Map<String, dynamic>? customization,
    DateTime? expiresAt,
    String? giftedBy,
    Map<String, dynamic>? metadata,
  }) {
    return UserInventoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      acquisitionMethod: acquisitionMethod ?? this.acquisitionMethod,
      quantity: quantity ?? this.quantity,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      isActive: isActive ?? this.isActive,
      isFavorite: isFavorite ?? this.isFavorite,
      customization: customization ?? this.customization,
      expiresAt: expiresAt ?? this.expiresAt,
      giftedBy: giftedBy ?? this.giftedBy,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        itemId,
        acquiredAt,
        acquisitionMethod,
        quantity,
        usageCount,
        lastUsed,
        isActive,
        isFavorite,
        customization,
        expiresAt,
        giftedBy,
        metadata,
      ];
}

class MarketplaceTransactionEntity extends Equatable {
  final String id;
  final String buyerId;
  final String? sellerId; // For user-to-user trades
  final String itemId;
  final String transactionType; // purchase, trade, gift, refund
  final String status; // pending, completed, failed, refunded
  final Map<String, int> price; // currency -> amount
  final int quantity;
  final DateTime transactionDate;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic> paymentData;
  final String? giftMessage;
  final String? giftRecipientId;
  final Map<String, dynamic> metadata;

  const MarketplaceTransactionEntity({
    required this.id,
    required this.buyerId,
    this.sellerId,
    required this.itemId,
    this.transactionType = 'purchase',
    this.status = 'pending',
    required this.price,
    this.quantity = 1,
    required this.transactionDate,
    this.completedAt,
    this.failureReason,
    this.paymentData = const {},
    this.giftMessage,
    this.giftRecipientId,
    this.metadata = const {},
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isGift => giftRecipientId != null;
  bool get isTrade => transactionType == 'trade';

  MarketplaceTransactionEntity copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    String? itemId,
    String? transactionType,
    String? status,
    Map<String, int>? price,
    int? quantity,
    DateTime? transactionDate,
    DateTime? completedAt,
    String? failureReason,
    Map<String, dynamic>? paymentData,
    String? giftMessage,
    String? giftRecipientId,
    Map<String, dynamic>? metadata,
  }) {
    return MarketplaceTransactionEntity(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      itemId: itemId ?? this.itemId,
      transactionType: transactionType ?? this.transactionType,
      status: status ?? this.status,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      transactionDate: transactionDate ?? this.transactionDate,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
      paymentData: paymentData ?? this.paymentData,
      giftMessage: giftMessage ?? this.giftMessage,
      giftRecipientId: giftRecipientId ?? this.giftRecipientId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        buyerId,
        sellerId,
        itemId,
        transactionType,
        status,
        price,
        quantity,
        transactionDate,
        completedAt,
        failureReason,
        paymentData,
        giftMessage,
        giftRecipientId,
        metadata,
      ];
}

class CreatorProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? profileImageUrl;
  final String? bannerImageUrl;
  final List<String> specialties; // What they create
  final Map<String, String> socialLinks;
  
  // Creator statistics
  final int totalItems;
  final int approvedItems;
  final int totalDownloads;
  final int totalPurchases;
  final double averageRating;
  final double totalEarnings;
  final int followerCount;
  final int followingCount;
  
  // Creator tier and benefits
  final String tier; // bronze, silver, gold, platinum, diamond
  final List<String> badges;
  final Map<String, dynamic> tierBenefits;
  final DateTime? tierExpiresAt;
  
  // Verification and status
  final bool isVerified;
  final bool isPartner;
  final bool isFeatured;
  final String status; // active, suspended, banned
  final DateTime? suspendedUntil;
  final List<String> suspensionReasons;
  
  // Creator tools access
  final Map<String, bool> toolAccess;
  final List<String> aiModelAccess;
  final Map<String, int> creationLimits;
  
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CreatorProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.profileImageUrl,
    this.bannerImageUrl,
    this.specialties = const [],
    this.socialLinks = const {},
    this.totalItems = 0,
    this.approvedItems = 0,
    this.totalDownloads = 0,
    this.totalPurchases = 0,
    this.averageRating = 0.0,
    this.totalEarnings = 0.0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.tier = 'bronze',
    this.badges = const [],
    this.tierBenefits = const {},
    this.tierExpiresAt,
    this.isVerified = false,
    this.isPartner = false,
    this.isFeatured = false,
    this.status = 'active',
    this.suspendedUntil,
    this.suspensionReasons = const [],
    this.toolAccess = const {},
    this.aiModelAccess = const [],
    this.creationLimits = const {},
    required this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended' && (suspendedUntil == null || DateTime.now().isBefore(suspendedUntil!));
  bool get canCreateItems => isActive && !isSuspended;

  CreatorProfileEntity copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? profileImageUrl,
    String? bannerImageUrl,
    List<String>? specialties,
    Map<String, String>? socialLinks,
    int? totalItems,
    int? approvedItems,
    int? totalDownloads,
    int? totalPurchases,
    double? averageRating,
    double? totalEarnings,
    int? followerCount,
    int? followingCount,
    String? tier,
    List<String>? badges,
    Map<String, dynamic>? tierBenefits,
    DateTime? tierExpiresAt,
    bool? isVerified,
    bool? isPartner,
    bool? isFeatured,
    String? status,
    DateTime? suspendedUntil,
    List<String>? suspensionReasons,
    Map<String, bool>? toolAccess,
    List<String>? aiModelAccess,
    Map<String, int>? creationLimits,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreatorProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      specialties: specialties ?? this.specialties,
      socialLinks: socialLinks ?? this.socialLinks,
      totalItems: totalItems ?? this.totalItems,
      approvedItems: approvedItems ?? this.approvedItems,
      totalDownloads: totalDownloads ?? this.totalDownloads,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      averageRating: averageRating ?? this.averageRating,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      tier: tier ?? this.tier,
      badges: badges ?? this.badges,
      tierBenefits: tierBenefits ?? this.tierBenefits,
      tierExpiresAt: tierExpiresAt ?? this.tierExpiresAt,
      isVerified: isVerified ?? this.isVerified,
      isPartner: isPartner ?? this.isPartner,
      isFeatured: isFeatured ?? this.isFeatured,
      status: status ?? this.status,
      suspendedUntil: suspendedUntil ?? this.suspendedUntil,
      suspensionReasons: suspensionReasons ?? this.suspensionReasons,
      toolAccess: toolAccess ?? this.toolAccess,
      aiModelAccess: aiModelAccess ?? this.aiModelAccess,
      creationLimits: creationLimits ?? this.creationLimits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        bio,
        profileImageUrl,
        bannerImageUrl,
        specialties,
        socialLinks,
        totalItems,
        approvedItems,
        totalDownloads,
        totalPurchases,
        averageRating,
        totalEarnings,
        followerCount,
        followingCount,
        tier,
        badges,
        tierBenefits,
        tierExpiresAt,
        isVerified,
        isPartner,
        isFeatured,
        status,
        suspendedUntil,
        suspensionReasons,
        toolAccess,
        aiModelAccess,
        creationLimits,
        createdAt,
        updatedAt,
      ];
}
