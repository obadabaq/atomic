import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';

abstract class TodoState {
  const TodoState();
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class SuccessGetTodosState extends TodoState {
  final List<TodoModel> todos;

  SuccessGetTodosState(this.todos);
}

class SuccessAddTodoState extends TodoState {
  final List<TodoModel> todos;

  SuccessAddTodoState(this.todos);
}

class SuccessUpdateTodoState extends TodoState {
  final List<TodoModel> todos;

  SuccessUpdateTodoState(this.todos);
}

class SuccessDeleteTodoState extends TodoState {
  final List<TodoModel> todos;

  SuccessDeleteTodoState(this.todos);
}

class SuccessToggleTodoState extends TodoState {
  final List<TodoModel> todos;

  SuccessToggleTodoState(this.todos);
}

class ErrorGetTodosState extends TodoState {
  final String error;

  ErrorGetTodosState(this.error);
}

class ErrorTodoOperationState extends TodoState {
  final String error;

  ErrorTodoOperationState(this.error);
}
