import 'package:async_status/async_status.dart';

extension AsyncStatusStream<T extends Object> on Stream<T> {
  Stream<AsyncStatus<T>> toAsyncStatus() {
    return map((value) => AsyncData(value)).handleError((error, stackTrace) => AsyncError(error, stackTrace));
  }
}

extension AsyncStatusFuture<T extends Object> on Future<T> {
  Future<AsyncStatus<T>> toAsyncStatus() async {
    try {
      return AsyncData(await this);
    } catch (err, stack) {
      return AsyncError(err, stack);
    }
  }
}