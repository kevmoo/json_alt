// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_single_quotes,omit_local_variable_types

import 'package:test/test.dart' as t;

/// Expect is used for tests that do not want to make use of the
/// Dart unit test library - for example, the core language tests.
/// Third parties are discouraged from using this, and should use
/// the expect() function in the unit test library instead for
/// test assertions.
class Expect {
  /// Checks whether the expected and actual values are equal (using `==`).
  static void equals(var expected, var actual, [String reason]) {
    t.expect(actual, t.equals(expected), reason: reason);
  }

  /// Checks whether the actual value is a bool and its value is true.
  static void isTrue(var actual, [String reason]) {
    if (_identical(actual, true)) return;
    String msg = _getMessage(reason);
    t.fail("Expect.isTrue($actual$msg) fails.");
  }

  /// Checks whether the actual value is a bool and its value is false.
  static void isFalse(var actual, [String reason]) {
    if (_identical(actual, false)) return;
    String msg = _getMessage(reason);
    t.fail("Expect.isFalse($actual$msg) fails.");
  }

  /// Checks whether [actual] is null.
  static void isNull(actual, [String reason]) {
    if (null == actual) return;
    String msg = _getMessage(reason);
    t.fail("Expect.isNull(actual: <$actual>$msg) fails.");
  }

  // Unconditional failure.
  static void fail(String msg) {
    t.fail("Expect.fail('$msg')");
  }

  /// Checks that all elements in [expected] and [actual] are equal `==`.
  /// This is different than the typical check for identity equality `identical`
  /// used by the standard list implementation.  It should also produce nicer
  /// error messages than just calling `Expect.equals(expected, actual)`.
  static void listEquals(List expected, List actual, [String reason]) {
    String msg = _getMessage(reason);
    int n = (expected.length < actual.length) ? expected.length : actual.length;
    for (int i = 0; i < n; i++) {
      if (expected[i] != actual[i]) {
        t.fail('Expect.listEquals(at index $i, '
            'expected: <${expected[i]}>, actual: <${actual[i]}>$msg) fails');
      }
    }
    // We check on length at the end in order to provide better error
    // messages when an unexpected item is inserted in a list.
    if (expected.length != actual.length) {
      t.fail('Expect.listEquals(list length, '
          'expected: <${expected.length}>, actual: <${actual.length}>$msg) '
          'fails: Next element <'
          '${expected.length > n ? expected[n] : actual[n]}>');
    }
  }

  /// Checks that all [expected] and [actual] have the same set of keys (using
  /// the semantics of [Map.containsKey] to determine what "same" means. For
  /// each key, checks that the values in both maps are equal using `==`.
  static void mapEquals(Map expected, Map actual, [String reason]) {
    String msg = _getMessage(reason);

    // Make sure all of the values are present in both and match.
    for (final key in expected.keys) {
      if (!actual.containsKey(key)) {
        t.fail('Expect.mapEquals(missing expected key: <$key>$msg) fails');
      }

      Expect.equals(expected[key], actual[key]);
    }

    // Make sure the actual map doesn't have any extra keys.
    for (final key in actual.keys) {
      if (!expected.containsKey(key)) {
        t.fail('Expect.mapEquals(unexpected key: <$key>$msg) fails');
      }
    }
  }

