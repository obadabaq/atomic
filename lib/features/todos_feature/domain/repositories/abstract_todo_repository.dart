import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';

abstract class AbstractTodoRepository {
  FunctionalFuture<Failure, List<TodoModel>> getTodos();

  FunctionalFuture<Failure, TodoModel> addTodo(TodoModel todoModel);

  FunctionalFuture<Failure, List<TodoModel>> updateTodo(TodoModel todoModel);

  FunctionalFuture<Failure, List<TodoModel>> deleteTodo(int todoId);

  FunctionalFuture<Failure, List<TodoModel>> toggleTodoCompletion(int todoId);
}
