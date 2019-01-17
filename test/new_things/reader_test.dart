import 'dart:convert' as sdk;

import 'package:json_alt/json.dart';
import 'package:test/test.dart';

import '../../example/example.dart';
import 'example_test_values.dart';

void main() {
  test('sanity', () {
    var decoder = const MyJsonDecoder();

    var encodedInput = sdk.jsonEncode([
      null,
      1,
      true,
      'str',
      {'key': 'value'},
    ]);
    var thing = decoder.convert(encodedInput);
    expect(sdk.jsonEncode(thing), encodedInput);
  });

  void testPair(k, v) {
    if (v is! Example) {
      return;
    }
    final sdkString = sdk.json.encode(v);
    test(k, () {
      final decodedObject =
          parseJsonExperimental(sdkString, Example.createReader());

      try {
        final reEncodedString = sdk.json.encode(decodedObject);
        expect(reEncodedString, sdkString);
      } catch (e) {
        if (e is sdk.JsonUnsupportedObjectError) {
          Object error = e;

          var count = 1;

          while (error is sdk.JsonUnsupportedObjectError) {
            var juoe = error as sdk.JsonUnsupportedObjectError;
            print(
                '(${count++}) $error ${juoe.unsupportedObject} ${juoe.unsupportedObject.runtimeType} !!!');
            error = juoe.cause;
          }

          if (error != null) {
            print('(${count++}) $error ???');
          }
        }
        rethrow;
      }
    });
  }

  for (var entry in newTestItems.entries) {
    testPair(entry.key, entry.value);
  }
}
