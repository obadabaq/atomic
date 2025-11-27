import 'dart:convert';
import 'package:atomic/core/helpers/prefs_helper.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class WidgetHelper {
  final PrefsHelper prefsHelper;

  const WidgetHelper({
    required this.prefsHelper,
  });

  /// Update the habits widget with current data
  Future<void> updateHabitsWidget() async {
    try {
      final habits = prefsHelper.getHabits();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Prepare widget data
      final List<Map<String, dynamic>> widgetHabits = habits.map((habit) {
        // Find today's submission
        final todaySubmission = habit.submissions.firstWhere(
          (sub) => sub.date == today,
          orElse: () => habit.submissions.first, // Fallback to first submission
        );

        // Calculate streak
        int streak = _calculateStreak(habit);

        return {
          'id': habit.id,
          'name': habit.name,
          'isCompleted': todaySubmission.value,
          'streak': streak,
          'habitType': habit.habitType.name,
          'count': todaySubmission.count,
          'targetCount': habit.targetCount ?? 0,
          'isPositive': habit.isPositive,
        };
      }).toList();

      // Save to SharedPreferences with key that Android can read
      final widgetData = {
        'habits': widgetHabits,
        'lastUpdated': DateTime.now().toIso8601String(),
        'todayDate': today,
      };

      await HomeWidget.saveWidgetData<String>(
        'widget_habits_data',
        jsonEncode(widgetData),
      );

      // Update the widget UI
      await HomeWidget.updateWidget(
        name: 'HabitsWidgetProvider',
        androidName: 'HabitsWidgetProvider',
      );
    } catch (e) {
      print('Error updating habits widget: $e');
    }
  }

  /// Calculate the current streak for a habit
  int _calculateStreak(HabitModel habit) {
    if (habit.submissions.isEmpty) return 0;

    // Sort submissions by date (newest first)
    final sortedSubmissions = List<dynamic>.from(habit.submissions)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (var submission in sortedSubmissions) {
      final submissionDate = DateTime.parse(submission.date);
      final expectedDate = DateFormat('yyyy-MM-dd').format(
        currentDate.subtract(Duration(days: streak)),
      );

      if (submission.date == expectedDate && submission.value == true) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Handle widget interaction (when user taps habit checkbox on widget)
  /// Returns the habit ID that was toggled
  static Future<int?> handleWidgetAction(Uri? uri) async {
    if (uri == null) return null;

    try {
      // Expected URI format: atomic://habit/toggle/{habitId}
      if (uri.scheme == 'atomic' && uri.host == 'habit' && uri.pathSegments.isNotEmpty) {
        if (uri.pathSegments[0] == 'toggle' && uri.pathSegments.length > 1) {
          final habitId = int.tryParse(uri.pathSegments[1]);
          return habitId;
        }
      }
    } catch (e) {
      print('Error handling widget action: $e');
    }

    return null;
  }

  /// Initialize widget system - call this on app startup
  static Future<void> initializeWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.example.atomic');
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }
}
