import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/core/helpers/prefs_helper.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:dartz/dartz.dart';

abstract class FoodLocalDataSource {
  FunctionalFuture<Failure, List<FoodModel>> getFoods();
  FunctionalFuture<Failure, FoodModel> addFood(FoodModel food);
  FunctionalFuture<Failure, FoodModel> updateFood(FoodModel food);
  FunctionalFuture<Failure, bool> deleteFood(int foodId);
  FunctionalFuture<Failure, DailyNutritionModel> getTodayNutrition();
  FunctionalFuture<Failure, MealEntryModel> addMealEntry(MealEntryModel entry);
  FunctionalFuture<Failure, bool> deleteMealEntry(int entryId);
  FunctionalFuture<Failure, List<DailyNutritionModel>> getDailyNutrition({
    required DateTime startDate,
    required DateTime endDate,
  });
  FunctionalFuture<Failure, DailyNutritionModel?> getDailyNutritionByDate(
      String date);
  FunctionalFuture<Failure, NutritionAnalyticsModel> getAnalytics(
      {int days = 30});
}

class FoodLocalDataSourceImpl extends FoodLocalDataSource {
  final PrefsHelper _prefsHelper;

  FoodLocalDataSourceImpl(this._prefsHelper);

  @override
  FunctionalFuture<Failure, List<FoodModel>> getFoods() async {
    try {
      final foods = _prefsHelper.getFoods();
      return Right(foods);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve foods: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, FoodModel> addFood(FoodModel food) async {
    try {
      final addedFood = _prefsHelper.addFood(food);
      return Right(addedFood);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add food: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, FoodModel> updateFood(FoodModel food) async {
    try {
      final updatedFood = _prefsHelper.updateFood(food);
      return Right(updatedFood);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update food: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, bool> deleteFood(int foodId) async {
    try {
      _prefsHelper.deleteFood(foodId);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete food: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, DailyNutritionModel> getTodayNutrition() async {
    try {
      final todayData = _prefsHelper.getTodayNutrition();
      return Right(todayData);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve today\'s nutrition: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, MealEntryModel> addMealEntry(
      MealEntryModel entry) async {
    try {
      final addedEntry = _prefsHelper.addMealEntry(entry);
      return Right(addedEntry);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add meal entry: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, bool> deleteMealEntry(int entryId) async {
    try {
      _prefsHelper.deleteMealEntry(entryId);
      return const Right(true);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete meal entry: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<DailyNutritionModel>> getDailyNutrition({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dailyData = _prefsHelper.getDailyNutrition(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(dailyData);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve daily nutrition: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, DailyNutritionModel?> getDailyNutritionByDate(
      String date) async {
    try {
      final dayData = _prefsHelper.getDailyNutritionByDate(date);
      return Right(dayData);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve nutrition for date: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, NutritionAnalyticsModel> getAnalytics(
      {int days = 30}) async {
    try {
      final analytics = _prefsHelper.getAnalytics(days: days);
      return Right(analytics);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve analytics: $e'));
    }
  }
}
