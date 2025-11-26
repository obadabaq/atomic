import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';

class TodoEntity extends TodoModel {
  TodoEntity({
    super.id,
    required super.title,
    super.description,
    super.isCompleted,
    super.createdAt,
    super.completedAt,
  });
}
