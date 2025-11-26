import 'package:atomic/features/notes_feature/data/repositories/note_repository_impl.dart';
import 'package:atomic/features/notes_feature/data/sources/local_data_source.dart';
import 'package:atomic/features/notes_feature/domain/repositories/abstract_note_repository.dart';
import 'package:atomic/features/notes_feature/domain/usecases/note_use_case.dart';
import 'package:atomic/features/notes_feature/presentation/bloc/note_bloc.dart';
import 'package:get_it/get_it.dart';

void initNoteFeature(GetIt getIt) {
  // Data Sources
  getIt.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(getIt(), getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AbstractNoteRepository>(
    () => NoteRepositoryImpl(getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => NoteUseCase(getIt()));

  // BLoC
  getIt.registerFactory(
    () => NoteBloc(noteUseCase: getIt()),
  );
}
