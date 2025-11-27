import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';
import 'package:atomic/features/todos_feature/domain/usecases/todo_use_case.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_event.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoUseCase todoUseCase;

  List<TodoModel> _cachedTodos = [];

  TodoBloc({required this.todoUseCase}) : super(TodoInitial()) {
    on<OnGettingTodosEvent>(_onGettingTodosEvent);
    on<OnAddingTodoEvent>(_onAddingTodoEvent);
    on<OnUpdatingTodoEvent>(_onUpdatingTodoEvent);
    on<OnDeletingTodoEvent>(_onDeletingTodoEvent);
    on<OnTogglingTodoCompletionEvent>(_onTogglingTodoCompletionEvent);
    on<OnReorderingTodosEvent>(_onReorderingTodosEvent);
  }

  // Helper methods for filtered todos
  List<TodoModel> getActiveTodos() {
    return _cachedTodos.where((todo) => !todo.isCompleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TodoModel> getCompletedTodos() {
    return _cachedTodos.where((todo) => todo.isCompleted).toList()
      ..sort((a, b) {
        if (a.completedAt == null) return 1;
        if (b.completedAt == null) return -1;
        return b.completedAt!.compareTo(a.completedAt!);
      });
  }

  Future<void> _onGettingTodosEvent(
      OnGettingTodosEvent event, Emitter<TodoState> emitter) async {
    final result = await todoUseCase.call(NoParams());
    result.fold(
      (failure) => emitter(ErrorGetTodosState(failure.error)),
      (todos) {
        _cachedTodos = todos;
        emitter(SuccessGetTodosState(todos));
      },
    );
  }

  Future<void> _onAddingTodoEvent(
      OnAddingTodoEvent event, Emitter<TodoState> emitter) async {
    final result = await todoUseCase.addTodo(event.todoModel);

    final newTodo = result.fold(
      (failure) {
        emitter(ErrorTodoOperationState(failure.error));
        return null;
      },
      (todo) => todo,
    );

    if (newTodo == null) return;

    // Refresh the list after adding
    final todosResult = await todoUseCase.call(NoParams());
    todosResult.fold(
      (failure) => emitter(ErrorTodoOperationState(failure.error)),
      (todos) {
        _cachedTodos = todos;
        emitter(SuccessAddTodoState(todos));
      },
    );
  }

  Future<void> _onUpdatingTodoEvent(
      OnUpdatingTodoEvent event, Emitter<TodoState> emitter) async {
    final result = await todoUseCase.updateTodo(event.todoModel);
    result.fold(
      (failure) => emitter(ErrorTodoOperationState(failure.error)),
      (todos) {
        _cachedTodos = todos;
        emitter(SuccessUpdateTodoState(todos));
      },
    );
  }

  Future<void> _onDeletingTodoEvent(
      OnDeletingTodoEvent event, Emitter<TodoState> emitter) async {
    final result = await todoUseCase.deleteTodo(event.todoId);
    result.fold(
      (failure) => emitter(ErrorTodoOperationState(failure.error)),
      (todos) {
        _cachedTodos = todos;
        emitter(SuccessDeleteTodoState(todos));
      },
    );
  }

  Future<void> _onTogglingTodoCompletionEvent(
      OnTogglingTodoCompletionEvent event, Emitter<TodoState> emitter) async {
    final result = await todoUseCase.toggleTodoCompletion(event.todoId);
    result.fold(
      (failure) => emitter(ErrorTodoOperationState(failure.error)),
      (todos) {
        _cachedTodos = todos;
        emitter(SuccessToggleTodoState(todos));
      },
    );
  }

  Future<void> _onReorderingTodosEvent(
      OnReorderingTodosEvent event, Emitter<TodoState> emitter) async {
    final result = await todoUseCase.reorderTodos(event.reorderedTodos);
    result.fold(
      (failure) => emitter(ErrorTodoOperationState(failure.error)),
      (todos) {
        _cachedTodos = todos;
        emitter(SuccessGetTodosState(todos));
      },
    );
  }
}
