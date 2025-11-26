import 'package:atomic/features/food_feature/domain/models/food_model.dart';

class Food extends FoodModel {
  Food({
    super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fats,
  });
}
