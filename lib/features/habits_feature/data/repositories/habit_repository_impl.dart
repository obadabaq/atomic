import 'package:atomic/core/errors/failures.dart';
import 'package:atomic/core/helpers/functional_types.dart';
import 'package:atomic/features/habits_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/habits_feature/domain/models/habit_model.dart';
import 'package:atomic/features/habits_feature/domain/repositories/abstract_habit_repository.dart';

class HabitRepositoryImpl extends AbstractHabitRepository {
  final HabitLocalDataSource _habitLocalDataSource;

  HabitRepositoryImpl(this._habitLocalDataSource);

  @override
  FunctionalFuture<Failure, List<HabitModel>> getHabits() async {
    return await _habitLocalDataSource.getHabits();
  }

  @override
  FunctionalFuture<Failure, List<HabitModel>> addHabit(
      HabitModel habitModel) async {
    return await _habitLocalDataSource.addHabit(habitModel);
  }

  @override
  FunctionalFuture<Failure, List<HabitModel>> deleteHabit(
      HabitModel habitModel) async {
    return await _habitLocalDataSource.deleteHabit(habitModel);
  }

  @override
  FunctionalFuture<Failure, List<HabitModel>> submitHabits(
      List<HabitModel> submittedHabits) async {
    return await _habitLocalDataSource.submitHabits(submittedHabits);
  }
}
