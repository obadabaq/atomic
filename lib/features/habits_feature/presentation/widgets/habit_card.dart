import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/habits_feature/domain/models/submission_model.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_type.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:text_scroll/text_scroll.dart';

class HabitCard extends StatefulWidget {
  final HabitModel habitModel;
  final SubmissionModel submissionModel;
  final ThemeData theme;
  final VoidCallback onDelete;
  final VoidCallback? onToggle;

  const HabitCard({
    Key? key,
    required this.theme,
    required this.habitModel,
    required this.submissionModel,
    required this.onDelete,
    this.onToggle,
  }) : super(key: key);

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  @override
  Widget build(BuildContext context) {
    final isNegative = !widget.habitModel.isPositive;
    final habitType = widget.habitModel.habitType;

    // Determine if the habit is in "success" state
    bool isSuccess = false;
    if (habitType == HabitType.boolean) {
      // For boolean habits:
      // - Positive: success when checked (value = true)
      // - Negative: success when NOT checked (value = false)
      isSuccess = isNegative
          ? !widget.submissionModel.value
          : widget.submissionModel.value;
    } else if (habitType == HabitType.counter) {
      // For counter habits:
      // - Positive: success when count > 0
      // - Negative: success when count = 0 (avoided)
      isSuccess = isNegative
          ? widget.submissionModel.count == 0
          : widget.submissionModel.count > 0;
    }

    // Show accent color (green) when in success state
    Color cardColor = isSuccess ? CustomColors.accentColor : Colors.transparent;

    return InkWell(
      onTap: habitType == HabitType.boolean ? _toggleColor : null,
      child: Card(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.h),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              SizedBox(height: 0.1.h),
              _buildQuestionText(),
              if (habitType == HabitType.counter) ...[
                SizedBox(height: 0.2.h),
                _buildCounterControls(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isNegative = !widget.habitModel.isPositive;
    final habitType = widget.habitModel.habitType;

    // Determine if the habit is in "success" state (same logic as build method)
    bool isSuccess = false;
    if (habitType == HabitType.boolean) {
      isSuccess = isNegative
          ? !widget.submissionModel.value
          : widget.submissionModel.value;
    } else if (habitType == HabitType.counter) {
      isSuccess = isNegative
          ? widget.submissionModel.count == 0
          : widget.submissionModel.count > 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (!widget.habitModel.isPositive)
                Icon(
                  Icons.block,
                  color: isSuccess
                      ? CustomColors.whiteColor
                      : CustomColors.redColor,
                  size: 14.sp,
                ),
              if (!widget.habitModel.isPositive) SizedBox(width: 1.w),
              Expanded(
                child: TextScroll(
                  widget.habitModel.name,
                  style: widget.theme.textTheme.headlineLarge?.copyWith(
                    color: isSuccess
                        ? CustomColors.whiteColor
                        : CustomColors.blackColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: widget.onDelete,
          child: Icon(
            Icons.cancel_outlined,
            color: isSuccess ? CustomColors.whiteColor : CustomColors.redColor,
            size: 18.sp,
          ),
        )
      ],
    );
  }

  Widget _buildQuestionText() {
    final isNegative = !widget.habitModel.isPositive;
    final habitType = widget.habitModel.habitType;

    // Determine if the habit is in "success" state (same logic as build method)
    bool isSuccess = false;
    if (habitType == HabitType.boolean) {
      isSuccess = isNegative
          ? !widget.submissionModel.value
          : widget.submissionModel.value;
    } else if (habitType == HabitType.counter) {
      isSuccess = isNegative
          ? widget.submissionModel.count == 0
          : widget.submissionModel.count > 0;
    }

    return Text(
      widget.habitModel.question,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: widget.theme.textTheme.bodySmall?.copyWith(
        color: isSuccess ? CustomColors.whiteColor : CustomColors.blackColor,
      ),
    );
  }

  Widget _buildCounterControls() {
    final isNegative = !widget.habitModel.isPositive;
    final habitType = widget.habitModel.habitType;

    // Determine if the habit is in "success" state (same logic as build method)
    bool isSuccess = false;
    if (habitType == HabitType.boolean) {
      isSuccess = isNegative
          ? !widget.submissionModel.value
          : widget.submissionModel.value;
    } else if (habitType == HabitType.counter) {
      isSuccess = isNegative
          ? widget.submissionModel.count == 0
          : widget.submissionModel.count > 0;
    }

    final textColor =
        isSuccess ? CustomColors.whiteColor : CustomColors.blackColor;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Count: ${widget.submissionModel.count}',
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
              if (widget.habitModel.targetCount != null)
                Text(
                  'Target: ${widget.habitModel.targetCount}',
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontSize: 9.sp,
                  ),
                ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _decrementCount,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 28.sp,
                minHeight: 28.sp,
              ),
              icon: Icon(
                Icons.remove_circle,
                color:
                    isSuccess ? CustomColors.whiteColor : CustomColors.redColor,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 0.5.w),
            IconButton(
              onPressed: _incrementCount,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 28.sp,
                minHeight: 28.sp,
              ),
              icon: Icon(
                Icons.add_circle,
                color: isSuccess
                    ? CustomColors.whiteColor
                    : (widget.habitModel.isPositive
                        ? CustomColors.accentColor
                        : CustomColors.redColor),
                size: 18.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleColor() {
    setState(() {
      widget.submissionModel.value = !widget.submissionModel.value;
    });
    // Trigger auto-submit callback if provided
    if (widget.onToggle != null) {
      widget.onToggle!();
    }
  }

  void _incrementCount() {
    setState(() {
      widget.submissionModel.count++;
      widget.submissionModel.value = widget.submissionModel.count > 0;
    });
    // Trigger auto-submit callback if provided
    if (widget.onToggle != null) {
      widget.onToggle!();
    }
  }

  void _decrementCount() {
    setState(() {
      if (widget.submissionModel.count > 0) {
        widget.submissionModel.count--;
        widget.submissionModel.value = widget.submissionModel.count > 0;
      }
    });
    // Trigger auto-submit callback if provided
    if (widget.onToggle != null) {
      widget.onToggle!();
    }
  }
}
