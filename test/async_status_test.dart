import 'package:async_status/async_status.dart';
import 'package:test/test.dart';

void main(){

  test("Can use switch statement non-null",(){
    final AsyncStatus<int> status = AsyncStatus.loading();
    final int val;
    switch(status){
      case AsyncReloading<int>(:final data):
      case AsyncData<int>(:final data):
        val = data;
      case AsyncError(error:final _):
        val = 0;
      case AsyncLoading():
        val = -1;
    }
    expect(val,1);
  });

  test("Can use switch statement non-null 2",(){
    final AsyncStatus<int> status = AsyncStatus.data(1);
    final int val;
    switch(status){
      case AsyncReloading<int>(:final data):
      case AsyncData<int>(:final data):
        val = data;
      case AsyncError(error:final _):
        val = 0;
      case AsyncLoading():
        val = -1;
    }
    expect(val, 1);
  });

    test("Can use switch statement nullable",(){
    final AsyncStatus<int?> status = AsyncStatus.loading();
    final int? val;
    switch(status){
      case AsyncReloading<int?>(:final data):
      case AsyncData<int?>(:final data):
        val = data;
      case AsyncError(error:final _):
        val = 0;
      case AsyncLoading():
        val = -1;
    }
    expect(val,1);
  });

  test("Can use switch statement non-null 2",(){
    final AsyncStatus<int?> status = AsyncStatus.data(1);
    final int? val;
    switch(status){
      case AsyncReloading<int?>(:final data):
      case AsyncData<int?>(:final data):
        val = data;
      case AsyncError(error:final _):
        val = 0;
      case AsyncLoading():
        val = -1;
    }
    expect(val, 1);
  });

  test("match expresion",(){
    final AsyncStatus<int> status = AsyncStatus.loading();
    final int val = status.match(
      data: (data) => data,
      error: () => 0,
      loading: () => -1,
      reloading: (data) => data,
    );
    expect(val,-1);
  });

  test("Can use switch expresion",(){
    final AsyncStatus<int> status = AsyncStatus.loading();
    final int val = switch(status){
      AsyncReloading<int>(:final data) || AsyncReloading<int>(:final data) => data,
      AsyncData<int>(:final data) => data,
      AsyncError(error:final _) => 0,
      AsyncLoading() => -1,
    };
    expect(val,-1);
  });

  test("casting",(){
    AsyncStatus<int> start = AsyncStatus.loading();
    AsyncStatus<num> casted = start.cast<num>();
    
    start = AsyncStatus.data(1);
    casted = start.cast<num>();
    expect(casted,AsyncStatus.data(1));

    start = AsyncStatus.error("error");
    casted = start.cast<num>();
    expect(casted,AsyncStatus.error("error"));
  });
}