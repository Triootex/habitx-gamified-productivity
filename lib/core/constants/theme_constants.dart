import 'package:flutter/material.dart';

class ThemeConstants {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4FCF);
  static const Color primaryLight = Color(0xFF8B7EF7);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFFFF7675);
  static const Color secondaryDark = Color(0xFFE84142);
  static const Color secondaryLight = Color(0xFFFF9F9E);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Dark Theme Colors
  static const Color backgroundColorDark = Color(0xFF1A1A2E);
  static const Color surfaceColorDark = Color(0xFF16213E);
  static const Color cardColorDark = Color(0xFF0F1419);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  
  // Dark Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFDDD6FE);
  static const Color textTertiaryDark = Color(0xFFA8A8A8);
  
  // Status Colors
  static const Color successColor = Color(0xFF00B894);
  static const Color warningColor = Color(0xFFFFB020);
  static const Color errorColor = Color(0xFFE17055);
  static const Color infoColor = Color(0xFF74B9FF);
  
  // Rarity Colors
  static const Color commonColor = Color(0xFF74B9FF);
  static const Color uncommonColor = Color(0xFF00B894);
  static const Color rareColor = Color(0xFFFFB020);
  static const Color ultraRareColor = Color(0xFFE17055);
  static const Color legendaryColor = Color(0xFF6C5CE7);
  static const Color mythicalColor = Color(0xFFFF7675);
  
  // Category Colors
  static const Map<String, Color> categoryColors = {
    'todo': Color(0xFF3498DB),
    'habits': Color(0xFF2ECC71),
    'sleep': Color(0xFF9B59B6),
    'mental_health': Color(0xFFE74C3C),
    'flashcards': Color(0xFFF39C12),
    'fitness': Color(0xFF1ABC9C),
    'meditation': Color(0xFF34495E),
    'language': Color(0xFFE67E22),
    'budget': Color(0xFF27AE60),
    'reading': Color(0xFF8E44AD),
    'focus': Color(0xFFD35400),
    'journal': Color(0xFF2C3E50),
    'meals': Color(0xFFF1C40F),
  };
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [successColor, Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Font Sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;
  static const double fontSizeXXXL = 32.0;
  
  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXL = 48.0;
  
  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve fastCurve = Curves.fastOutSlowIn;
}
