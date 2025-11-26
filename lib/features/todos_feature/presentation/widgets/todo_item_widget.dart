import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/todos_feature/domain/models/todo_model.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_bloc.dart';
import 'package:atomic/features/todos_feature/presentation/bloc/todo_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoModel todo;

  const TodoItemWidget({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 1.h),
      elevation: 2,
      color: todo.isCompleted
          ? CustomColors.neutralColor.withOpacity(0.1)
          : Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) {
            context
                .read<TodoBloc>()
                .add(OnTogglingTodoCompletionEvent(todo.id!));
          },
          activeColor: CustomColors.accentColor,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.isCompleted
                ? CustomColors.neutralColor
                : CustomColors.blackColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                todo.description!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: CustomColors.neutralColor,
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 0.5.h),
            Text(
              todo.isCompleted && todo.completedAt != null
                  ? 'Completed ${DateFormat('MMM d, h:mm a').format(todo.completedAt!)}'
                  : 'Created ${DateFormat('MMM d, h:mm a').format(todo.createdAt)}',
              style: TextStyle(
                fontSize: 9.sp,
                color: CustomColors.neutralColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          color: CustomColors.redColor,
          iconSize: 20.sp,
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TodoBloc>().add(OnDeletingTodoEvent(todo.id!));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.redColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
