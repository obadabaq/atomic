import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/habits_feature/domain/models/submission_model.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_type.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class CalendarWidget extends StatefulWidget {
  final HabitModel habit;
  final bool isWeekView;

  const CalendarWidget({
    Key? key,
    required this.habit,
    required this.isWeekView,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late ThemeData theme;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    final days = widget.isWeekView
        ? _getDaysInWeek(_selectedDate)
        : _getDaysInMonth(_selectedDate);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
            crossAxisSpacing: 1.5.w,
            mainAxisSpacing: 1.h,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final dayDate = widget.isWeekView
                ? _selectedDate
                    .add(Duration(days: index - _selectedDate.weekday + 1))
                : DateTime(_selectedDate.year, _selectedDate.month, index + 1);
            final submission = _getSubmissionForDate(dayDate);
            final isToday = _isToday(dayDate);
            final isCompleted = _isSubmissionSuccessful(submission);

            return _buildDateCard(
              days[index],
              isToday,
              isCompleted,
              submission,
            );
          },
        ),
        SizedBox(height: 3.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: CustomColors.primaryColor, size: 20),
                onPressed: _prevMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: CustomColors.primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios,
                    color: CustomColors.primaryColor, size: 20),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(
    String dateText,
    bool isToday,
    bool? isCompleted,
    SubmissionModel? submission,
  ) {
    final parts = dateText.split('-');
    final dayName = parts[0];
    final dayNumber = parts[1];
    final isCounter = widget.habit.habitType == HabitType.counter;

    // Only consider a day as having submission data if submission is not null
    final hasSubmission = submission != null;
    final isSuccessful = isCompleted == true;
    final isFailed = hasSubmission && isCompleted == false;

    return Container(
      decoration: BoxDecoration(
        gradient: isSuccessful
            ? const LinearGradient(
                colors: [
                  CustomColors.primaryColor,
                  CustomColors.accentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSuccessful
            ? null
            : (isFailed
                ? Colors.red.withOpacity(0.1)
                : CustomColors.neutralColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? CustomColors.primaryColor
              : (isSuccessful
                  ? CustomColors.primaryColor
                  : (isFailed
                      ? Colors.red.withOpacity(0.5)
                      : CustomColors.neutralColor.withOpacity(0.3))),
          width: isToday ? 2.5 : 1.5,
        ),
        boxShadow: isSuccessful
            ? [
                BoxShadow(
                  color: CustomColors.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : (isToday
                ? [
                    BoxShadow(
                      color: CustomColors.primaryColor.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : []),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isCounter && hasSubmission && submission.count > 0)
            // Display counter value for counter habits with submissions
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: isSuccessful
                    ? CustomColors.whiteColor.withOpacity(0.3)
                    : (isFailed
                        ? Colors.red.withOpacity(0.3)
                        : CustomColors.primaryColor.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                submission.count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSuccessful
                      ? CustomColors.whiteColor
                      : (isFailed ? Colors.red : CustomColors.primaryColor),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isSuccessful && !isCounter)
            // Display checkmark for completed boolean habits
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: CustomColors.whiteColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: CustomColors.whiteColor,
                size: 16.sp,
              ),
            )
          else if (isFailed && !isCounter)
            // Display X for failed boolean habits
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: 16.sp,
              ),
            )
          else
            // Display day name for days without submission or counter habits with 0 count
            Text(
              dayName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isToday
                    ? CustomColors.primaryColor
                    : CustomColors.neutralColor,
                fontSize: 8.sp,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          SizedBox(height: 0.3.h),
          Text(
            dayNumber,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isSuccessful
                  ? CustomColors.whiteColor
                  : (isFailed
                      ? Colors.red
                      : (isToday
                          ? CustomColors.primaryColor
                          : CustomColors.blackColor)),
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  List<String> _getDaysInMonth(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(
        daysInMonth,
        (i) =>
            DateFormat('EEE-d').format(DateTime(month.year, month.month, i + 1)));
  }

  List<String> _getDaysInWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(
        7, (i) => DateFormat('EEE-d').format(startOfWeek.add(Duration(days: i))));
  }

  SubmissionModel? _getSubmissionForDate(DateTime date) {
    final formattedDate = DateFormat('yMMMMd').format(date);
    try {
      return widget.habit.submissions.firstWhere(
        (submission) => submission.date == formattedDate,
      );
    } catch (e) {
      // No submission found for this date
      return null;
    }
  }

  /// Determines if a submission represents a successful day based on habit type and positivity
  /// Returns null if no submission exists (day not submitted)
  bool? _isSubmissionSuccessful(SubmissionModel? submission) {
    // If no submission exists, return null to indicate day was not submitted
    if (submission == null) {
      return null;
    }

    final habitType = widget.habit.habitType;
    final isPositive = widget.habit.isPositive;

    if (habitType == HabitType.boolean) {
      // Boolean habits:
      // - Positive: success = checked (value = true)
      // - Negative: success = NOT checked (value = false)
      return isPositive ? submission.value : !submission.value;
    } else {
      // Counter habits:
      // - Positive: success = count > 0 (did something)
      // - Negative: success = count == 0 (avoided doing something)
      return isPositive ? submission.count > 0 : submission.count == 0;
    }
  }

  void _prevMonth() {
    setState(() =>
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1));
  }

  void _nextMonth() {
    setState(() =>
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1));
  }
}
