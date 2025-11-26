import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/food_feature/domain/models/daily_nutrition_model.dart';
import 'package:atomic/features/food_feature/domain/models/meal_entry_model.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:atomic/features/food_feature/presentation/widgets/add_from_list_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class TodayTrackingTab extends StatelessWidget {
  const TodayTrackingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FoodBloc, FoodState>(
        builder: (context, state) {
          if (state is FoodLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          DailyNutritionModel? todayNutrition;
          if (state is FoodDataState) {
            todayNutrition = state.todayNutrition;
          } else if (state is TodayNutritionLoadedState) {
            todayNutrition = state.todayNutrition;
          } else if (state is MealEntryAddedState) {
            todayNutrition = state.updatedToday;
          } else if (state is MealEntryDeletedState) {
            todayNutrition = state.updatedToday;
          }

          if (todayNutrition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FoodBloc>().add(const LoadTodayNutritionEvent());
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: [
                _buildHeader(context),
                SizedBox(height: 2.h),
                _NutritionTotalsCard(todayNutrition: todayNutrition),
                SizedBox(height: 3.h),
                _buildMealsHeader(context),
                SizedBox(height: 1.h),
                _buildMealsList(context, todayNutrition.meals),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<FoodBloc>(),
              child: const AddFromListDialog(),
            ),
          );
        },
        backgroundColor: CustomColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Meal', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Nutrition",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CustomColors.neutralColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealsHeader(BuildContext context) {
    return Text(
      'Meals',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMealsList(BuildContext context, List<MealEntryModel> meals) {
    if (meals.isEmpty) {
      return Center(
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Icon(
              Icons.fastfood,
              size: 80.sp,
              color: CustomColors.neutralColor,
            ),
            SizedBox(height: 2.h),
            Text(
              'No meals logged today',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Tap "Add Meal" to log your first meal',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CustomColors.neutralColor,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: meals.map((meal) => _MealEntryItem(meal: meal)).toList(),
    );
  }
}

class _NutritionTotalsCard extends StatelessWidget {
  final DailyNutritionModel todayNutrition;

  const _NutritionTotalsCard({Key? key, required this.todayNutrition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Totals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroColumn(
                  'Calories',
                  todayNutrition.totalCalories.toString(),
                  Colors.orange,
                  'cal',
                ),
                _buildMacroColumn(
                  'Protein',
                  todayNutrition.totalProtein.toString(),
                  Colors.blue,
                  'g',
                ),
                _buildMacroColumn(
                  'Carbs',
                  todayNutrition.totalCarbs.toString(),
                  Colors.green,
                  'g',
                ),
                _buildMacroColumn(
                  'Fats',
                  todayNutrition.totalFats.toString(),
                  Colors.purple,
                  'g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroColumn(
      String label, String value, Color color, String unit) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: CustomColors.neutralColor,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10.sp,
            color: CustomColors.neutralColor,
          ),
        ),
      ],
    );
  }
}

class _MealEntryItem extends StatelessWidget {
  final MealEntryModel meal;

  const _MealEntryItem({Key? key, required this.meal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: CircleAvatar(
          backgroundColor: CustomColors.primaryColor.withOpacity(0.1),
          child: const Icon(
            Icons.restaurant,
            color: CustomColors.primaryColor,
          ),
        ),
        title: Text(
          meal.foodName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${meal.calories} cal | ${meal.protein}g pro | ${meal.carbs}g carbs | ${meal.fats}g fats',
                style: TextStyle(fontSize: 11.sp),
              ),
              SizedBox(height: 0.5.h),
              Text(
                DateFormat('h:mm a').format(meal.timestamp),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: CustomColors.neutralColor,
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: CustomColors.redColor),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete "${meal.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FoodBloc>().add(DeleteMealEntryEvent(meal.id!));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Meal deleted successfully'),
                  backgroundColor: CustomColors.complementaryColor,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.redColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
