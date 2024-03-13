import 'dart:async';

/// A utility for safely manipulating representing the state of asynchronous data.
///
/// By using [AsyncStatus], you are guaranteed that you cannot forget to
/// handle the loading/reloading/error state of an asynchronous operation.
///
/// - [AsyncStatus.guard], to simplify transforming a [Future] into an [AsyncStatus].
sealed class AsyncStatus<T> {

  /// {@template aysncstatus.data}
  /// Creates an [AsyncStatus] with a data.
  /// {@endtemplate}
  const factory AsyncStatus.data(T value) = AsyncData<T>;

  /// {@template aysncstatus.loading}
  /// Creates an [AsyncStatus] in loading state.
  ///
  /// Prefer always using this constructor with the `const` keyword.
  /// {@endtemplate}
  const factory AsyncStatus.loading() = AsyncLoading<T>;

  /// {@template aysncstatus.reloading}
  /// Creates an [AsyncStatus] in reloading state. Data exists and is being refreshed.
  /// {@endtemplate}
  const factory AsyncStatus.reloading(T value) = AsyncReloading<T>;

  /// {@template aysncstatus.error_ctor}
  /// Creates an [AsyncStatus] in the error state.
  /// ```dart
  /// AysncStatus.error(error, StackTrace.current);
  /// ```
  /// {@endtemplate}
  const factory AsyncStatus.error(Object error, [StackTrace? stackTrace]) =
      AsyncError<T>;

  /// Transforms a [Future] that may fail into something that is safe to read.
  ///
  /// This is useful to avoid having to do a tedious `try/catch`. Instead of
  /// writing:
  ///
  /// ```dart
  /// class MyNotifier extends AsyncNotifier<MyData> {
  ///   @override
  ///   Future<MyData> build() => Future.value(MyData());
  ///
  ///   Future<void> sideEffect() async {
  ///     state = const AysncStatus.loading();
  ///     try {
  ///       final response = await dio.get('my_api/data');
  ///       final data = MyData.fromJson(response);
  ///       state = AysncStatus.data(data);
  ///     } catch (err, stack) {
  ///       state = AysncStatus.error(err, stack);
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// We can use [guard] to simplify it:
  ///
  /// ```dart
  /// class MyNotifier extends AsyncNotifier<MyData> {
  ///   @override
  ///   Future<MyData> build() => Future.value(MyData());
  ///
  ///   Future<void> sideEffect() async {
  ///     state = const AysncStatus.loading();
  ///     // does the try/catch for us like previously
  ///     state = await AysncStatus.guard(() async {
  ///       final response = await dio.get('my_api/data');
  ///       return Data.fromJson(response);
  ///     });
  ///   }
  /// }
  ///
  /// An optional callback can be specified to catch errors only under a certain condition.
  /// In the following example, we catch all exceptions beside FormatExceptions.
  ///
  /// ```dart
  ///   AysncStatus.guard(
  ///    () async { /* ... */ },
  ///     // Catch all errors beside [FormatException]s.
  ///    (err) => err is! FormatException,
  ///   );
  /// }
  /// ```
  static Future<AsyncStatus<T>> guard<T>(
    FutureOr<T> Function() future, [
    bool Function(Object)? isValidErr,
  ]) async {
    try {
      return AsyncStatus.data(await future());
    } catch (err, stack) {
      if (isValidErr == null) {
        return AsyncStatus.error(err, stack);
      }
      if (isValidErr(err)) {
        return AsyncStatus.error(err, stack);
      }

      Error.throwWithStackTrace(err, stack);
    }
  }

  /// Perform some action based on the current state of the [AsyncStatus].
  ///
  /// This allows reading the content of an [AsyncStatus] in a type-safe way,
  /// without potentially forgetting to handle a case.
  R match<R>({
    required R Function(AsyncData<T> data) data,
    required R Function(AsyncError<T> error) error,
    required R Function(AsyncLoading<T> loading) loading,
    required R Function(AsyncReloading<T> reloading) reloading,
  });

  /// Casts the [AsyncStatus] to a different type.
  AsyncStatus<R> cast<R>();
}

/// {@macro aysncstatus.data}
final class AsyncData<T> implements AsyncStatus<T> {
  /// {@macro aysncstatus.data}
  const AsyncData(this.data);

  final T data;

  @override
  R match<R>({
    required R Function(AsyncData<T> data) data,
    required R Function(AsyncError<T> error) error,
    required R Function(AsyncLoading<T> loading) loading,
    required R Function(AsyncReloading<T> reloading) reloading,
  }) {
    return data(this);
  }

  @override
  AsyncStatus<R> cast<R>() { //todo test
    return this as AsyncStatus<R>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncData && data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// {@macro aysncstatus.loading}
final class AsyncLoading<T> implements AsyncStatus<T> {
  /// {@macro aysncstatus.loading}
  const AsyncLoading();

  @override
  R match<R>({
    required R Function(AsyncData<T> data) data,
    required R Function(AsyncError<T> error) error,
    required R Function(AsyncLoading<T> loading) loading,
    required R Function(AsyncReloading<T> reloading) reloading,
  }) {
    return loading(this);
  }

  @override
  AsyncLoading<R> cast<R>() {
    return this as AsyncLoading<R>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AsyncLoading;
  
  @override
  int get hashCode => 0;
}

/// {@macro aysncstatus.reloading}
final class AsyncReloading<T> implements AsyncStatus<T> {
  /// {@macro aysncstatus.reloading}
  const AsyncReloading(this.data);

  final T data;

  @override
  R match<R>({
    required R Function(AsyncData<T> data) data,
    required R Function(AsyncError<T> error) error,
    required R Function(AsyncLoading<T> loading) loading,
    required R Function(AsyncReloading<T> reloading) reloading,
  }) {
    return reloading(this);
  }

  @override
  AsyncLoading<R> cast<R>() {
    return this as AsyncLoading<R>;
  }

  /// Transition to [AsyncData] state.
  AsyncData<T> toData() {
    return AsyncData(data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncReloading && data == other.data;
  
  @override
  int get hashCode => data.hashCode;
}

/// {@macro aysncstatus.error_ctor}
final class AsyncError<T> implements AsyncStatus<T> {
  /// {@macro aysncstatus.error_ctor}
  const AsyncError(this.error, [this.stackTrace]);

  final Object error;

  final StackTrace? stackTrace;

  @override
  R match<R>({
    required R Function(AsyncData<T> data) data,
    required R Function(AsyncError<T> error) error,
    required R Function(AsyncLoading<T> loading) loading,
    required R Function(AsyncReloading<T> reloading) reloading,
  }) {
    return error(this);
  }
  
  @override
  AsyncStatus<R> cast<R>() {
    return this as AsyncStatus<R>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncError &&
          error == other.error &&
          stackTrace == other.stackTrace;

  @override
  int get hashCode => error.hashCode ^ stackTrace.hashCode;
}
