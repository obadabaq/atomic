import 'package:atomic/core/errors/failures.dart';
import 'package:dartz/dartz.dart';

typedef FunctionalFuture<F extends Failure, T> = Future<Either<F, T>>;
