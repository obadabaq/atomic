import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/core/helpers/prefs_helper.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';
import 'package:dartz/dartz.dart';

abstract class TodoLocalDataSource {
  FunctionalFuture<Failure, List<TodoModel>> getTodos();

  FunctionalFuture<Failure, TodoModel> addTodo(TodoModel todoModel);

  FunctionalFuture<Failure, List<TodoModel>> updateTodo(TodoModel todoModel);

  FunctionalFuture<Failure, List<TodoModel>> deleteTodo(int todoId);

  FunctionalFuture<Failure, List<TodoModel>> toggleTodoCompletion(int todoId);
}

class TodoLocalDataSourceImpl extends TodoLocalDataSource {
  final PrefsHelper _prefsHelper;

  TodoLocalDataSourceImpl(this._prefsHelper);

  @override
  FunctionalFuture<Failure, List<TodoModel>> getTodos() async {
    try {
      final todos = _prefsHelper.getTodos();
      return Right(todos);
    } catch (e) {
      return Left(DatabaseFailure('Failed to retrieve todos: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, TodoModel> addTodo(TodoModel todoModel) async {
    try {
      final newTodo = _prefsHelper.addTodo(todoModel);
      return Right(newTodo);
    } catch (e) {
      return Left(DatabaseFailure('Failed to add todo: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> updateTodo(
      TodoModel todoModel) async {
    try {
      final todos = _prefsHelper.updateTodo(todoModel);
      return Right(todos);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update todo: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> deleteTodo(int todoId) async {
    try {
      final todos = _prefsHelper.deleteTodo(todoId);
      return Right(todos);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete todo: $e'));
    }
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> toggleTodoCompletion(
      int todoId) async {
    try {
      final todos = _prefsHelper.toggleTodoCompletion(todoId);
      return Right(todos);
    } catch (e) {
      return Left(DatabaseFailure('Failed to toggle todo completion: $e'));
    }
  }
}
