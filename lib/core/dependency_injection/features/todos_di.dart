import 'package:atomic/features/todos_feature/data/repositories/todo_repository_impl.dart';
import 'package:atomic/features/todos_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/todos_feature/domain/repositories/abstract_todo_repository.dart';
import 'package:atomic/features/todos_feature/domain/usecases/todo_use_case.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_bloc.dart';
import 'package:get_it/get_it.dart';

void initTodoFeature(GetIt getIt) {
  // Data Sources
  getIt.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AbstractTodoRepository>(
    () => TodoRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => TodoUseCase(getIt()));

  // BLoC
  getIt.registerFactory(
    () => TodoBloc(todoUseCase: getIt()),
  );
}
