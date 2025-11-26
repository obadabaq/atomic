import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/dependency_injection/locator.dart';
import 'package:atomic/core/router/app_router.dart';
import 'package:atomic/core/router/routes_names.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:atomic/features/habits_feature/domain/usecases/habit_use_case.dart';
import 'package:atomic/features/habits_feature/presentation/bloc/habit_bloc.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_bloc.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (_, orientation, screenType) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<HabitBloc>(
              create: (BuildContext context) =>
                  HabitBloc(habitUseCase: sl<HabitUseCase>()),
            ),
            BlocProvider<FoodBloc>(
              create: (BuildContext context) => sl<FoodBloc>(),
            ),
            BlocProvider<TodoBloc>(
              create: (BuildContext context) => sl<TodoBloc>(),
            ),
            BlocProvider<NoteBloc>(
              create: (BuildContext context) => sl<NoteBloc>(),
            ),
          ],
          child: MaterialApp(
            title: 'atomic',
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSeed(seedColor: CustomColors.primaryColor),
              useMaterial3: true,
            ),
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: RoutesNames.home,
          ),
        );
      },
    );
  }
}

/// Dashboard:
/// Habits:
///   1- add habit (name, question, value)
///   2- show all added habits with today value
///   3- toggle habit on/off
/// Food:
