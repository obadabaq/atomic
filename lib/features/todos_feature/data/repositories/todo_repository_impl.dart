import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/todos_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';
import 'package:atomic/features/todos_feature/domain/repositories/abstract_todo_repository.dart';

class TodoRepositoryImpl extends AbstractTodoRepository {
  final TodoLocalDataSource _localDataSource;

  TodoRepositoryImpl(this._localDataSource);

  @override
  FunctionalFuture<Failure, List<TodoModel>> getTodos() {
    return _localDataSource.getTodos();
  }

  @override
  FunctionalFuture<Failure, TodoModel> addTodo(TodoModel todoModel) {
    return _localDataSource.addTodo(todoModel);
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> updateTodo(TodoModel todoModel) {
    return _localDataSource.updateTodo(todoModel);
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> deleteTodo(int todoId) {
    return _localDataSource.deleteTodo(todoId);
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> toggleTodoCompletion(int todoId) {
    return _localDataSource.toggleTodoCompletion(todoId);
  }

  @override
  FunctionalFuture<Failure, List<TodoModel>> reorderTodos(
      List<TodoModel> reorderedTodos) {
    return _localDataSource.reorderTodos(reorderedTodos);
  }
}
