import 'package:atomic/features/habits_feature/domain/models/submission_model.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_type.dart';

class HabitModel {
  int? id;
  final String name;
  final String question;
  final List<SubmissionModel> submissions;
  final HabitType habitType;
  final bool isPositive;
  final int? targetCount;

  HabitModel({
    this.id,
    required this.name,
    required this.question,
    required this.submissions,
    this.habitType = HabitType.boolean,
    this.isPositive = true,
    this.targetCount,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    List<SubmissionModel> tmp = [];
    for (int i = 0; i < json['submissions'].length; i++) {
      tmp.add(SubmissionModel.fromJson(json['submissions'][i]));
    }
    return HabitModel(
      id: json['id'],
      name: json['name'],
      question: json['question'],
      submissions: tmp,
      habitType: json['habitType'] != null
          ? HabitTypeExtension.fromString(json['habitType'])
          : HabitType.boolean,
      isPositive: json['isPositive'] ?? true,
      targetCount: json['targetCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'question': question,
      'submissions': submissions,
      'habitType': habitType.name,
      'isPositive': isPositive,
      'targetCount': targetCount,
    };
  }
}
