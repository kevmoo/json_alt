// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_single_quotes

import 'package:json_alt/json.dart';

import "src/expect.dart";
import 'test_util.dart';
import 'test_values.dart';

typedef _Callback = void Function(Object input);

class _MyStringConversionSink extends StringConversionSinkBase {
  final _buffer = StringBuffer();
  _Callback callback;

  _MyStringConversionSink(this.callback);

  @override
  void addSlice(str, start, end, bool isLast) {
    _buffer.write(str.substring(start, end));
    if (isLast) close();
  }

  @override
  void close() {
    callback(_buffer.toString());
  }
}

String _encode(Object o) {
  String result;
  ChunkedConversionSink<String> stringSink =
      _MyStringConversionSink((x) => result = x as String);
  var objectSink = const JsonEncoder().startChunkedConversion(stringSink);
  objectSink.add(o);
  objectSink.close();
  return result;
}

String _encode2(Object o) {
  String result;
  var encoder = const JsonEncoder();
  ChunkedConversionSink<String> stringSink =
      StringConversionSink.withCallback((x) => result = x);
  var objectSink = encoder.startChunkedConversion(stringSink);
  objectSink.add(o);
  objectSink.close();
  return result;
}

void main() {
  testAll<List>(testValues, (value) {
    var o = value[0];
    var expected = value[1] as String;
    Expect.equals(expected, _encode(o));
    Expect.equals(expected, _encode2(o));
  });
}