  /// Specialized equality test for strings. When the strings don't match,
  /// this method shows where the mismatch starts and ends.
  static void stringEquals(String expected, String actual, [String reason]) {
    if (expected == actual) return;

    String msg = _getMessage(reason);
    String defaultMessage =
        'Expect.stringEquals(expected: <$expected>", <$actual>$msg) fails';

    if ((expected == null) || (actual == null)) {
      t.fail('$defaultMessage');
    }

    // Scan from the left until we find the mismatch.
    int left = 0;
    int right = 0;
    int eLen = expected.length;
    int aLen = actual.length;

    for (;;) {
      if (left == eLen || left == aLen || expected[left] != actual[left]) {
        break;
      }
      left++;
    }

    // Scan from the right until we find the mismatch.
    int eRem = eLen - left; // Remaining length ignoring left match.
    int aRem = aLen - left;
    for (;;) {
      if (right == eRem ||
          right == aRem ||
          expected[eLen - right - 1] != actual[aLen - right - 1]) {
        break;
      }
      right++;
    }

    // First difference is at index `left`, last at `length - right - 1`
    // Make useful difference message.
    // Example:
    // Diff (1209..1209/1246):
    // ...,{"name":"[  ]FallThroug...
    // ...,{"name":"[ IndexError","kind":"class"},{"name":" ]FallThroug...
    // (colors would be great!)

    // Make snippets of up to ten characters before and after differences.

    String leftSnippet = expected.substring(left < 10 ? 0 : left - 10, left);
    int rightSnippetLength = right < 10 ? right : 10;
    String rightSnippet =
        expected.substring(eLen - right, eLen - right + rightSnippetLength);

    // Make snippets of the differences.
    String eSnippet = expected.substring(left, eLen - right);
    String aSnippet = actual.substring(left, aLen - right);

    // If snippets are long, elide the middle.
    if (eSnippet.length > 43) {
      eSnippet = [
        eSnippet.substring(0, 20),
        "...",
        eSnippet.substring(eSnippet.length - 20)
      ].join();
    }
    if (aSnippet.length > 43) {
      aSnippet = [
        aSnippet.substring(0, 20),
        "...",
        aSnippet.substring(aSnippet.length - 20)
      ].join();
    }
    // Add "..." before and after, unless the snippets reach the end.
    String leftLead = "...";
    String rightTail = "...";
    if (left <= 10) leftLead = "";
    if (right <= 10) rightTail = "";

    String diff = '\nDiff ($left..${eLen - right}/${aLen - right}):\n'
        '$leftLead$leftSnippet[ $eSnippet ]$rightSnippet$rightTail\n'
        '$leftLead$leftSnippet[ $aSnippet ]$rightSnippet$rightTail';
    t.fail("$defaultMessage$diff");
  }

  /// Checks that every element of [expected] is also in [actual], and that
  /// every element of [actual] is also in [expected].
  static void setEquals(Iterable expected, Iterable actual, [String reason]) {
    final missingSet = Set.from(expected);
    missingSet.removeAll(actual);
    final extraSet = Set.from(actual);
    extraSet.removeAll(expected);

    if (extraSet.isEmpty && missingSet.isEmpty) return;
    String msg = _getMessage(reason);

    StringBuffer sb = StringBuffer("Expect.setEquals($msg) fails");
    // Report any missing items.
    if (missingSet.isNotEmpty) {
      sb.write('\nExpected collection does not contain: ');
    }

    for (final val in missingSet) {
      sb.write('$val ');
    }

    // Report any extra items.
    if (extraSet.isNotEmpty) {
      sb.write('\nExpected collection should not contain: ');
    }

    for (final val in extraSet) {
      sb.write('$val ');
    }
    t.fail(sb.toString());
  }

