import 'package:atomic/features/habits_feature/data/repositories/habit_repository_impl.dart';
import 'package:atomic/features/habits_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/habits_feature/domain/repositories/abstract_habit_repository.dart';
import 'package:atomic/features/habits_feature/domain/usecases/habit_use_case.dart';
import 'package:atomic/features/habits_feature/presentation/bloc/habit_bloc.dart';
import 'package:get_it/get_it.dart';

void initHabitFeature(GetIt getIt) {
  // Data Sources
  getIt.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AbstractHabitRepository>(
    () => HabitRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => HabitUseCase(getIt()));

  // BLoC
  getIt.registerFactory(
    () => HabitBloc(habitUseCase: getIt()),
  );
}
