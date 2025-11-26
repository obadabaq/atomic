import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:atomic/features/food_feature/domain/usecases/food_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final GetFoodsUseCase getFoodsUseCase;
  final AddFoodUseCase addFoodUseCase;
  final UpdateFoodUseCase updateFoodUseCase;
  final DeleteFoodUseCase deleteFoodUseCase;
  final GetTodayNutritionUseCase getTodayNutritionUseCase;
  final AddMealEntryUseCase addMealEntryUseCase;
  final DeleteMealEntryUseCase deleteMealEntryUseCase;
  final GetAnalyticsUseCase getAnalyticsUseCase;

  // Cache for combined state
  List<FoodModel> _cachedFoods = [];
  DailyNutritionModel? _cachedTodayNutrition;
  NutritionAnalyticsModel? _cachedAnalytics;

  FoodBloc({
    required this.getFoodsUseCase,
    required this.addFoodUseCase,
    required this.updateFoodUseCase,
    required this.deleteFoodUseCase,
    required this.getTodayNutritionUseCase,
    required this.addMealEntryUseCase,
    required this.deleteMealEntryUseCase,
    required this.getAnalyticsUseCase,
  }) : super(FoodInitial()) {
    on<LoadFoodsEvent>(_onLoadFoods);
    on<AddFoodEvent>(_onAddFood);
    on<UpdateFoodEvent>(_onUpdateFood);
    on<DeleteFoodEvent>(_onDeleteFood);
    on<LoadTodayNutritionEvent>(_onLoadTodayNutrition);
    on<AddMealEntryEvent>(_onAddMealEntry);
    on<DeleteMealEntryEvent>(_onDeleteMealEntry);
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
    on<RefreshAllDataEvent>(_onRefreshAllData);
  }

  Future<void> _onLoadFoods(
      LoadFoodsEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Loading foods...'));

    final result = await getFoodsUseCase(NoParams());
    result.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (foods) {
        _cachedFoods = foods;
        emit(FoodsLoadedState(foods));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onAddFood(AddFoodEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Adding food...'));

    final result = await addFoodUseCase(event.food);

    final addedFood = result.fold(
      (failure) {
        emit(FoodErrorState(failure.error));
        return null;
      },
      (food) => food,
    );

    if (addedFood == null) return;

    final foodsResult = await getFoodsUseCase(NoParams());
    foodsResult.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (foods) {
        _cachedFoods = foods;
        emit(FoodAddedState(food: addedFood, allFoods: foods));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onUpdateFood(
      UpdateFoodEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Updating food...'));

    final result = await updateFoodUseCase(event.food);

    final updatedFood = result.fold(
      (failure) {
        emit(FoodErrorState(failure.error));
        return null;
      },
      (food) => food,
    );

    if (updatedFood == null) return;

    final foodsResult = await getFoodsUseCase(NoParams());
    foodsResult.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (foods) {
        _cachedFoods = foods;
        emit(FoodUpdatedState(food: updatedFood, allFoods: foods));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onDeleteFood(
      DeleteFoodEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Deleting food...'));

    final result = await deleteFoodUseCase(event.foodId);

    final success = result.fold(
      (failure) {
        emit(FoodErrorState(failure.error));
        return false;
      },
      (_) => true,
    );

    if (!success) return;

    final foodsResult = await getFoodsUseCase(NoParams());
    foodsResult.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (foods) {
        _cachedFoods = foods;
        emit(FoodDeletedState(foods));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onLoadTodayNutrition(
      LoadTodayNutritionEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Loading today\'s nutrition...'));

    final result = await getTodayNutritionUseCase(NoParams());
    result.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (todayNutrition) {
        _cachedTodayNutrition = todayNutrition;
        emit(TodayNutritionLoadedState(todayNutrition));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onAddMealEntry(
      AddMealEntryEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Adding meal...'));

    // Simplified - just pass the food directly
    final result = await addMealEntryUseCase(event.food);

    final entry = result.fold(
      (failure) {
        emit(FoodErrorState(failure.error));
        return null;
      },
      (entry) => entry,
    );

    if (entry == null) return;

    final todayResult = await getTodayNutritionUseCase(NoParams());
    todayResult.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (todayNutrition) {
        _cachedTodayNutrition = todayNutrition;
        emit(MealEntryAddedState(
            entry: entry, updatedToday: todayNutrition));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onDeleteMealEntry(
      DeleteMealEntryEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Deleting meal...'));

    final result = await deleteMealEntryUseCase(event.entryId);

    final success = result.fold(
      (failure) {
        emit(FoodErrorState(failure.error));
        return false;
      },
      (_) => true,
    );

    if (!success) return;

    final todayResult = await getTodayNutritionUseCase(NoParams());
    todayResult.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (todayNutrition) {
        _cachedTodayNutrition = todayNutrition;
        emit(MealEntryDeletedState(todayNutrition));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onLoadAnalytics(
      LoadAnalyticsEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Loading analytics...'));

    final params = GetAnalyticsParams(days: event.days);
    final result = await getAnalyticsUseCase(params);

    result.fold(
      (failure) => emit(FoodErrorState(failure.error)),
      (analytics) {
        _cachedAnalytics = analytics;
        emit(AnalyticsLoadedState(analytics));
        _emitCombinedState(emit);
      },
    );
  }

  Future<void> _onRefreshAllData(
      RefreshAllDataEvent event, Emitter<FoodState> emit) async {
    emit(const FoodLoadingState(message: 'Refreshing...'));

    final results = await Future.wait([
      getFoodsUseCase(NoParams()),
      getTodayNutritionUseCase(NoParams()),
      getAnalyticsUseCase(GetAnalyticsParams(days: 30)),
    ]);

    final foodsResult = results[0];
    final todayResult = results[1];
    final analyticsResult = results[2];

    if (foodsResult.isLeft()) {
      emit(FoodErrorState(foodsResult.fold((l) => l.error, (_) => '')));
      return;
    }
    if (todayResult.isLeft()) {
      emit(FoodErrorState(todayResult.fold((l) => l.error, (_) => '')));
      return;
    }
    if (analyticsResult.isLeft()) {
      emit(FoodErrorState(analyticsResult.fold((l) => l.error, (_) => '')));
      return;
    }

    foodsResult.fold(
      (_) {},
      (foods) => _cachedFoods = foods as List<FoodModel>
    );
    todayResult.fold(
      (_) {},
      (today) => _cachedTodayNutrition = today as DailyNutritionModel
    );
    analyticsResult.fold(
      (_) {},
      (analytics) => _cachedAnalytics = analytics as NutritionAnalyticsModel
    );

    _emitCombinedState(emit);
  }

  void _emitCombinedState(Emitter<FoodState> emit) {
    if (_cachedTodayNutrition != null) {
      emit(FoodDataState(
        foods: _cachedFoods,
        todayNutrition: _cachedTodayNutrition!,
        analytics: _cachedAnalytics,
      ));
    }
  }
}
