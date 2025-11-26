import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:atomic/features/food_feature/presentation/widgets/food_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class MyFoodListTab extends StatelessWidget {
  const MyFoodListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FoodBloc, FoodState>(
        builder: (context, state) {
          if (state is FoodLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          List<FoodModel> foods = [];
          if (state is FoodDataState) {
            foods = state.foods;
          } else if (state is FoodsLoadedState) {
            foods = state.foods;
          } else if (state is FoodAddedState) {
            foods = state.allFoods;
          } else if (state is FoodUpdatedState) {
            foods = state.allFoods;
          } else if (state is FoodDeletedState) {
            foods = state.allFoods;
          }

          if (foods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80.sp,
                    color: CustomColors.neutralColor,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No foods added yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Tap + to add your first food',
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
              context.read<FoodBloc>().add(const LoadFoodsEvent());
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return _FoodListItem(food: food);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<FoodBloc>(),
              child: const FoodFormDialog(),
            ),
          );
        },
        backgroundColor: CustomColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FoodListItem extends StatelessWidget {
  final FoodModel food;

  const _FoodListItem({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        title: Text(
          food.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 1.h),
          child: Row(
            children: [
              _buildNutritionChip('${food.calories} cal', Colors.orange),
              SizedBox(width: 2.w),
              _buildNutritionChip('${food.protein}g pro', Colors.blue),
              SizedBox(width: 2.w),
              _buildNutritionChip('${food.carbs}g carbs', Colors.green),
              SizedBox(width: 2.w),
              _buildNutritionChip('${food.fats}g fats', Colors.purple),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: CustomColors.accentColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => BlocProvider.value(
                    value: context.read<FoodBloc>(),
                    child: FoodFormDialog(foodToEdit: food),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: CustomColors.redColor),
              onPressed: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Food'),
        content: Text('Are you sure you want to delete "${food.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FoodBloc>().add(DeleteFoodEvent(food.id!));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Food deleted successfully'),
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
