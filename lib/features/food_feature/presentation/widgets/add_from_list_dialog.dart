import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class AddFromListDialog extends StatelessWidget {
  const AddFromListDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Food to Today'),
      content: SizedBox(
        width: double.maxFinite,
        height: 60.h,
        child: BlocBuilder<FoodBloc, FoodState>(
          builder: (context, state) {
            List<FoodModel> foods = [];
            if (state is FoodDataState) {
              foods = state.foods;
            } else if (state is FoodsLoadedState) {
              foods = state.foods;
            }

            if (foods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 60.sp,
                      color: CustomColors.neutralColor,
                    ),
                    SizedBox(height: 2.h),
                    const Text(
                      'No foods available',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 1.h),
                    const Text(
                      'Add foods in "My Foods" tab first',
                      style: TextStyle(color: CustomColors.neutralColor),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: ListTile(
                    title: Text(
                      food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Text(
                        '${food.calories} cal | ${food.protein}g pro | ${food.carbs}g carbs | ${food.fats}g fats',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CustomColors.neutralColor,
                        ),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.add_circle,
                      color: CustomColors.complementaryColor,
                    ),
                    onTap: () {
                      // Simplified - just add the food directly (no servings dialog)
                      context.read<FoodBloc>().add(AddMealEntryEvent(food));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${food.name} added to today!'),
                          backgroundColor: CustomColors.complementaryColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
