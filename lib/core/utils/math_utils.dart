import 'dart:math' as math;

class MathUtils {
  static final _random = math.Random();
  
  /// Generate random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }
  
  /// Generate random double between min and max
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
  
  /// Calculate XP required for level
  static int calculateXpForLevel(int level) {
    return (level * 100 * (1 + level * 0.1)).round();
  }
  
  /// Calculate level from XP
  static int calculateLevelFromXp(int xp) {
    int level = 1;
    while (calculateXpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }
  
  /// Calculate XP progress to next level
  static double calculateLevelProgress(int xp) {
    final currentLevel = calculateLevelFromXp(xp);
    final currentLevelXp = calculateXpForLevel(currentLevel);
    final nextLevelXp = calculateXpForLevel(currentLevel + 1);
    return (xp - currentLevelXp) / (nextLevelXp - currentLevelXp);
  }
  
  /// Calculate streak multiplier
  static double calculateStreakMultiplier(int streak) {
    if (streak < 3) return 1.0;
    if (streak < 7) return 1.2;
    if (streak < 14) return 1.5;
    if (streak < 30) return 2.0;
    return 2.5;
  }
  
  /// Calculate reward based on difficulty
  static Map<String, int> calculateReward(String difficulty, {bool isPremium = false}) {
    final baseRewards = {
      'easy': {'xp': 10, 'gold': 5},
      'medium': {'xp': 50, 'gold': 15},
      'hard': {'xp': 100, 'gold': 30},
      'very_hard': {'xp': 200, 'gold': 50},
    };
    
    final base = baseRewards[difficulty]!;
    final multiplier = isPremium ? 1.5 : 1.0;
    
    return {
      'xp': (base['xp']! * multiplier * (0.8 + _random.nextDouble() * 0.4)).round(),
      'gold': (base['gold']! * multiplier * (0.8 + _random.nextDouble() * 0.4)).round(),
    };
  }
  
  /// Calculate rarity from random roll
  static String calculateRarity(double roll, String difficulty) {
    final premiumBonus = 0.0; // This would be set based on premium status
    final adjustedRoll = roll + premiumBonus;
    
    final difficultyMultiplier = {
      'easy': 1.0,
      'medium': 1.2,
      'hard': 1.5,
      'very_hard': 2.0,
    }[difficulty] ?? 1.0;
    
    final thresholds = {
      'common': 0.60 / difficultyMultiplier,
      'uncommon': 0.85 / difficultyMultiplier,
      'rare': 0.95 / difficultyMultiplier,
      'ultra_rare': 0.99 / difficultyMultiplier,
      'legendary': 0.998 / difficultyMultiplier,
      'mythical': 1.0,
    };
    
    if (adjustedRoll <= thresholds['common']!) return 'common';
    if (adjustedRoll <= thresholds['uncommon']!) return 'uncommon';
    if (adjustedRoll <= thresholds['rare']!) return 'rare';
    if (adjustedRoll <= thresholds['ultra_rare']!) return 'ultra_rare';
    if (adjustedRoll <= thresholds['legendary']!) return 'legendary';
    return 'mythical';
  }
  
  /// Calculate item quantity based on rarity
  static int calculateItemQuantity(String rarity) {
    final ranges = {
      'common': [1, 2],
      'uncommon': [2, 3],
      'rare': [2, 3],
      'ultra_rare': [2, 3],
      'legendary': [3, 4],
      'mythical': [4, 5],
    };
    
    final range = ranges[rarity] ?? [1, 1];
    return randomInt(range[0], range[1]);
  }
  
  /// Calculate distance between two points
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLon = (lon2 - lon1) * math.pi / 180;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }
  
  /// Calculate BMI
  static double calculateBMI(double weightKg, double heightM) {
    return weightKg / (heightM * heightM);
  }
  
  /// Calculate BMR (Basal Metabolic Rate)
  static double calculateBMR(double weightKg, double heightCm, int age, bool isMale) {
    if (isMale) {
      return 88.362 + (13.397 * weightKg) + (4.799 * heightCm) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weightKg) + (3.098 * heightCm) - (4.330 * age);
    }
  }
  
  /// Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(double bmr, String activityLevel) {
    final multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    
    return bmr * (multipliers[activityLevel] ?? 1.2);
  }
  
  /// Calculate percentage
  static double calculatePercentage(num value, num total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }
  
  /// Clamp value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
  
  /// Linear interpolation
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
  
  /// Map value from one range to another
  static double mapValue(double value, double inMin, double inMax, double outMin, double outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }
  
  /// Round to decimal places
  static double roundToDecimal(double value, int decimalPlaces) {
    final multiplier = math.pow(10, decimalPlaces);
    return (value * multiplier).round() / multiplier;
  }
  
  /// Calculate average
  static double calculateAverage(List<num> values) {
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }
  
  /// Calculate median
  static double calculateMedian(List<num> values) {
    if (values.isEmpty) return 0.0;
    final sorted = List<num>.from(values)..sort();
    final middle = sorted.length ~/ 2;
    
    if (sorted.length % 2 == 1) {
      return sorted[middle].toDouble();
    } else {
      return (sorted[middle - 1] + sorted[middle]) / 2;
    }
  }
  
  /// Calculate standard deviation
  static double calculateStandardDeviation(List<num> values) {
    if (values.isEmpty) return 0.0;
    final mean = calculateAverage(values);
    final variance = values
        .map((x) => math.pow(x - mean, 2))
        .reduce((a, b) => a + b) / values.length;
    return math.sqrt(variance);
  }
  
  /// Generate weighted random choice
  static T weightedRandomChoice<T>(Map<T, double> weights) {
    final totalWeight = weights.values.reduce((a, b) => a + b);
    double randomValue = _random.nextDouble() * totalWeight;
    
    for (final entry in weights.entries) {
      randomValue -= entry.value;
      if (randomValue <= 0) {
        return entry.key;
      }
    }
    
    return weights.keys.first;
  }
  
  /// Check if number is prime
  static bool isPrime(int number) {
    if (number < 2) return false;
    for (int i = 2; i <= math.sqrt(number); i++) {
      if (number % i == 0) return false;
    }
    return true;
  }
  
  /// Calculate factorial
  static int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
  }
  
  /// Calculate Fibonacci number
  static int fibonacci(int n) {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
  }
}
