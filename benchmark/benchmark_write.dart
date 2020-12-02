import 'dart:async';
import 'dart:convert' as sdk;

import 'package:json_alt/json.dart';

import 'src/bench_shared.dart';
import 'src/data.dart';
import 'src/stats.dart';

void main() async {
  assert(_assertMatching());
  await runBench(_work);
}

bool _assertMatching() {
  var values = <String, List<int>>{};
  for (var entry in _impls.entries) {
    values[entry.key] = entry.value.convert(_input);
  }

  print(
      values.entries.map((e) => [e.key, e.value.length].join('\t')).join('\n'));
  return true;
}

Future<Map<String, int>> _work() async {
  var result = <String, int>{};

  for (var entry in _impls.entries) {
    //print(entry.key);
    var items = <int>[];

    for (var i = 0; i < 20; i++) {
      items.add((await _write(entry.value)).inMicroseconds);
    }

    var stats = Stats.fromData(items);
    //print(_pretty(stats));

    var trackingValue = stats.min.toInt();
    //print('  ${Duration(microseconds: trackingValue)}');

    result[entry.key] = trackingValue;
  }

  return result;
}

final _impls = <String, Converter<Object, List<int>>>{
  'fused': _fusedEncoder,
  'unifed': _unifiedEncoder,
  'custom': _customFun,
  'lrhn': LrhnConverter(),
};

final _fusedEncoder = sdk.json.encoder.fuse(sdk.utf8.encoder);

final _unifiedEncoder = sdk.JsonUtf8Encoder();

final _customFun = JsonUtf8Encoder(writer: _writer);

bool _writer(Object object, JsonWriter writer) {
  if (Example.writeJson(object, writer)) {
    return true;
  }

  if (object is DateTime) {
    writer.writeObject(object.toIso8601String());
    return true;
  }

  return false;
}

final _input = [
  List.generate(100, (i) => getExampleClass(3, 3), growable: false)
];

int _lastByteValue;

Future<Duration> _write(Converter<Object, List<int>> converter) async {
  // create a list of `Fun` of length `length`

  var stopWatch = Stopwatch()..start();
  var bytes =
      await converter.bind(Stream.fromIterable(_input)).expand((e) => e).length;

  assert(_lastByteValue == null || _lastByteValue == bytes);
  _lastByteValue = bytes;

  stopWatch.stop();

  return stopWatch.elapsed;
}
