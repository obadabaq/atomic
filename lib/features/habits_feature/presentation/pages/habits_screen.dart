import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/dependency_injection/locator.dart';
import 'package:atomic/core/widgets/custom_text_field.dart';
import 'package:atomic/features/dashboard_feature/presentation/widgets/calender_widget.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/habits_feature/domain/models/submission_model.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_type.dart';
import 'package:atomic/features/habits_feature/presentation/bloc/habit_bloc.dart';
import 'package:atomic/features/habits_feature/presentation/widgets/habit_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({Key? key}) : super(key: key);

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late ThemeData theme;
  late String date;
  late TabController _tabController;
  late DateTime selectedDate;

  final HabitBloc _habitBloc = sl<HabitBloc>();
  List<HabitModel> habits = [];
  final Map<int, bool> _habitViewModes = {}; // true = week view, false = month view

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _targetCountController = TextEditingController();

  HabitType _selectedHabitType = HabitType.boolean;
  bool _isPositiveHabit = true;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    date = DateFormat('yMMMMd').format(selectedDate);
    _tabController = TabController(length: 2, vsync: this);
    getHabits();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _habitBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return BlocConsumer<HabitBloc, HabitState>(
      bloc: _habitBloc,
      listener: (context, state) {
        if (state is SuccessSubmitHabitsState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: CustomColors.whiteColor),
                  SizedBox(width: 2.w),
                  const Text('Habit saved'),
                ],
              ),
              backgroundColor: CustomColors.accentColor,
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 2.h, left: 5.w, right: 5.w),
            ),
          );
          getHabits();
        } else if (state is ErrorSubmitHabitsState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: CustomColors.whiteColor),
                  SizedBox(width: 2.w),
                  Expanded(child: Text(state.error)),
                ],
              ),
              backgroundColor: CustomColors.redColor,
              duration: const Duration(milliseconds: 2500),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 2.h, left: 5.w, right: 5.w),
            ),
          );
        }
      },
      builder: (_, state) {
        if (state is SuccessGetHabitsState) {
          habits = state.habits;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Atomic Habits'),
              backgroundColor: Colors.white,
              foregroundColor: CustomColors.blackColor,
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: CustomColors.primaryColor,
                labelColor: CustomColors.primaryColor,
                unselectedLabelColor: Colors.black45,
                tabs: const [
                  Tab(text: 'Today', icon: Icon(Icons.today)),
                  Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(),
                _buildAnalyticsTab(),
              ],
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildTodayTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      children: [
        _buildHeader(),
        _buildHabitGrid(),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Progress", style: theme.textTheme.headlineLarge),
          SizedBox(height: 3.h),
          _buildHabitsList(),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return ListView.builder(
      itemCount: habits.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildAnalyticsHabitCard(habits[index]);
      },
    );
  }

  Widget _buildAnalyticsHabitCard(HabitModel habit) {
    // Get the current view mode for this habit (default to week view)
    // Use habit.id if available, otherwise use habit.name as key
    final habitKey = habit.id ?? habit.name.hashCode;
    final isWeekView = _habitViewModes[habitKey] ?? true;

    return Card(
      child: Padding(
        padding: EdgeInsets.only(top: 2.h, left: 2.h, right: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    habit.name,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: CustomColors.blackColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleHabitView(habitKey),
                  icon: Icon(
                    isWeekView ? Icons.calendar_month : Icons.view_week,
                    color: CustomColors.primaryColor,
                  ),
                  tooltip: isWeekView ? 'Month View' : 'Week View',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            CalendarWidget(habit: habit, isWeekView: isWeekView),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isToday = _isSameDay(selectedDate, DateTime.now());
    final headerTitle = isToday ? "Today's Progress" : "Progress";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headerTitle, style: theme.textTheme.headlineLarge),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12.sp,
                        color: isToday
                            ? CustomColors.primaryColor
                            : CustomColors.blackColor,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isToday
                              ? CustomColors.primaryColor
                              : CustomColors.blackColor,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CustomColors.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CustomColors.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: openAddHabitPopup,
                icon: Icon(
                  Icons.add_rounded,
                  color: CustomColors.whiteColor,
                  size: 24.sp,
                ),
                tooltip: 'Add New Habit',
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildDateNavigation(),
      ],
    );
  }

  Widget _buildDateNavigation() {
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: CustomColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CustomColors.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _goToPreviousDay,
            icon: const Icon(Icons.chevron_left),
            color: CustomColors.primaryColor,
            tooltip: 'Previous Day',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: InkWell(
              onTap: _showDatePicker,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: CustomColors.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 16.sp,
                      color: CustomColors.primaryColor,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      DateFormat('EEEE, MMM d, y').format(selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: CustomColors.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: isToday ? null : _goToNextDay,
            icon: const Icon(Icons.chevron_right),
            color: isToday
                ? Colors.grey.withOpacity(0.3)
                : CustomColors.primaryColor,
            tooltip: 'Next Day',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitGrid() {
    if (habits.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 10.h),
          child: Column(
            children: [
              Icon(
                Icons.track_changes,
                size: 80.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 2.h),
              Text(
                'No habits yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Tap + to add your first habit',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort habits by order field
    final sortedHabits = List<HabitModel>.from(habits)
      ..sort((a, b) => a.order.compareTo(b.order));

    return ReorderableListView.builder(
      padding: EdgeInsets.only(top: 4.h),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedHabits.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = sortedHabits.removeAt(oldIndex);
          sortedHabits.insert(newIndex, item);

          // Update habits list with new order
          habits = sortedHabits;

          // Trigger reorder event
          _habitBloc.add(OnReorderingHabitsEvent(sortedHabits));
        });
      },
      itemBuilder: (context, index) {
        final habit = sortedHabits[index];
        return Container(
          key: ValueKey(habit.id),
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: HabitCard(
            theme: theme,
            habitModel: habit,
            submissionModel: getTodaySubmission(habit),
            onDelete: () => deleteHabit(habit),
            onToggle: () => autoSubmitHabits(),
          ),
        );
      },
    );
  }

  void _toggleHabitView(int habitId) {
    setState(() {
      // Toggle the view mode for this specific habit
      final currentMode = _habitViewModes[habitId] ?? true;
      _habitViewModes[habitId] = !currentMode;
    });
  }

  void openAddHabitPopup() {
    // Reset form state
    _nameController.clear();
    _questionController.clear();
    _targetCountController.clear();
    _selectedHabitType = HabitType.boolean;
    _isPositiveHabit = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Habit'),
              content: SingleChildScrollView(
                child: _buildHabitForm(setDialogState),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  onPressed: addHabit,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHabitForm(StateSetter setDialogState) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 80.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _nameController,
              label: "Habit name",
              hint: "e.g. Exercise",
            ),
            SizedBox(height: 2.h),
            CustomTextField(
              controller: _questionController,
              label: "Habit question",
              hint: "e.g. Did you exercise today?",
            ),
            SizedBox(height: 2.h),
            Text(
              "Habit Type",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            DropdownButtonFormField<HabitType>(
              value: _selectedHabitType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              items: const [
                DropdownMenuItem(
                  value: HabitType.boolean,
                  child: Text('Yes/No (Checkbox)'),
                ),
                DropdownMenuItem(
                  value: HabitType.counter,
                  child: Text('Counter (Track quantity)'),
                ),
              ],
              onChanged: (value) {
                setDialogState(() {
                  _selectedHabitType = value!;
                });
              },
            ),
            SizedBox(height: 2.h),
            Text(
              "Habit Nature",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setDialogState(() {
                        _isPositiveHabit = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: _isPositiveHabit
                            ? CustomColors.accentColor
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isPositiveHabit
                              ? CustomColors.primaryColor
                              : Colors.grey,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: _isPositiveHabit
                                ? CustomColors.whiteColor
                                : Colors.grey[600],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Positive Habit',
                            style: TextStyle(
                              color: _isPositiveHabit
                                  ? CustomColors.whiteColor
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'To build',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: _isPositiveHabit
                                  ? CustomColors.whiteColor
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setDialogState(() {
                        _isPositiveHabit = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: !_isPositiveHabit
                            ? CustomColors.redColor.withOpacity(0.8)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: !_isPositiveHabit
                              ? CustomColors.redColor
                              : Colors.grey,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.block,
                            color: !_isPositiveHabit
                                ? CustomColors.whiteColor
                                : Colors.grey[600],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Negative Habit',
                            style: TextStyle(
                              color: !_isPositiveHabit
                                  ? CustomColors.whiteColor
                                  : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'To avoid',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: !_isPositiveHabit
                                  ? CustomColors.whiteColor
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedHabitType == HabitType.counter) ...[
              SizedBox(height: 2.h),
              CustomTextField(
                controller: _targetCountController,
                label: "Target Count (Optional)",
                hint: "e.g. 8",
                isNumber: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void getHabits() {
    _habitBloc.add(const OnGettingHabitsEvent());
  }

  void addHabit() {
    HabitModel habitModel = HabitModel(
      name: _nameController.text,
      question: _questionController.text,
      submissions: [],
      habitType: _selectedHabitType,
      isPositive: _isPositiveHabit,
      targetCount: _targetCountController.text.isNotEmpty
          ? int.tryParse(_targetCountController.text)
          : null,
    );
    _habitBloc.add(OnAddingHabitEvent(habitModel));
    Navigator.of(context).pop();
  }

  void deleteHabit(HabitModel habitModel) {
    _habitBloc.add(OnDeletingHabitEvent(habitModel));
  }

  void autoSubmitHabits() {
    _habitBloc.add(OnSubmittingHabitsEvent(habits));
  }

  SubmissionModel getTodaySubmission(HabitModel habit) {
    return habit.submissions.firstWhere(
      (submission) => submission.date == date,
      orElse: () {
        SubmissionModel sub = SubmissionModel(value: false, date: date);
        habit.submissions.add(sub);
        return sub;
      },
    );
  }

  void _showDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CustomColors.primaryColor,
              onPrimary: CustomColors.whiteColor,
              onSurface: CustomColors.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && !_isSameDay(pickedDate, selectedDate)) {
      setState(() {
        selectedDate = pickedDate;
        date = DateFormat('yMMMMd').format(selectedDate);
      });
    }
  }

  void _goToPreviousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      date = DateFormat('yMMMMd').format(selectedDate);
    });
  }

  void _goToNextDay() {
    final tomorrow = selectedDate.add(const Duration(days: 1));
    if (!_isSameDay(tomorrow, DateTime.now().add(const Duration(days: 1)))) {
      setState(() {
        selectedDate = tomorrow;
        date = DateFormat('yMMMMd').format(selectedDate);
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
