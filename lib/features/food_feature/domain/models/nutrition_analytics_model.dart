import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';

class NutritionAnalyticsModel {
  final List<DailyNutritionModel> dailyData;
  final int daysTracked;
  final double avgCalories;
  final double avgProtein;
  final double avgCarbs;
  final double avgFats;
  final int maxCalories;
  final int minCalories;
  final String mostTrackedDay;

  NutritionAnalyticsModel({
    required this.dailyData,
    required this.daysTracked,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgCarbs,
    required this.avgFats,
    required this.maxCalories,
    required this.minCalories,
    required this.mostTrackedDay,
  });

  factory NutritionAnalyticsModel.fromDailyData(
    List<DailyNutritionModel> dailyData,
  ) {
    if (dailyData.isEmpty) {
      return NutritionAnalyticsModel(
        dailyData: [],
        daysTracked: 0,
        avgCalories: 0,
        avgProtein: 0,
        avgCarbs: 0,
        avgFats: 0,
        maxCalories: 0,
        minCalories: 0,
        mostTrackedDay: 'N/A',
      );
    }

    final daysTracked = dailyData.length;
    final avgCalories =
        dailyData.fold(0, (sum, d) => sum + d.totalCalories) / daysTracked;
    final avgProtein =
        dailyData.fold(0, (sum, d) => sum + d.totalProtein) / daysTracked;
    final avgCarbs =
        dailyData.fold(0, (sum, d) => sum + d.totalCarbs) / daysTracked;
    final avgFats =
        dailyData.fold(0, (sum, d) => sum + d.totalFats) / daysTracked;

    final calories = dailyData.map((d) => d.totalCalories).toList();
    final maxCalories = calories.reduce((a, b) => a > b ? a : b);
    final minCalories = calories.reduce((a, b) => a < b ? a : b);

    final dayCount = <String, int>{};
    for (var day in dailyData) {
      final weekday = DateTime.parse(day.date).weekday;
      final dayName = _getWeekdayName(weekday);
      dayCount[dayName] = (dayCount[dayName] ?? 0) + 1;
    }
    final mostTrackedDay = dayCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return NutritionAnalyticsModel(
      dailyData: dailyData,
      daysTracked: daysTracked,
      avgCalories: avgCalories,
      avgProtein: avgProtein,
      avgCarbs: avgCarbs,
      avgFats: avgFats,
      maxCalories: maxCalories,
      minCalories: minCalories,
      mostTrackedDay: mostTrackedDay,
    );
  }

  static String _getWeekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  List<DailyNutritionModel> getLastNDays(int n) {
    final result = <DailyNutritionModel>[];
    final today = DateTime.now();

    for (var i = n - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateString = _formatDate(date);

      final existingDay = dailyData.firstWhere(
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

      result.add(existingDay);
    }

    return result;
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
