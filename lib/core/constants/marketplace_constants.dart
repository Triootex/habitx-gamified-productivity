class MarketplaceConstants {
  // Item Categories
  static const String avatars = 'avatars';
  static const String themes = 'themes';
  static const String sounds = 'sounds';
  static const String animations = 'animations';
  static const String powerUps = 'power_ups';
  static const String badges = 'badges';
  static const String backgrounds = 'backgrounds';
  static const String effects = 'effects';
  
  // Item Rarity Levels
  static const String common = 'common';
  static const String uncommon = 'uncommon';
  static const String rare = 'rare';
  static const String epic = 'epic';
  static const String legendary = 'legendary';
  static const String mythical = 'mythical';
  
  // Currency Types
  static const String gold = 'gold';
  static const String gems = 'gems';
  static const String premium = 'premium';
  static const String tokens = 'tokens';
  
  // Item Types
  static const String consumable = 'consumable';
  static const String permanent = 'permanent';
  static const String temporary = 'temporary';
  static const String subscription = 'subscription';
  
  // Trading Status
  static const String available = 'available';
  static const String sold = 'sold';
  static const String reserved = 'reserved';
  static const String expired = 'expired';
  
  // Custom Item Creation Tools
  static const List<Map<String, dynamic>> creationTools = [
    {
      'tool': 'Avatar Creator',
      'description': 'Design custom character appearances',
      'features': ['hair_styles', 'clothing', 'accessories', 'poses'],
      'skill_level': 'beginner',
    },
    {
      'tool': 'Theme Designer',
      'description': 'Create custom app themes and color schemes',
      'features': ['color_palettes', 'typography', 'layouts', 'icons'],
      'skill_level': 'intermediate',
    },
    {
      'tool': 'Animation Studio',
      'description': 'Build custom animations and transitions',
      'features': ['frame_editor', 'timeline', 'effects', 'export'],
      'skill_level': 'advanced',
    },
    {
      'tool': 'Sound Mixer',
      'description': 'Compose custom sounds and music',
      'features': ['waveform_editor', 'effects', 'layering', 'export'],
      'skill_level': 'intermediate',
    },
  ];
  
  // AI Asset Generation Categories
  static const List<Map<String, dynamic>> aiGenerationCategories = [
    {
      'category': 'Character Portraits',
      'styles': ['anime', 'realistic', 'cartoon', 'pixel_art', 'fantasy'],
      'attributes': ['gender', 'age', 'ethnicity', 'expression', 'clothing'],
    },
    {
      'category': 'Backgrounds',
      'styles': ['landscape', 'abstract', 'minimalist', 'fantasy', 'sci_fi'],
      'attributes': ['time_of_day', 'weather', 'mood', 'color_scheme'],
    },
    {
      'category': 'Icons',
      'styles': ['flat', 'outlined', '3d', 'gradient', 'hand_drawn'],
      'attributes': ['size', 'color', 'style', 'category'],
    },
    {
      'category': 'Patterns',
      'styles': ['geometric', 'organic', 'tribal', 'modern', 'vintage'],
      'attributes': ['complexity', 'color_count', 'repetition', 'scale'],
    },
  ];
  
  // Pricing Tiers
  static const Map<String, Map<String, int>> pricingTiers = {
    common: {
      gold: 50,
      gems: 5,
      tokens: 10,
    },
    uncommon: {
      gold: 150,
      gems: 15,
      tokens: 25,
    },
    rare: {
      gold: 500,
      gems: 50,
      tokens: 75,
    },
    epic: {
      gold: 1500,
      gems: 150,
      tokens: 200,
    },
    legendary: {
      gold: 5000,
      gems: 500,
      tokens: 600,
    },
    mythical: {
      gold: 15000,
      gems: 1500,
      tokens: 1800,
    },
  };
  
  // Item Abilities and Effects
  static const List<Map<String, dynamic>> itemAbilities = [
    {
      'ability': 'XP Boost',
      'description': 'Increases XP gain by specified percentage',
      'parameters': {'multiplier': 1.5, 'duration': 3600}, // 1 hour
      'rarity_requirement': common,
    },
    {
      'ability': 'Gold Magnet',
      'description': 'Automatically collects bonus gold from completed tasks',
      'parameters': {'bonus_percentage': 0.25, 'duration': -1}, // Permanent
      'rarity_requirement': uncommon,
    },
    {
      'ability': 'Streak Shield',
      'description': 'Protects habit streaks from being broken',
      'parameters': {'protection_days': 1, 'uses': 3},
      'rarity_requirement': rare,
    },
    {
      'ability': 'Time Warp',
      'description': 'Extends deadline for tasks by specified time',
      'parameters': {'extension_hours': 24, 'uses': 5},
      'rarity_requirement': epic,
    },
    {
      'ability': 'Motivation Aura',
      'description': 'Increases completion rate for all activities',
      'parameters': {'completion_boost': 0.15, 'duration': 86400}, // 24 hours
      'rarity_requirement': legendary,
    },
    {
      'ability': 'Master Key',
      'description': 'Instantly completes any single task or habit',
      'parameters': {'uses': 1, 'restrictions': 'non_premium_tasks'},
      'rarity_requirement': mythical,
    },
  ];
  
  // Trading Mechanics
  static const Map<String, dynamic> tradingRules = {
    'min_user_level': 5,
    'max_items_per_trade': 5,
    'trade_cooldown_hours': 24,
    'commission_percentage': 0.05, // 5% marketplace fee
    'escrow_duration_hours': 72,
  };
  
  // Item Creation Requirements
  static const Map<String, Map<String, dynamic>> creationRequirements = {
    'avatar': {
      'min_level': 3,
      'required_skills': ['creativity_level_1'],
      'cost': {gold: 100, gems: 10},
      'time_hours': 2,
    },
    'theme': {
      'min_level': 5,
      'required_skills': ['design_level_2'],
      'cost': {gold: 250, gems: 25},
      'time_hours': 4,
    },
    'animation': {
      'min_level': 10,
      'required_skills': ['animation_level_3'],
      'cost': {gold: 500, gems: 50},
      'time_hours': 8,
    },
    'sound': {
      'min_level': 7,
      'required_skills': ['audio_level_2'],
      'cost': {gold: 300, gems: 30},
      'time_hours': 3,
    },
  };
  
  // Quality Assurance
  static const Map<String, dynamic> qualityStandards = {
    'image_requirements': {
      'min_resolution': {'width': 256, 'height': 256},
      'max_file_size_mb': 5,
      'allowed_formats': ['png', 'jpg', 'svg'],
      'transparency_support': true,
    },
    'audio_requirements': {
      'min_duration_seconds': 1,
      'max_duration_seconds': 300,
      'max_file_size_mb': 10,
      'allowed_formats': ['mp3', 'wav', 'ogg'],
      'sample_rate_hz': 44100,
    },
    'animation_requirements': {
      'min_frames': 2,
      'max_frames': 120,
      'max_file_size_mb': 15,
      'allowed_formats': ['gif', 'webp', 'mp4'],
      'fps_range': {'min': 12, 'max': 60},
    },
  };
  
  // Marketplace Categories
  static const List<Map<String, dynamic>> marketplaceCategories = [
    {
      'category': 'Productivity Boosters',
      'items': ['xp_multipliers', 'streak_shields', 'auto_completers'],
      'popularity': 0.9,
    },
    {
      'category': 'Visual Customization',
      'items': ['themes', 'avatars', 'backgrounds', 'icons'],
      'popularity': 0.8,
    },
    {
      'category': 'Audio Enhancement',
      'items': ['notification_sounds', 'ambient_music', 'voice_packs'],
      'popularity': 0.6,
    },
    {
      'category': 'Special Effects',
      'items': ['particle_effects', 'screen_transitions', 'celebrations'],
      'popularity': 0.7,
    },
    {
      'category': 'Utility Tools',
      'items': ['widgets', 'shortcuts', 'integrations'],
      'popularity': 0.5,
    },
  ];
  
  // Revenue Sharing Model
  static const Map<String, double> revenueSharing = {
    'creator_percentage': 0.70, // 70% to item creator
    'platform_percentage': 0.25, // 25% to platform
    'promotion_fund_percentage': 0.05, // 5% for promotion
  };
  
  // Featured Items Rotation
  static const Map<String, dynamic> featuredItemsConfig = {
    'rotation_hours': 24,
    'max_featured_items': 8,
    'featured_boost_multiplier': 1.5,
    'selection_criteria': {
      'popularity_weight': 0.4,
      'recent_sales_weight': 0.3,
      'creator_level_weight': 0.2,
      'randomness_weight': 0.1,
    },
  };
  
  // Item Rating System
  static const List<Map<String, dynamic>> ratingCriteria = [
    {
      'criterion': 'Quality',
      'description': 'Overall visual/audio quality and craftsmanship',
      'weight': 0.4,
    },
    {
      'criterion': 'Originality',
      'description': 'Uniqueness and creativity of the design',
      'weight': 0.3,
    },
    {
      'criterion': 'Functionality',
      'description': 'How well the item serves its intended purpose',
      'weight': 0.2,
    },
    {
      'criterion': 'Appeal',
      'description': 'General aesthetic appeal and attractiveness',
      'weight': 0.1,
    },
  ];
  
  // Seasonal Events and Limited Items
  static const List<Map<String, dynamic>> seasonalEvents = [
    {
      'event': 'Diwali Festival',
      'duration_days': 7,
      'special_items': ['diwali_avatar', 'lamp_animation', 'festive_theme'],
      'bonus_effects': {'xp_multiplier': 1.2, 'special_currency': 'festival_tokens'},
    },
    {
      'event': 'New Year Challenge',
      'duration_days': 14,
      'special_items': ['resolution_badge', 'countdown_effect', 'motivational_sounds'],
      'bonus_effects': {'goal_completion_bonus': 0.5},
    },
    {
      'event': 'Summer Productivity',
      'duration_days': 30,
      'special_items': ['summer_themes', 'beach_backgrounds', 'sunny_avatars'],
      'bonus_effects': {'outdoor_activity_bonus': 0.3},
    },
  ];
  
  // Creator Program Tiers
  static const List<Map<String, dynamic>> creatorTiers = [
    {
      'tier': 'Novice Creator',
      'requirements': {'items_created': 1, 'total_sales': 0},
      'benefits': ['basic_tools_access', 'community_forum'],
      'revenue_share': 0.6,
    },
    {
      'tier': 'Skilled Creator',
      'requirements': {'items_created': 10, 'total_sales': 1000},
      'benefits': ['advanced_tools', 'priority_review', 'featured_eligibility'],
      'revenue_share': 0.7,
    },
    {
      'tier': 'Master Creator',
      'requirements': {'items_created': 50, 'total_sales': 10000},
      'benefits': ['exclusive_tools', 'direct_promotion', 'beta_access'],
      'revenue_share': 0.8,
    },
    {
      'tier': 'Legendary Creator',
      'requirements': {'items_created': 100, 'total_sales': 50000},
      'benefits': ['custom_events', 'revenue_insights', 'mentorship_program'],
      'revenue_share': 0.85,
    },
  ];
  
  // Asset Library Integration
  static const Map<String, dynamic> assetLibrary = {
    'free_assets': {
      'basic_shapes': 100,
      'simple_patterns': 50,
      'common_icons': 200,
      'basic_sounds': 75,
    },
    'premium_assets': {
      'advanced_shapes': 500,
      'complex_patterns': 200,
      'professional_icons': 1000,
      'high_quality_sounds': 300,
    },
    'user_uploads': {
      'max_uploads_per_month': 20,
      'storage_limit_mb': 100,
      'moderation_required': true,
    },
  };
  
  // Notification Types
  static const String itemSold = 'item_sold';
  static const String itemPurchased = 'item_purchased';
  static const String tradeProposed = 'trade_proposed';
  static const String tradeAccepted = 'trade_accepted';
  static const String itemFeatured = 'item_featured';
  static const String creatorLevelUp = 'creator_level_up';
  static const String seasonalEventStart = 'seasonal_event_start';
  static const String limitedItemAvailable = 'limited_item_available';
  
  // Validation Rules
  static const int maxItemNameLength = 50;
  static const int maxItemDescriptionLength = 500;
  static const int maxTagsPerItem = 10;
  static const int maxImagesPerItem = 5;
  static const double minItemPrice = 1.0;
  static const double maxItemPrice = 100000.0;
  static const int maxItemsPerUser = 1000;
  static const int maxTradesPerDay = 10;
  
  // Search and Filter Options
  static const List<String> sortOptions = [
    'newest',
    'oldest',
    'price_low_to_high',
    'price_high_to_low',
    'popularity',
    'rating',
    'most_sold',
  ];
  
  static const List<String> filterCategories = [
    'category',
    'rarity',
    'price_range',
    'creator',
    'date_created',
    'has_abilities',
    'is_tradeable',
  ];
}
