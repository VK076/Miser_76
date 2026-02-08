import 'package:flutter/material.dart';

/// Category model for expenses
/// Each category has a name, icon, color, and emoji for display
class Category {
  final String name;
  final IconData icon;
  final Color color;
  final String emoji;

  const Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}

/// All available expense categories
class CategoryManager {
  static const List<Category> allCategories = [
    // Food & Dining
    Category(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFF87171), // Red
      emoji: '🍔',
    ),
    Category(
      name: 'Groceries',
      icon: Icons.shopping_cart,
      color: Color(0xFFFA8072), // Salmon
      emoji: '🛒',
    ),

    // Transportation
    Category(
      name: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF60A5FA), // Blue
      emoji: '🚗',
    ),
    Category(
      name: 'Fuel',
      icon: Icons.local_gas_station,
      color: Color(0xFF3B82F6), // Darker Blue
      emoji: '⛽',
    ),
    Category(
      name: 'Parking',
      icon: Icons.location_on,
      color: Color(0xFF0EA5E9), // Cyan
      emoji: '🅿️',
    ),

    // Entertainment
    Category(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFA78BFA), // Purple
      emoji: '🎬',
    ),
    Category(
      name: 'Streaming',
      icon: Icons.subscriptions,
      color: Color(0xFF8B5CF6), // Darker Purple
      emoji: '📺',
    ),
    Category(
      name: 'Gaming',
      icon: Icons.games,
      color: Color(0xFFA855F7), // Orchid
      emoji: '🎮',
    ),

    // Shopping
    Category(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFFB7185), // Pink
      emoji: '🛍️',
    ),
    Category(
      name: 'Clothing',
      icon: Icons.checkroom,
      color: Color(0xFFF43F5E), // Hot Pink
      emoji: '👕',
    ),
    Category(
      name: 'Electronics',
      icon: Icons.devices,
      color: Color(0xFFEC4899), // Deep Pink
      emoji: '📱',
    ),

    // Utilities & Bills
    Category(
      name: 'Electricity',
      icon: Icons.bolt,
      color: Color(0xFFFCD34D), // Yellow
      emoji: '⚡',
    ),
    Category(
      name: 'Water',
      icon: Icons.water_drop,
      color: Color(0xFF06B6D4), // Cyan
      emoji: '💧',
    ),
    Category(
      name: 'Internet',
      icon: Icons.wifi,
      color: Color(0xFF14B8A6), // Teal
      emoji: '📡',
    ),
    Category(
      name: 'Phone Bill',
      icon: Icons.phone,
      color: Color(0xFF06B6D4), // Cyan
      emoji: '📞',
    ),

    // Health & Medical
    Category(
      name: 'Health',
      icon: Icons.local_hospital,
      color: Color(0xFF4ADE80), // Green
      emoji: '💊',
    ),
    Category(
      name: 'Fitness',
      icon: Icons.fitness_center,
      color: Color(0xFF22C55E), // Darker Green
      emoji: '💪',
    ),
    Category(
      name: 'Medicine',
      icon: Icons.medical_services,
      color: Color(0xFF16A34A), // Forest Green
      emoji: '💉',
    ),

    // Subscriptions & Services
    Category(
      name: 'Subscriptions',
      icon: Icons.card_membership,
      color: Color(0xFFA78BFA), // Purple
      emoji: '📋',
    ),
    Category(
      name: 'Insurance',
      icon: Icons.security,
      color: Color(0xFF8B5CF6), // Darker Purple
      emoji: '🛡️',
    ),

    // Personal Care
    Category(
      name: 'Personal Care',
      icon: Icons.spa,
      color: Color(0xFFD946EF), // Magenta
      emoji: '💅',
    ),

    // Education
    Category(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF0EA5E9), // Sky Blue
      emoji: '📚',
    ),

    // Work
    Category(
      name: 'Work',
      icon: Icons.work,
      color: Color(0xFFF97316), // Orange
      emoji: '💼',
    ),

    // Travel
    Category(
      name: 'Travel',
      icon: Icons.flight,
      color: Color(0xFF06B6D4), // Cyan
      emoji: '✈️',
    ),
    Category(
      name: 'Hotels',
      icon: Icons.hotel,
      color: Color(0xFF14B8A6), // Teal
      emoji: '🏨',
    ),

    // Miscellaneous
    Category(
      name: 'Other',
      icon: Icons.category,
      color: Color(0xFF64748B), // Slate
      emoji: '💰',
    ),
  ];

  /// Get category by name
  static Category? getCategoryByName(String name) {
    try {
      return allCategories.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return allCategories.last; // Return "Other" if not found
    }
  }

  /// Get all category names
  static List<String> getCategoryNames() {
    return allCategories.map((cat) => cat.name).toList();
  }
}
