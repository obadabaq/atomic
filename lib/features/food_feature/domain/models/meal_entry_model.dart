import 'package:atomic/features/food_feature/domain/models/food_model.dart';

class MealEntryModel {
  final int? id;
  final int foodId;
  final String foodName; // Denormalized - includes serving size
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final DateTime timestamp;

  MealEntryModel({
    this.id,
    required this.foodId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MealEntryModel.fromJson(Map<String, dynamic> json) {
    return MealEntryModel(
      id: json['id'] as int?,
      foodId: json['foodId'] as int,
      foodName: json['foodName'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fats: json['fats'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Simplified factory - just copy values from food (no multiplication)
  factory MealEntryModel.fromFood({
    required FoodModel food,
    int? id,
  }) {
    return MealEntryModel(
      id: id,
      foodId: food.id!,
      foodName: food.name,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fats: food.fats,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealEntryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
