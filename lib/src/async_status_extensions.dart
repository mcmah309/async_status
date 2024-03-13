import 'package:async_status/async_status.dart';

extension AsyncStatusStream<T> on Stream<T> {
  Stream<AsyncStatus<T>> toAsyncStatus() {
    return map((value) => AsyncData(value)).handleError((error, stackTrace) => AsyncError(error, stackTrace));
  }
}

extension AsyncStatusFuture<T> on Future<T> {
  Future<AsyncStatus<T>> toAsyncStatus() async {
    try {
      return AsyncData(await this);
    } catch (err, stack) {
      return AsyncError(err, stack);
    }
  }
}