import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';
import 'package:atomic/features/todos_feature/domain/repositories/abstract_todo_repository.dart';

class TodoUseCase extends UseCase<List<TodoModel>, NoParams> {
  final AbstractTodoRepository _abstractTodoRepository;

  TodoUseCase(this._abstractTodoRepository);

  @override
  FunctionalFuture<Failure, List<TodoModel>> call(params) {
    return _abstractTodoRepository.getTodos();
  }

  FunctionalFuture<Failure, TodoModel> addTodo(TodoModel todoModel) {
    return _abstractTodoRepository.addTodo(todoModel);
  }

  FunctionalFuture<Failure, List<TodoModel>> updateTodo(TodoModel todoModel) {
    return _abstractTodoRepository.updateTodo(todoModel);
  }

  FunctionalFuture<Failure, List<TodoModel>> deleteTodo(int todoId) {
    return _abstractTodoRepository.deleteTodo(todoId);
  }

  FunctionalFuture<Failure, List<TodoModel>> toggleTodoCompletion(int todoId) {
    return _abstractTodoRepository.toggleTodoCompletion(todoId);
  }

  FunctionalFuture<Failure, List<TodoModel>> reorderTodos(
      List<TodoModel> reorderedTodos) {
    return _abstractTodoRepository.reorderTodos(reorderedTodos);
  }
}
