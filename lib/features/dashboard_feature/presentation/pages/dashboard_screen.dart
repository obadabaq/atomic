import 'package:atomic/core/constants/colors.dart';
import 'package:atomic/core/dependency_injection/locator.dart';
import 'package:atomic/features/dashboard_feature/presentation/widgets/calender_widget.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/habits_feature/domain/usecases/habit_use_case.dart';
import 'package:atomic/features/habits_feature/presentation/bloc/habit_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  final HabitBloc _habitBloc = HabitBloc(habitUseCase: sl<HabitUseCase>());
  late ThemeData theme;
  List<HabitModel> habits = [];
  bool _isWeekView = true;

  @override
  void initState() {
    super.initState();
    _habitBloc.add(const OnGettingHabitsEvent());
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return BlocBuilder<HabitBloc, HabitState>(
      bloc: _habitBloc,
      builder: (_, state) {
        if (state is SuccessGetHabitsState) {
          habits = state.habits;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildHabitsList(),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Your Progress", style: theme.textTheme.headlineLarge),
            TextButton(
              onPressed: _toggleView,
              child: Text(_isWeekView ? 'Month View' : 'Week View'),
            ),
          ],
        ),
        SizedBox(height: 5.h),
      ],
    );
  }

  Widget _buildHabitsList() {
    return ListView.builder(
      itemCount: habits.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _buildHabitCard(habits[index]);
      },
    );
  }

  Widget _buildHabitCard(HabitModel habit) {
    return Card(
      child: Padding(
        padding: EdgeInsets.only(top: 2.h, left: 2.h, right: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHabitHeader(habit),
            SizedBox(height: 1.h),
            CalendarWidget(habit: habit, isWeekView: _isWeekView),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitHeader(HabitModel habit) {
    return Text(
      habit.name,
      style: theme.textTheme.headlineLarge?.copyWith(
        color: CustomColors.blackColor,
      ),
    );
  }

  void _toggleView() {
    setState(() => _isWeekView = !_isWeekView);
  }
}
