import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Cyan/Teal
  static const Color primary = Color(0xFF06B6D4); // Cyan 500
  static const Color primaryLight = Color(0xFF22D3EE); // Cyan 400
  static const Color primaryDark = Color(0xFF0891B2); // Cyan 600

  // Accent colors - Vibrant and modern
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFF43F5E); // Rose 500
  static const Color warning = Color(0xFFFBBF24); // Amber 400
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Light Mode - Neutral colors
  static const Color background = Color(0xFFF8FAFC);   // Slate 50
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color border = Color(0xFFE2E8F0);       // Slate 200
  static const Color textPrimary = Color(0xFF0F172A);  // Slate 900
  static const Color textSecondary = Color(0xFF64748B);// Slate 500

  // Dark Mode - Deeper, richer colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkBorder = Color(0xFF334155);     // Slate 700
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Slate 100
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  // Category colors - More vibrant and distinct
  static const Color foodColor = Color(0xFFEF4444);    // Red 500
  static const Color transportColor = Color(0xFF3B82F6);// Blue 500
  static const Color entertainmentColor = Color(0xFFA855F7);// Purple 500
  static const Color utilitiesColor = Color(0xFFF59E0B);// Amber 500
  static const Color shoppingColor = Color(0xFFEC4899);// Pink 500
  static const Color healthColor = Color(0xFF10B981); // Emerald 500
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF06B6D4), // Cyan 500
    Color(0xFF0891B2), // Cyan 600
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF10B981), // Emerald 500
    Color(0xFF059669), // Emerald 600
  ];
  
  // Shadow colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowDark = Color(0x33000000); // 20% black
}

class AppStrings {
    //Login Screen
    static const String appName = 'FinTrack';
    static const String appTagline = 'Track your expenses smartly';
    static const String emailHint = 'Enter your email';
    static const String passwordHint = 'Enter your password';
    static const String loginButton = 'Login';
    static const String forgotPassword = 'Forgot Password?';
    static const String signUp = 'Don\'t have an account? Sign Up';
    
      // Dashboard
    static const String totalSpent = 'Total Spent';
    static const String thisMonth = 'This Month';
    static const String recentExpenses = 'Recent Expenses';
    static const String noExpenses = 'No expenses yet';
    
    // Categories
    static const String food = 'Food';
    static const String transport = 'Transport';
    static const String entertainment = 'Entertainment';
    static const String utilities = 'Utilities';
    static const String shopping = 'Shopping';
    static const String health = 'Health';
}

class AppAnimations {
  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

class AppDimensions {
  // Padding & Margins
  static const double paddingXSmall = 4;
  static const double paddingSmall = 8;
  static const double paddingMedium = 16;
  static const double paddingLarge = 24;
  static const double paddingXLarge = 32;
  
  // Border Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;
  
  // Font Sizes
  static const double fontSmall = 12;
  static const double fontMedium = 14;
  static const double fontLarge = 16;
  static const double fontXLarge = 18;
  static const double fontTitle = 24;
  static const double fontHeading = 32;
  
  // Elevation
  static const double elevationLow = 2;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;
}
