part of 'food_bloc.dart';

abstract class FoodEvent {
  const FoodEvent();
}

// Food List Management Events
class LoadFoodsEvent extends FoodEvent {
  const LoadFoodsEvent();
}

class AddFoodEvent extends FoodEvent {
  final FoodModel food;
  const AddFoodEvent(this.food);
}

class UpdateFoodEvent extends FoodEvent {
  final FoodModel food;
  const UpdateFoodEvent(this.food);
}

class DeleteFoodEvent extends FoodEvent {
  final int foodId;
  const DeleteFoodEvent(this.foodId);
}

// Today's Tracking Events
class LoadTodayNutritionEvent extends FoodEvent {
  const LoadTodayNutritionEvent();
}

class AddMealEntryEvent extends FoodEvent {
  final FoodModel food;
  const AddMealEntryEvent(this.food);
}

class DeleteMealEntryEvent extends FoodEvent {
  final int entryId;
  const DeleteMealEntryEvent(this.entryId);
}

// Analytics Events
class LoadAnalyticsEvent extends FoodEvent {
  final int days;
  const LoadAnalyticsEvent({this.days = 30});
}

// Combined event to refresh all data
class RefreshAllDataEvent extends FoodEvent {
  const RefreshAllDataEvent();
}
