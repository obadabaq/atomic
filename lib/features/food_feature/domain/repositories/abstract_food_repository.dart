import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';

abstract class AbstractFoodRepository {
  // Food List Management (My Foods)
  FunctionalFuture<Failure, List<FoodModel>> getFoods();
  FunctionalFuture<Failure, FoodModel> addFood(FoodModel food);
  FunctionalFuture<Failure, FoodModel> updateFood(FoodModel food);
  FunctionalFuture<Failure, bool> deleteFood(int foodId);

  // Today's Tracking
  FunctionalFuture<Failure, DailyNutritionModel> getTodayNutrition();
  FunctionalFuture<Failure, MealEntryModel> addMealEntry(MealEntryModel entry);
  FunctionalFuture<Failure, bool> deleteMealEntry(int entryId);

  // Daily Nutrition (Historical)
  FunctionalFuture<Failure, List<DailyNutritionModel>> getDailyNutrition({
    required DateTime startDate,
    required DateTime endDate,
  });
  FunctionalFuture<Failure, DailyNutritionModel?> getDailyNutritionByDate(
      String date);

  // Analytics
  FunctionalFuture<Failure, NutritionAnalyticsModel> getAnalytics({
    int days = 30,
  });
}
