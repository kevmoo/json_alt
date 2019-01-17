// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_single_quotes

import 'dart:async';

import 'package:test/test.dart';
import 'package:json_alt/json.dart';

import "src/expect.dart";
import 'test_util.dart';
import 'test_values.dart';

Stream<String> encode(Object o) {
  var encoder = const JsonEncoder();
  StreamController controller;
  controller = StreamController(onListen: () {
    controller.add(o);
    controller.close();
  });
  return controller.stream.transform(encoder);
}

void testNoPause(String expected, Object o) {
  Stream stream = encode(o);
  stream.toList().then(expectAsync1((list) {
    var buffer = StringBuffer();
    buffer.writeAll(list);
    Expect.stringEquals(expected, buffer.toString());
  }));
}

void testWithPause(String expected, Object o) {
  Stream stream = encode(o);
  var buffer = StringBuffer();
  StreamSubscription sub;
  sub = stream.listen((x) {
    buffer.write(x);
    sub.pause(Future.delayed(Duration.zero));
  }, onDone: expectAsync0(() {
    Expect.stringEquals(expected, buffer.toString());
    sub.cancel();
  }));
}

void main() {
  testAll(testValues, (value) {
    var o = value[0];
    var expected = value[1] as String;
    testNoPause(expected, o);
    testWithPause(expected, o);
  });
}
