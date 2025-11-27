import 'package:atomic/core/abstracts/use_case.dart';
import 'package:atomic/core/helpers/widget_helper.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/habits_feature/domain/usecases/habit_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part "habit_event.dart";

part "habit_state.dart";

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final HabitUseCase habitUseCase;
  final WidgetHelper widgetHelper;

  HabitBloc({
    required this.habitUseCase,
    required this.widgetHelper,
  }) : super(HabitInitial()) {
    on<OnGettingHabitsEvent>(_onGettingHabitsEvent);
    on<OnAddingHabitEvent>(_onAddingHabitsEvent);
    on<OnDeletingHabitEvent>(_onDeletingHabitsEvent);
    on<OnSubmittingHabitsEvent>(_onSubmittingHabitsEvent);
    on<OnReorderingHabitsEvent>(_onReorderingHabitsEvent);
  }

  _onGettingHabitsEvent(
      OnGettingHabitsEvent event, Emitter<HabitState> emitter) async {
    final result = await habitUseCase.call(
      NoParams(),
    );
    result.fold((l) {
      emitter(ErrorGetHabitsState(l.error));
    }, (r) {
      emitter(SuccessGetHabitsState(r));
      // Update widget after successfully fetching habits
      widgetHelper.updateHabitsWidget();
    });
  }

  _onAddingHabitsEvent(
      OnAddingHabitEvent event, Emitter<HabitState> emitter) async {
    final result = await habitUseCase.addHabit(event.habitModel);
    result.fold((l) {
      emitter(ErrorGetHabitsState(l.error));
    }, (r) {
      emitter(SuccessGetHabitsState(r));
      // Update widget after adding habit
      widgetHelper.updateHabitsWidget();
    });
  }

  _onDeletingHabitsEvent(
      OnDeletingHabitEvent event, Emitter<HabitState> emitter) async {
    final result = await habitUseCase.deleteHabit(event.habitModel);
    result.fold((l) {
      emitter(ErrorGetHabitsState(l.error));
    }, (r) {
      emitter(SuccessGetHabitsState(r));
      // Update widget after deleting habit
      widgetHelper.updateHabitsWidget();
    });
  }

  _onSubmittingHabitsEvent(
      OnSubmittingHabitsEvent event, Emitter<HabitState> emitter) async {
    final result = await habitUseCase.submitHabits(event.submittedHabits);
    result.fold((l) {
      emitter(ErrorSubmitHabitsState(l.error));
    }, (r) {
      emitter(SuccessSubmitHabitsState(r));
      // Update widget after submitting habits (most important for widget sync)
      widgetHelper.updateHabitsWidget();
    });
  }

  _onReorderingHabitsEvent(
      OnReorderingHabitsEvent event, Emitter<HabitState> emitter) async {
    final result = await habitUseCase.reorderHabits(event.reorderedHabits);
    result.fold((l) {
      emitter(ErrorGetHabitsState(l.error));
    }, (r) {
      emitter(SuccessGetHabitsState(r));
      // Update widget after reordering
      widgetHelper.updateHabitsWidget();
    });
  }
}
