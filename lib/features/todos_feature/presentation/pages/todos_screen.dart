import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_bloc.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_event.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_state.dart';
import 'package:atomic/features/todos_feature/presentation/widgets/add_todo_dialog.dart';
import 'package:atomic/features/todos_feature/presentation/widgets/todo_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({Key? key}) : super(key: key);

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  bool _showArchived = false;

  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(const OnGettingTodosEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Todos'),
        backgroundColor: Colors.white,
        foregroundColor: CustomColors.blackColor,
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.archive : Icons.archive_outlined,
            ),
            onPressed: () {
              setState(() {
                _showArchived = !_showArchived;
              });
            },
            tooltip: _showArchived ? 'Hide Archive' : 'Show Archive',
          ),
        ],
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is SuccessAddTodoState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Todo added successfully'),
                backgroundColor: CustomColors.complementaryColor,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is SuccessDeleteTodoState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Todo deleted'),
                backgroundColor: CustomColors.complementaryColor,
                duration: Duration(seconds: 2),
              ),
            );
          } else if (state is ErrorGetTodosState ||
              state is ErrorTodoOperationState) {
            final error = state is ErrorGetTodosState
                ? state.error
                : (state as ErrorTodoOperationState).error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: CustomColors.redColor,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeTodos = context.read<TodoBloc>().getActiveTodos();
          final completedTodos = context.read<TodoBloc>().getCompletedTodos();

          if (activeTodos.isEmpty && completedTodos.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TodoBloc>().add(const OnGettingTodosEvent());
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: [
                if (activeTodos.isNotEmpty) ...[
                  _buildSectionHeader('Active Todos', activeTodos.length),
                  SizedBox(height: 1.h),
                  ...activeTodos.map((todo) => TodoItemWidget(todo: todo)),
                ],
                if (completedTodos.isNotEmpty) ...[
                  if (activeTodos.isNotEmpty) SizedBox(height: 2.h),
                  if (_showArchived) ...[
                    _buildSectionHeader('Archived Todos', completedTodos.length),
                    SizedBox(height: 1.h),
                    ...completedTodos.map((todo) => TodoItemWidget(todo: todo)),
                  ] else ...[
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showArchived = true;
                          });
                        },
                        icon: const Icon(Icons.archive),
                        label: Text(
                          '${completedTodos.length} archived ${completedTodos.length == 1 ? 'todo' : 'todos'}',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: CustomColors.neutralColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<TodoBloc>(),
              child: const AddTodoDialog(),
            ),
          );
        },
        backgroundColor: CustomColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80.sp,
            color: CustomColors.neutralColor,
          ),
          SizedBox(height: 2.h),
          Text(
            'No todos yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap + to add your first todo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CustomColors.neutralColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: CustomColors.blackColor,
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
          decoration: BoxDecoration(
            color: CustomColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: CustomColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
