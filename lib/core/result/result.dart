import '../errors/app_error.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get value => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  AppError? get error => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    Failure<T>(:final error) => onFailure(error),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  @override
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  @override
  final AppError error;
}
