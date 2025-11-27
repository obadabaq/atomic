import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/dependency_injection/locator.dart';
import 'package:atomic/core/helpers/widget_helper.dart';
import 'package:atomic/core/router/app_router.dart';
import 'package:atomic/core/router/routes_names.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:atomic/features/habits_feature/presentation/bloc/habit_bloc.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_bloc.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sizer/sizer.dart';

// Global key to access HabitBloc from widget callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencyInjection();

  // Initialize widget system
  await WidgetHelper.initializeWidget();

  // Set up widget interaction callback
  HomeWidget.setAppGroupId('group.com.example.atomic');
  HomeWidget.registerBackgroundCallback(backgroundCallback);

  runApp(const MyApp());
}

// Background callback for widget interactions
@pragma("vm:entry-point")
void backgroundCallback(Uri? uri) async {
  if (uri != null) {
    final habitId = await WidgetHelper.handleWidgetAction(uri);
    if (habitId != null) {
      // Widget interaction detected - will be handled when app opens
      await HomeWidget.saveWidgetData<int>('pending_habit_toggle', habitId);
    }
  }
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
              create: (BuildContext context) => sl<HabitBloc>(),
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
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Atomic',
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
