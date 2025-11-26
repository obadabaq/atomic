import 'package:atomic/features/food_feature/data/repositories/food_repository_impl.dart';
import 'package:atomic/features/food_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/food_feature/domain/repositories/abstract_food_repository.dart';
import 'package:atomic/features/food_feature/domain/usecases/food_use_case.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:get_it/get_it.dart';

void initFoodFeature(GetIt getIt) {
  // Data Sources
  getIt.registerLazySingleton<FoodLocalDataSource>(
    () => FoodLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AbstractFoodRepository>(
    () => FoodRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetFoodsUseCase(getIt()));
  getIt.registerLazySingleton(() => AddFoodUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateFoodUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteFoodUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTodayNutritionUseCase(getIt()));
  getIt.registerLazySingleton(() => AddMealEntryUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteMealEntryUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAnalyticsUseCase(getIt()));

  // BLoC
  getIt.registerFactory(
    () => FoodBloc(
      getFoodsUseCase: getIt(),
      addFoodUseCase: getIt(),
      updateFoodUseCase: getIt(),
      deleteFoodUseCase: getIt(),
      getTodayNutritionUseCase: getIt(),
      addMealEntryUseCase: getIt(),
      deleteMealEntryUseCase: getIt(),
      getAnalyticsUseCase: getIt(),
    ),
  );
}
