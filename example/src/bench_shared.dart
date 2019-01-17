import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

Future runBench(Future<Map<String, int>> Function() _work) async {
  var sub = stdin.listen((data) {
    print('stdin: `${systemEncoding.decode(data)}`');
    if (_enterCompleter != null) {
      _enterCompleter.complete();
      _enterCompleter = null;
    }
  });

  try {
    var result = <String, int>{};
    for (var i = 0; i < 100; i++) {
      var newResult = await _work();

      for (var e in newResult.entries) {
        var current = result[e.key];
        if (current == null || e.value < current) {
          result[e.key] = e.value;
        }
      }

      printResults(result);
    }
  } finally {
    await sub.cancel();
  }
}

void printResults(Map<String, int> result) {
  var length =
      result.entries.fold(0, (int length, e) => math.max(length, e.key.length));

  var fastest = result.entries.skip(1).fold(result.entries.first.value,
      (int microseconds, e) => math.min(microseconds, e.value));

  print('\n');
  print(result.entries.map((e) {
    var pct = ((100 * e.value / fastest) - 100).toStringAsFixed(2).padLeft(10);
    pct = '$pct%';

    return [e.key.padRight(length), e.value.toString().padLeft(10), pct]
        .join(' ');
  }).join('\n'));
}

Completer _enterCompleter;

Future<void> waitForEnter(String message) {
  if (_enterCompleter != null) {
    throw StateError('boo!');
  }
  _enterCompleter = Completer();

  print(message);

  return _enterCompleter.future;
}

String prettyJson(Object obj) => const JsonEncoder.withIndent(' ').convert(obj);
