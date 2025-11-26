import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';

class DailyNutritionModel {
  final String date;
  final List<MealEntryModel> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFats;
  final DateTime createdAt;

  DailyNutritionModel({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DailyNutritionModel.fromJson(Map<String, dynamic> json) {
    return DailyNutritionModel(
      date: json['date'] as String,
      meals: (json['meals'] as List<dynamic>)
          .map((m) => MealEntryModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      totalCalories: json['totalCalories'] as int,
      totalProtein: json['totalProtein'] as int,
      totalCarbs: json['totalCarbs'] as int,
      totalFats: json['totalFats'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'meals': meals.map((m) => m.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DailyNutritionModel.fromMeals({
    required String date,
    required List<MealEntryModel> meals,
  }) {
    return DailyNutritionModel(
      date: date,
      meals: meals,
      totalCalories: meals.fold(0, (sum, m) => sum + m.calories),
      totalProtein: meals.fold(0, (sum, m) => sum + m.protein),
      totalCarbs: meals.fold(0, (sum, m) => sum + m.carbs),
      totalFats: meals.fold(0, (sum, m) => sum + m.fats),
    );
  }

  bool get isToday {
    final today = DateTime.now();
    final thisDate = DateTime.parse(date);
    return thisDate.year == today.year &&
        thisDate.month == today.month &&
        thisDate.day == today.day;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyNutritionModel &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
