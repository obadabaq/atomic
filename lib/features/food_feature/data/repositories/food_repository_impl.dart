import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/food_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:atomic/features/food_feature/domain/repositories/abstract_food_repository.dart';

class FoodRepositoryImpl extends AbstractFoodRepository {
  final FoodLocalDataSource _localDataSource;

  FoodRepositoryImpl(this._localDataSource);

  @override
  FunctionalFuture<Failure, List<FoodModel>> getFoods() async {
    return await _localDataSource.getFoods();
  }

  @override
  FunctionalFuture<Failure, FoodModel> addFood(FoodModel food) async {
    return await _localDataSource.addFood(food);
  }

  @override
  FunctionalFuture<Failure, FoodModel> updateFood(FoodModel food) async {
    return await _localDataSource.updateFood(food);
  }

  @override
  FunctionalFuture<Failure, bool> deleteFood(int foodId) async {
    return await _localDataSource.deleteFood(foodId);
  }

  @override
  FunctionalFuture<Failure, DailyNutritionModel> getTodayNutrition() async {
    return await _localDataSource.getTodayNutrition();
  }

  @override
  FunctionalFuture<Failure, MealEntryModel> addMealEntry(
      MealEntryModel entry) async {
    return await _localDataSource.addMealEntry(entry);
  }

  @override
  FunctionalFuture<Failure, bool> deleteMealEntry(int entryId) async {
    return await _localDataSource.deleteMealEntry(entryId);
  }

  @override
  FunctionalFuture<Failure, List<DailyNutritionModel>> getDailyNutrition({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _localDataSource.getDailyNutrition(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  FunctionalFuture<Failure, DailyNutritionModel?> getDailyNutritionByDate(
      String date) async {
    return await _localDataSource.getDailyNutritionByDate(date);
  }

  @override
  FunctionalFuture<Failure, NutritionAnalyticsModel> getAnalytics({
    int days = 30,
  }) async {
    return await _localDataSource.getAnalytics(days: days);
  }
}
