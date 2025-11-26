import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

enum MacroType { calories, protein, carbs, fats }

class DailyChartWidget extends StatefulWidget {
  final NutritionAnalyticsModel analytics;
  final MacroType selectedMacro;

  const DailyChartWidget({
    Key? key,
    required this.analytics,
    this.selectedMacro = MacroType.calories,
  }) : super(key: key);

  @override
  State<DailyChartWidget> createState() => _DailyChartWidgetState();
}

class _DailyChartWidgetState extends State<DailyChartWidget> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final dailyData = widget.analytics.getLastNDays(30);

    if (dailyData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 60.sp,
              color: CustomColors.neutralColor,
            ),
            SizedBox(height: 2.h),
            const Text(
              'No data to display',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    final spots = _getSpots(dailyData);
    final maxY = _getMaxY(dailyData);

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getChartTitle(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 30.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: dailyData.length > 10 ? 5 : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= dailyData.length) {
                            return const Text('');
                          }
                          final date = DateTime.parse(dailyData[index].date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: CustomColors.neutralColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY / 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: CustomColors.neutralColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: (dailyData.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _getMacroColor(),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: _getMacroColor(),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getMacroColor().withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = DateTime.parse(
                              dailyData[spot.x.toInt()].date);
                          return LineTooltipItem(
                            '${DateFormat('MMM d').format(date)}\n${spot.y.toInt()} ${_getUnit()}',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<DailyNutritionModel> dailyData) {
    List<FlSpot> spots = [];
    for (int i = 0; i < dailyData.length; i++) {
      double value;
      switch (widget.selectedMacro) {
        case MacroType.calories:
          value = dailyData[i].totalCalories.toDouble();
          break;
        case MacroType.protein:
          value = dailyData[i].totalProtein.toDouble();
          break;
        case MacroType.carbs:
          value = dailyData[i].totalCarbs.toDouble();
          break;
        case MacroType.fats:
          value = dailyData[i].totalFats.toDouble();
          break;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  double _getMaxY(List<DailyNutritionModel> dailyData) {
    double max = 0;
    for (var data in dailyData) {
      double value;
      switch (widget.selectedMacro) {
        case MacroType.calories:
          value = data.totalCalories.toDouble();
          break;
        case MacroType.protein:
          value = data.totalProtein.toDouble();
          break;
        case MacroType.carbs:
          value = data.totalCarbs.toDouble();
          break;
        case MacroType.fats:
          value = data.totalFats.toDouble();
          break;
      }
      if (value > max) max = value;
    }
    // Add 20% padding to max value
    return max * 1.2;
  }

  Color _getMacroColor() {
    switch (widget.selectedMacro) {
      case MacroType.calories:
        return Colors.orange;
      case MacroType.protein:
        return Colors.blue;
      case MacroType.carbs:
        return Colors.green;
      case MacroType.fats:
        return Colors.purple;
    }
  }

  String _getChartTitle() {
    switch (widget.selectedMacro) {
      case MacroType.calories:
        return 'Daily Calories';
      case MacroType.protein:
        return 'Daily Protein (g)';
      case MacroType.carbs:
        return 'Daily Carbs (g)';
      case MacroType.fats:
        return 'Daily Fats (g)';
    }
  }

  String _getUnit() {
    switch (widget.selectedMacro) {
      case MacroType.calories:
        return 'cal';
      case MacroType.protein:
      case MacroType.carbs:
      case MacroType.fats:
        return 'g';
    }
  }
}
