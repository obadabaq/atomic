part of 'food_bloc.dart';

abstract class FoodState {
  const FoodState();
}

class FoodInitial extends FoodState {}

/// Loading States
class FoodLoadingState extends FoodState {
  final String? message;
  const FoodLoadingState({this.message});
}

/// Food List States
class FoodsLoadedState extends FoodState {
  final List<FoodModel> foods;
  const FoodsLoadedState(this.foods);
}

class FoodAddedState extends FoodState {
  final FoodModel food;
  final List<FoodModel> allFoods;
  const FoodAddedState({required this.food, required this.allFoods});
}

class FoodUpdatedState extends FoodState {
  final FoodModel food;
  final List<FoodModel> allFoods;
  const FoodUpdatedState({required this.food, required this.allFoods});
}

class FoodDeletedState extends FoodState {
  final List<FoodModel> allFoods;
  const FoodDeletedState(this.allFoods);
}

/// Today's Tracking States
class TodayNutritionLoadedState extends FoodState {
  final DailyNutritionModel todayNutrition;
  const TodayNutritionLoadedState(this.todayNutrition);
}

class MealEntryAddedState extends FoodState {
  final MealEntryModel entry;
  final DailyNutritionModel updatedToday;
  const MealEntryAddedState({
    required this.entry,
    required this.updatedToday,
  });
}

class MealEntryDeletedState extends FoodState {
  final DailyNutritionModel updatedToday;
  const MealEntryDeletedState(this.updatedToday);
}

/// Analytics States
class AnalyticsLoadedState extends FoodState {
  final NutritionAnalyticsModel analytics;
  const AnalyticsLoadedState(this.analytics);
}

/// Combined State (for UI convenience)
class FoodDataState extends FoodState {
  final List<FoodModel> foods;
  final DailyNutritionModel todayNutrition;
  final NutritionAnalyticsModel? analytics;

  const FoodDataState({
    required this.foods,
    required this.todayNutrition,
    this.analytics,
  });

  FoodDataState copyWith({
    List<FoodModel>? foods,
    DailyNutritionModel? todayNutrition,
    NutritionAnalyticsModel? analytics,
  }) {
    return FoodDataState(
      foods: foods ?? this.foods,
      todayNutrition: todayNutrition ?? this.todayNutrition,
      analytics: analytics ?? this.analytics,
    );
  }
}

/// Error State
class FoodErrorState extends FoodState {
  final String message;
  const FoodErrorState(this.message);
}
