import 'dart:async';
import 'dart:convert' as sdk;

import 'package:json/json.dart';

import 'src/bench_shared.dart';
import 'src/data.dart';
import 'src/stats.dart';

final _inputBytes = sdk.JsonUtf8Encoder().convert(getExampleClass(6, 6));

void main() async {
  print(_inputBytes.length);
  await runBench(_work);
}

Future<Map<String, int>> _work() async {
  var result = <String, int>{};

  for (var entry in _impls.entries) {
    //print(entry.key);
    var items = <int>[];

    for (var i = 0; i < 20; i++) {
      items.add((_read(entry.value)).inMicroseconds);
    }

    var stats = Stats.fromData(items);
    //print(_pretty(stats));

    var trackingValue = stats.min.toInt();
    //print('  ${Duration(microseconds: trackingValue)}');

    result[entry.key] = trackingValue;
  }

  return result;
}

final _impls = <String, Fun Function(List<int>)>{
  'sdk': sdkJsonFunction,
  'custom': _custom
};

final _fusedDecoder = sdk.utf8.decoder.fuse(sdk.json.decoder);

Fun sdkJsonFunction(List<int> bytes) =>
    Fun.fromJson(_fusedDecoder.convert(bytes) as Map<String, dynamic>);

final _customDecoder = MyJsonUtf8Decoder(reader: Fun.createReader());

Fun _custom(List<int> bytes) => _customDecoder.convert(bytes);

Duration _read(Fun Function(List<int>) converter) {
  // create a list of `Fun` of length `length`

  var stopWatch = Stopwatch()..start();
  var object = converter(_inputBytes);

  stopWatch.stop();

  assert(object != null);

  return stopWatch.elapsed;
}
