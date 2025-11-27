import 'dart:convert';
import 'dart:math';
import 'package:atomic/core/constants/prefs_keys.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/domain/models/submitted_meals_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';
import 'package:atomic/features/notes_feature/domain/models/note_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  final SharedPreferences prefs;

  const PrefsHelper({
    required this.prefs,
  });

  /// Habits Logic
  List<HabitModel> getHabits() {
    final String? habitsPref = prefs.getString(PrefsKeys.habits);

    if (habitsPref == null) {
      return [];
    }

    final List<dynamic> habitsList = jsonDecode(habitsPref);
    return habitsList.map((item) => HabitModel.fromJson(item)).toList();
  }

  List<HabitModel> addHabit(HabitModel habitModel) {
    List<HabitModel> habits = getHabits();

    habitModel.id = 10000 + Random().nextInt(90000);

    habits.add(habitModel);

    prefs.setString(
        PrefsKeys.habits, jsonEncode(habits.map((h) => h.toJson()).toList()));

    return habits;
  }

  List<HabitModel> deleteHabit(HabitModel habitModel) {
    List<HabitModel> habits = getHabits();
    habits.removeWhere((element) => element.id == habitModel.id);

    prefs.setString(
        PrefsKeys.habits, jsonEncode(habits.map((h) => h.toJson()).toList()));

    return habits;
  }

  List<HabitModel> submitHabits(List<HabitModel> submittedHabits) {
    List<HabitModel> habits = getHabits();

    for (var submitted in submittedHabits) {
      var existingHabitIndex = habits.indexWhere((h) => h.id == submitted.id);
      if (existingHabitIndex != -1) {
        habits[existingHabitIndex] = submitted;
      } else {
        habits.add(submitted);
      }
    }

    prefs.setString(
      PrefsKeys.habits,
      jsonEncode(habits.map((h) => h.toJson()).toList()),
    );

    return habits;
  }

  List<HabitModel> reorderHabits(List<HabitModel> reorderedHabits) {
    // Update the order field for each habit based on its position in the list
    final habitsWithOrder = reorderedHabits.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    prefs.setString(
      PrefsKeys.habits,
      jsonEncode(habitsWithOrder.map((h) => h.toJson()).toList()),
    );

    return habitsWithOrder;
  }

  /// Food Logic
  List<FoodModel> getFoods() {
    final String? foodsPref = prefs.getString(PrefsKeys.foods);

    if (foodsPref == null) {
      return [];
    }

    final List<dynamic> foodsList = jsonDecode(foodsPref);
    return foodsList.map((item) => FoodModel.fromJson(item)).toList();
  }

  FoodModel addFood(FoodModel foodModel) {
    List<FoodModel> foods = getFoods();

    final newFood = foodModel.copyWith(
      id: 10000 + Random().nextInt(90000),
    );

    foods.add(newFood);
    prefs.setString(
        PrefsKeys.foods, jsonEncode(foods.map((f) => f.toJson()).toList()));

    return newFood;
  }

  FoodModel updateFood(FoodModel foodModel) {
    List<FoodModel> foods = getFoods();

    final index = foods.indexWhere((f) => f.id == foodModel.id);
    if (index == -1) {
      throw Exception('Food not found');
    }

    foods[index] = foodModel;
    prefs.setString(
        PrefsKeys.foods, jsonEncode(foods.map((f) => f.toJson()).toList()));

    return foodModel;
  }

  void deleteFood(int foodId) {
    List<FoodModel> foods = getFoods();
    foods.removeWhere((f) => f.id == foodId);
    prefs.setString(
        PrefsKeys.foods, jsonEncode(foods.map((f) => f.toJson()).toList()));
  }

  /// Daily Nutrition Management
  List<DailyNutritionModel> _getAllDailyNutrition() {
    final String? dailyPref = prefs.getString(PrefsKeys.dailyNutrition);
    if (dailyPref == null) return [];

    final List<dynamic> dailyList = jsonDecode(dailyPref);
    return dailyList.map((item) => DailyNutritionModel.fromJson(item)).toList();
  }

  void _saveDailyNutrition(List<DailyNutritionModel> dailyData) {
    prefs.setString(
      PrefsKeys.dailyNutrition,
      jsonEncode(dailyData.map((d) => d.toJson()).toList()),
    );
  }

  DailyNutritionModel getTodayNutrition() {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final allDaily = _getAllDailyNutrition();
    final todayData = allDaily.firstWhere(
      (d) => d.date == dateString,
      orElse: () => DailyNutritionModel(
        date: dateString,
        meals: [],
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFats: 0,
      ),
    );

    return todayData;
  }

  MealEntryModel addMealEntry(MealEntryModel entry) {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final allDaily = _getAllDailyNutrition();
    final todayIndex = allDaily.indexWhere((d) => d.date == dateString);

    final newEntry = MealEntryModel(
      id: 10000 + Random().nextInt(90000),
      foodId: entry.foodId,
      foodName: entry.foodName,
      calories: entry.calories,
      protein: entry.protein,
      carbs: entry.carbs,
      fats: entry.fats,
      timestamp: entry.timestamp,
    );

    if (todayIndex == -1) {
      final newDay = DailyNutritionModel.fromMeals(
        date: dateString,
        meals: [newEntry],
      );
      allDaily.add(newDay);
    } else {
      final meals = List<MealEntryModel>.from(allDaily[todayIndex].meals);
      meals.add(newEntry);
      allDaily[todayIndex] = DailyNutritionModel.fromMeals(
        date: dateString,
        meals: meals,
      );
    }

    _saveDailyNutrition(allDaily);
    return newEntry;
  }

  void deleteMealEntry(int entryId) {
    final today = DateTime.now();
    final dateString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final allDaily = _getAllDailyNutrition();
    final todayIndex = allDaily.indexWhere((d) => d.date == dateString);

    if (todayIndex != -1) {
      final meals = List<MealEntryModel>.from(allDaily[todayIndex].meals);
      meals.removeWhere((m) => m.id == entryId);

      allDaily[todayIndex] = DailyNutritionModel.fromMeals(
        date: dateString,
        meals: meals,
      );

      _saveDailyNutrition(allDaily);
    }
  }

  List<DailyNutritionModel> getDailyNutrition({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final allDaily = _getAllDailyNutrition();

    return allDaily.where((d) {
      final date = DateTime.parse(d.date);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  DailyNutritionModel? getDailyNutritionByDate(String date) {
    final allDaily = _getAllDailyNutrition();
    try {
      return allDaily.firstWhere((d) => d.date == date);
    } catch (e) {
      return null;
    }
  }

  NutritionAnalyticsModel getAnalytics({int days = 30}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final dailyData = getDailyNutrition(
      startDate: startDate,
      endDate: endDate,
    );

    return NutritionAnalyticsModel.fromDailyData(dailyData);
  }

  /// Legacy methods (for backward compatibility)
  List<SubmittedMealsModel> getMeals() {
    final String? mealsPref = prefs.getString(PrefsKeys.meals);

    if (mealsPref == null) {
      return [];
    }

    final List<dynamic> mealsList = jsonDecode(mealsPref);
    return mealsList
        .map((item) => SubmittedMealsModel.fromJson(item))
        .toList();
  }

  List<SubmittedMealsModel> submitMeal(SubmittedMealsModel submittedMeal) {
    List<SubmittedMealsModel> submittedMeals = getMeals();

    submittedMeal.id = 10000 + Random().nextInt(90000);

    submittedMeals.add(submittedMeal);

    prefs.setString(PrefsKeys.meals,
        jsonEncode(submittedMeals.map((h) => h.toJson()).toList()));

    return submittedMeals;
  }

  /// Todos Logic
  List<TodoModel> getTodos() {
    final String? todosPref = prefs.getString(PrefsKeys.todos);

    if (todosPref == null) {
      return [];
    }

    final List<dynamic> todosList = jsonDecode(todosPref);
    return todosList.map((item) => TodoModel.fromJson(item)).toList();
  }

  TodoModel addTodo(TodoModel todoModel) {
    List<TodoModel> todos = getTodos();

    final newTodo = todoModel.copyWith(
      id: 10000 + Random().nextInt(90000),
    );

    todos.add(newTodo);
    prefs.setString(
        PrefsKeys.todos, jsonEncode(todos.map((t) => t.toJson()).toList()));

    return newTodo;
  }

  List<TodoModel> updateTodo(TodoModel todoModel) {
    List<TodoModel> todos = getTodos();

    final index = todos.indexWhere((t) => t.id == todoModel.id);
    if (index != -1) {
      todos[index] = todoModel;
    }

    prefs.setString(
        PrefsKeys.todos, jsonEncode(todos.map((t) => t.toJson()).toList()));

    return todos;
  }

  List<TodoModel> deleteTodo(int todoId) {
    List<TodoModel> todos = getTodos();
    todos.removeWhere((t) => t.id == todoId);

    prefs.setString(
        PrefsKeys.todos, jsonEncode(todos.map((t) => t.toJson()).toList()));

    return todos;
  }

  List<TodoModel> toggleTodoCompletion(int todoId) {
    List<TodoModel> todos = getTodos();

    final index = todos.indexWhere((t) => t.id == todoId);
    if (index != -1) {
      final todo = todos[index];
      todos[index] = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
    }

    prefs.setString(
        PrefsKeys.todos, jsonEncode(todos.map((t) => t.toJson()).toList()));

    return todos;
  }

  List<TodoModel> reorderTodos(List<TodoModel> reorderedTodos) {
    // Update the order field for each todo based on its position in the list
    final todosWithOrder = reorderedTodos.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key);
    }).toList();

    prefs.setString(
      PrefsKeys.todos,
      jsonEncode(todosWithOrder.map((t) => t.toJson()).toList()),
    );

    return todosWithOrder;
  }

  /// Notes Logic
  List<NoteModel> getNotes() {
    final String? notesPref = prefs.getString(PrefsKeys.notes);

    if (notesPref == null) {
      return [];
    }

    final List<dynamic> notesList = jsonDecode(notesPref);
    return notesList.map((item) => NoteModel.fromJson(item)).toList();
  }

  NoteModel addNote(NoteModel noteModel) {
    List<NoteModel> notes = getNotes();

    final newNote = noteModel.copyWith(
      id: 10000 + Random().nextInt(90000),
    );

    notes.add(newNote);
    prefs.setString(
        PrefsKeys.notes, jsonEncode(notes.map((n) => n.toJson()).toList()));

    return newNote;
  }

  List<NoteModel> updateNote(NoteModel noteModel) {
    List<NoteModel> notes = getNotes();

    final index = notes.indexWhere((n) => n.id == noteModel.id);
    if (index != -1) {
      notes[index] = noteModel.copyWith(
        editedAt: DateTime.now(),
      );
    }

    prefs.setString(
        PrefsKeys.notes, jsonEncode(notes.map((n) => n.toJson()).toList()));

    return notes;
  }

  List<NoteModel> deleteNote(int noteId) {
    List<NoteModel> notes = getNotes();
    notes.removeWhere((n) => n.id == noteId);

    prefs.setString(
        PrefsKeys.notes, jsonEncode(notes.map((n) => n.toJson()).toList()));

    return notes;
  }
}
