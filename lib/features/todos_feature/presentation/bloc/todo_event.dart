import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';

abstract class TodoEvent {
  const TodoEvent();
}

class OnGettingTodosEvent extends TodoEvent {
  const OnGettingTodosEvent();
}

class OnAddingTodoEvent extends TodoEvent {
  final TodoModel todoModel;

  const OnAddingTodoEvent(this.todoModel);
}

class OnUpdatingTodoEvent extends TodoEvent {
  final TodoModel todoModel;

  const OnUpdatingTodoEvent(this.todoModel);
}

class OnDeletingTodoEvent extends TodoEvent {
  final int todoId;

  const OnDeletingTodoEvent(this.todoId);
}

class OnTogglingTodoCompletionEvent extends TodoEvent {
  final int todoId;

  const OnTogglingTodoCompletionEvent(this.todoId);
}
