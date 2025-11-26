import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/food_feature/domain/models/nutrition_analytics_model.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:atomic/features/food_feature/presentation/widgets/daily_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({Key? key}) : super(key: key);

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  MacroType _selectedMacro = MacroType.calories;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        NutritionAnalyticsModel? analytics;
        if (state is FoodDataState) {
          analytics = state.analytics;
        } else if (state is AnalyticsLoadedState) {
          analytics = state.analytics;
        }

        if (analytics == null || analytics.dailyData.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics,
                  size: 80.sp,
                  color: CustomColors.neutralColor,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No analytics data yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Start tracking your meals to see insights',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CustomColors.neutralColor,
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<FoodBloc>()
                .add(const LoadAnalyticsEvent(days: 30));
          },
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            children: [
              _buildHeader(context),
              SizedBox(height: 2.h),
              _buildSummaryCards(analytics),
              SizedBox(height: 3.h),
              _buildMacroSelector(),
              SizedBox(height: 2.h),
              DailyChartWidget(
                analytics: analytics,
                selectedMacro: _selectedMacro,
              ),
              SizedBox(height: 3.h),
              _buildInsights(context, analytics),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      '30-Day Analytics',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildSummaryCards(NutritionAnalyticsModel analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Days Tracked',
                analytics.daysTracked.toString(),
                Icons.calendar_today,
                CustomColors.primaryColor,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildSummaryCard(
                'Avg Calories',
                analytics.avgCalories.toInt().toString(),
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.w),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Avg Protein',
                '${analytics.avgProtein.toInt()}g',
                Icons.fitness_center,
                Colors.blue,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildSummaryCard(
                'Avg Carbs',
                '${analytics.avgCarbs.toInt()}g',
                Icons.grain,
                Colors.green,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildSummaryCard(
                'Avg Fats',
                '${analytics.avgFats.toInt()}g',
                Icons.water_drop,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 1.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: CustomColors.neutralColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Metric',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              children: [
                _buildMacroChip(
                  'Calories',
                  MacroType.calories,
                  Colors.orange,
                ),
                _buildMacroChip(
                  'Protein',
                  MacroType.protein,
                  Colors.blue,
                ),
                _buildMacroChip(
                  'Carbs',
                  MacroType.carbs,
                  Colors.green,
                ),
                _buildMacroChip(
                  'Fats',
                  MacroType.fats,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, MacroType type, Color color) {
    final isSelected = _selectedMacro == type;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedMacro = type;
        });
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildInsights(
      BuildContext context, NutritionAnalyticsModel analytics) {
    if (analytics.dailyData.isEmpty) return const SizedBox.shrink();

    // Find max and min days
    var maxCaloriesDay = analytics.dailyData[0];
    var minCaloriesDay = analytics.dailyData[0];

    for (var day in analytics.dailyData) {
      if (day.totalCalories > maxCaloriesDay.totalCalories) {
        maxCaloriesDay = day;
      }
      if (day.totalCalories < minCaloriesDay.totalCalories &&
          day.totalCalories > 0) {
        minCaloriesDay = day;
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 2.h),
            _buildInsightRow(
              Icons.trending_up,
              'Highest Day',
              '${maxCaloriesDay.totalCalories} cal',
              Colors.green,
            ),
            SizedBox(height: 1.h),
            _buildInsightRow(
              Icons.trending_down,
              'Lowest Day',
              '${minCaloriesDay.totalCalories} cal',
              Colors.red,
            ),
            SizedBox(height: 1.h),
            _buildInsightRow(
              Icons.analytics,
              'Total Days',
              '${analytics.daysTracked} days',
              CustomColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 3.w),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
