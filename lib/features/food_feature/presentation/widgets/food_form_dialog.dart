import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/food_feature/domain/models/food_model.dart';
import 'package:atomic/features/food_feature/presentation/bloc/food_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class FoodFormDialog extends StatefulWidget {
  final FoodModel? foodToEdit;

  const FoodFormDialog({Key? key, this.foodToEdit}) : super(key: key);

  @override
  State<FoodFormDialog> createState() => _FoodFormDialogState();
}

class _FoodFormDialogState extends State<FoodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodToEdit?.name ?? '');
    _caloriesController = TextEditingController(
        text: widget.foodToEdit?.calories.toString() ?? '');
    _proteinController = TextEditingController(
        text: widget.foodToEdit?.protein.toString() ?? '');
    _carbsController =
        TextEditingController(text: widget.foodToEdit?.carbs.toString() ?? '');
    _fatsController =
        TextEditingController(text: widget.foodToEdit?.fats.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.foodToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Food' : 'Add Food'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (include serving size)',
                  hintText: 'e.g., 250g Chicken Breast',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter protein';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _carbsController,
                decoration: const InputDecoration(
                  labelText: 'Carbs (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter carbs';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _fatsController,
                decoration: const InputDecoration(
                  labelText: 'Fats (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fats';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final food = FoodModel(
      id: widget.foodToEdit?.id,
      name: _nameController.text.trim(),
      calories: int.parse(_caloriesController.text),
      protein: int.parse(_proteinController.text),
      carbs: int.parse(_carbsController.text),
      fats: int.parse(_fatsController.text),
    );

    if (widget.foodToEdit == null) {
      context.read<FoodBloc>().add(AddFoodEvent(food));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food added successfully!'),
          backgroundColor: CustomColors.complementaryColor,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      context.read<FoodBloc>().add(UpdateFoodEvent(food));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food updated successfully!'),
          backgroundColor: CustomColors.complementaryColor,
          duration: Duration(seconds: 2),
        ),
      );
    }

    Navigator.pop(context);
  }
}
