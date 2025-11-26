import 'package:atomic/core/dependency_injection/features/food_di.dart';
import 'package:atomic/core/dependency_injection/features/habits_di.dart';
import 'package:atomic/core/dependency_injection/features/notes_di.dart';
import 'package:atomic/core/dependency_injection/features/todos_di.dart';
import 'package:atomic/core/helpers/file_manager_helper.dart';
import 'package:atomic/core/helpers/prefs_helper.dart';
import 'package:atomic/core/router/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  /// External (Shared Preferences, Connectivity, ...)
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => PrefsHelper(prefs: sl()));
  sl.registerLazySingleton(() => FileManagerHelper());

  /// Core (Any part of Core that needs initialization)
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  /// Features (Blocs, Repos and Data Sources)
  initHabitFeature(sl);
  initFoodFeature(sl);
  initTodoFeature(sl);
  initNoteFeature(sl);
}
