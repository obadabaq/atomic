part of 'habit_bloc.dart';

abstract class HabitEvent {
  const HabitEvent();
}

class OnGettingHabitsEvent extends HabitEvent {
  const OnGettingHabitsEvent();
}

class OnAddingHabitEvent extends HabitEvent {
  final HabitModel habitModel;

  const OnAddingHabitEvent(this.habitModel);
}

class OnDeletingHabitEvent extends HabitEvent {
  final HabitModel habitModel;

  const OnDeletingHabitEvent(this.habitModel);
}

class OnSubmittingHabitsEvent extends HabitEvent {
  final List<HabitModel> submittedHabits;

  const OnSubmittingHabitsEvent(this.submittedHabits);
}

class OnReorderingHabitsEvent extends HabitEvent {
  final List<HabitModel> reorderedHabits;

  const OnReorderingHabitsEvent(this.reorderedHabits);
}