  /// Checks that [expected] is equivalent to [actual].
  ///
  /// If the objects are iterables or maps, recurses into them.
  static void deepEquals(Object expected, Object actual) {
    // Early exit check for equality.
    if (expected == actual) return;

    if (expected is String && actual is String) {
      stringEquals(expected, actual);
    } else if (expected is Iterable && actual is Iterable) {
      var expectedLength = expected.length;
      var actualLength = actual.length;

      var length =
          expectedLength < actualLength ? expectedLength : actualLength;
      for (var i = 0; i < length; i++) {
        deepEquals(expected.elementAt(i), actual.elementAt(i));
      }

      // We check on length at the end in order to provide better error
      // messages when an unexpected item is inserted in a list.
      if (expectedLength != actualLength) {
        var nextElement =
            (expectedLength > length ? expected : actual).elementAt(length);
        t.fail('Expect.deepEquals(list length, '
            'expected: <$expectedLength>, actual: <$actualLength>) '
            'fails: Next element <$nextElement>');
      }
    } else if (expected is Map && actual is Map) {
      // Make sure all of the values are present in both and match.
      for (final key in expected.keys) {
        if (!actual.containsKey(key)) {
          t.fail('Expect.deepEquals(missing expected key: <$key>) fails');
        }

        Expect.deepEquals(expected[key], actual[key]);
      }

      // Make sure the actual map doesn't have any extra keys.
      for (final key in actual.keys) {
        if (!expected.containsKey(key)) {
          t.fail('Expect.deepEquals(unexpected key: <$key>) fails');
        }
      }
    } else {
      t.fail("Expect.deepEquals(expected: <$expected>, actual: <$actual>) "
          "fails.");
    }
  }

  /// Calls the function [f] and verifies that it throws an exception.
  /// The optional [check] function can provide additional validation
  /// that the correct exception is being thrown.  For example, to check
  /// the type of the exception you could write this:
  ///
  ///     Expect.throws(myThrowingFunction, (e) => e is MyException);
  static void throws(void Function() f,
      [_CheckExceptionFn check, String reason]) {
    String msg = reason == null ? "" : "($reason)";
    if (f is! _Nullary) {
      // Only throws from executing the function body should count as throwing.
      // The failure to even call `f` should throw outside the try/catch.
      t.fail("Expect.throws$msg: Function f not callable with zero arguments");
    }
    try {
      f();
    } catch (e, s) {
      if (check != null) {
        if (!check(e)) {
          t.fail("Expect.throws$msg: Unexpected '$e'\n$s");
        }
      }
      return;
    }
    t.fail('Expect.throws$msg fails: Did not throw');
  }

  static void throwsArgumentError(void Function() f, [String reason]) {
    Expect.throws(
        f, (error) => error is ArgumentError, reason ?? "ArgumentError");
  }

  static void throwsAssertionError(void Function() f, [String reason]) {
    Expect.throws(
        f, (error) => error is AssertionError, reason ?? "AssertionError");
  }

  static void throwsCastError(void Function() f, [String reason]) {
    // ignore: deprecated_member_use
    Expect.throws(f, (error) => error is CastError, reason ?? "CastError");
  }

  static void throwsFormatException(void Function() f, [String reason]) {
    Expect.throws(
        f, (error) => error is FormatException, reason ?? "FormatException");
  }

  static void throwsNoSuchMethodError(void Function() f, [String reason]) {
    Expect.throws(f, (error) => error is NoSuchMethodError,
        reason ?? "NoSuchMethodError");
  }

  static void throwsRangeError(void Function() f, [String reason]) {
    Expect.throws(f, (error) => error is RangeError, reason ?? "RangeError");
  }

  static void throwsStateError(void Function() f, [String reason]) {
    Expect.throws(f, (error) => error is StateError, reason ?? "StateError");
  }

  static void throwsTypeError(void Function() f, [String reason]) {
    Expect.throws(f, (error) => error is TypeError, reason ?? "TypeError");
  }

  static void throwsUnsupportedError(void Function() f, [String reason]) {
    Expect.throws(
        f, (error) => error is UnsupportedError, reason ?? "UnsupportedError");
  }

  /// Reports that there is an error in the test itself and not the code under
  /// test.
  ///
  /// It may be using the expect API incorrectly or failing some other
  /// invariant that the test expects to be true.
  static void testError(String message) {
    t.fail("Test error: $message");
  }

  static String _getMessage(String reason) =>
      (reason == null) ? "" : ", '$reason'";
}

bool _identical(a, b) => identical(a, b);

typedef _CheckExceptionFn = bool Function(dynamic exception);
typedef _Nullary = Function(); // Expect.throws argument must be this type.
