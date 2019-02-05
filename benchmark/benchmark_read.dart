import 'dart:async';
import 'dart:convert' as sdk;

import 'package:json_alt/json.dart';

import 'src/bench_shared.dart';
import 'src/data.dart';
import 'src/stats.dart';

final _inputBytes = sdk.JsonUtf8Encoder().convert(getExampleClass(6, 6));

void main() async {
  print(_inputBytes.length);
  assert(_ensureMatching());
  await runBench(_work);
}

bool _ensureMatching() {
  var results = <String, String>{};
  for (var output in _impls.entries) {
    var result = output.value(_inputBytes);
    results[output.key] = sdk.jsonEncode(result);
  }

  /*
  print(results.entries
      .map((e) => [e.key, e.value.length, e.value].join('\t'))
      .join('\n'));
      */

  return results.values.skip(1).every((v) => v == results.values.first);
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

final _impls = <String, Example Function(List<int>)>{
  'sdk': sdkJsonFunction,
  'custom': _custom
};

final _fusedDecoder = sdk.utf8.decoder.fuse(sdk.json.decoder);

Example sdkJsonFunction(List<int> bytes) =>
    Example.fromJson(_fusedDecoder.convert(bytes) as Map<String, dynamic>);

final _customDecoder = MyJsonUtf8Decoder(reader: Example.createReader());

Example _custom(List<int> bytes) => _customDecoder.convert(bytes);

Duration _read(Example Function(List<int>) converter) {
  // create a list of `Fun` of length `length`

  var stopWatch = Stopwatch()..start();
  var object = converter(_inputBytes);

  stopWatch.stop();

  assert(object != null);

  return stopWatch.elapsed;
}
