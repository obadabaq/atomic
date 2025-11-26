import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:atomic/features/food_feature/domain/repositories/abstract_food_repository.dart';
import 'package:dartz/dartz.dart';

/// Food list management use cases
class GetFoodsUseCase extends UseCase<List<FoodModel>, NoParams> {
  final AbstractFoodRepository _repository;
  GetFoodsUseCase(this._repository);

  @override
  FunctionalFuture<Failure, List<FoodModel>> call(NoParams params) {
    return _repository.getFoods();
  }
}

class AddFoodUseCase extends UseCase<FoodModel, FoodModel> {
  final AbstractFoodRepository _repository;
  AddFoodUseCase(this._repository);

  @override
  FunctionalFuture<Failure, FoodModel> call(FoodModel params) {
    // Validation
    if (params.name.trim().isEmpty) {
      return Future.value(Left(DatabaseFailure('Food name cannot be empty')));
    }
    if (params.calories < 0 ||
        params.protein < 0 ||
        params.carbs < 0 ||
        params.fats < 0) {
      return Future.value(
          Left(DatabaseFailure('Nutrition values cannot be negative')));
    }

    return _repository.addFood(params);
  }
}

class UpdateFoodUseCase extends UseCase<FoodModel, FoodModel> {
  final AbstractFoodRepository _repository;
  UpdateFoodUseCase(this._repository);

  @override
  FunctionalFuture<Failure, FoodModel> call(FoodModel params) {
    // Validation
    if (params.id == null) {
      return Future.value(
          Left(DatabaseFailure('Food ID is required for update')));
    }
    if (params.name.trim().isEmpty) {
      return Future.value(Left(DatabaseFailure('Food name cannot be empty')));
    }
    if (params.calories < 0 ||
        params.protein < 0 ||
        params.carbs < 0 ||
        params.fats < 0) {
      return Future.value(
          Left(DatabaseFailure('Nutrition values cannot be negative')));
    }

    return _repository.updateFood(params);
  }
}

class DeleteFoodUseCase extends UseCase<bool, int> {
  final AbstractFoodRepository _repository;
  DeleteFoodUseCase(this._repository);

  @override
  FunctionalFuture<Failure, bool> call(int params) {
    return _repository.deleteFood(params);
  }
}

/// Today's tracking use cases
class GetTodayNutritionUseCase extends UseCase<DailyNutritionModel, NoParams> {
  final AbstractFoodRepository _repository;
  GetTodayNutritionUseCase(this._repository);

  @override
  FunctionalFuture<Failure, DailyNutritionModel> call(NoParams params) {
    return _repository.getTodayNutrition();
  }
}

class AddMealEntryUseCase extends UseCase<MealEntryModel, FoodModel> {
  final AbstractFoodRepository _repository;
  AddMealEntryUseCase(this._repository);

  @override
  FunctionalFuture<Failure, MealEntryModel> call(FoodModel params) {
    // Simplified - no validation needed, just create entry from food
    final entry = MealEntryModel.fromFood(food: params);
    return _repository.addMealEntry(entry);
  }
}

class DeleteMealEntryUseCase extends UseCase<bool, int> {
  final AbstractFoodRepository _repository;
  DeleteMealEntryUseCase(this._repository);

  @override
  FunctionalFuture<Failure, bool> call(int params) {
    return _repository.deleteMealEntry(params);
  }
}

/// Analytics use cases
class GetAnalyticsParams {
  final int days;
  GetAnalyticsParams({this.days = 30});
}

class GetAnalyticsUseCase
    extends UseCase<NutritionAnalyticsModel, GetAnalyticsParams> {
  final AbstractFoodRepository _repository;
  GetAnalyticsUseCase(this._repository);

  @override
  FunctionalFuture<Failure, NutritionAnalyticsModel> call(
      GetAnalyticsParams params) {
    return _repository.getAnalytics(days: params.days);
  }
}
