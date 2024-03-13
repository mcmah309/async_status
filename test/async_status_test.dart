import 'package:async_status/async_status.dart';
import 'package:test/test.dart';

void main(){

  test("Can use switch statement non-null",(){
    final status = AsyncStatus.loading(1);
    final int val;
    switch(status){
      case AsyncLoading<int>(:final data?):
      case AsyncData<int>(:final data):
        val = data;
      case AsyncError<int>(error:final _):
        val = 0;
      case AsyncLoading<int>():
        val = -1;
    }
    expect(val,1);
  });

  test("Can use switch statement non-null 2",(){
    final status = AsyncStatus.loading(1);
    final int val;
    switch(status){
      case AsyncData<int>(:final data):
        val = data;
      case AsyncError<int>(error:final _):
        val = 0;
      case AsyncLoading<int>():
        val = -1;
    }
    expect(val,-1);
  });
}