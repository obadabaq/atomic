import 'package:atomic/features/food_feature/domain/models/food_model.dart';

class SubmittedMealsModel {
  int? id;
  final String date;
  final List<FoodModel> foods;

  SubmittedMealsModel({required this.date, required this.foods});

  factory SubmittedMealsModel.fromJson(Map<String, dynamic> json) {
    List<FoodModel> tmp = [];
    for (int i = 0; i < json['foods'].length; i++) {
      tmp.add(FoodModel.fromJson(json['foods'][i]));
    }
    return SubmittedMealsModel(
      date: json['date'],
      foods: tmp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'foods': foods,
    };
  }
}
