// ignore_for_file: prefer_single_quotes,constant_identifier_names,omit_local_variable_types

import 'package:meta/meta.dart';

import 'errors.dart';
import 'json_writer.dart';
import 'to_encodable.dart';

// TODO(kevmoo): remove seen tracking. Just have a max-depth counter?

Object _defaultToEncodable(dynamic object) => object.toJson();

bool _defaultJsonWriter(Object source, JsonWriter writer) => false;

// ('0' + x) or ('a' + x - 10)
int _hexDigit(int x) => x < 10 ? 48 + x : 87 + x;

/// JSON encoder that traverses an object structure and writes JSON source.
///
/// This is an abstract implementation that doesn't decide on the output
/// format, but writes the JSON through abstract methods like [writeString].
abstract class JsonStringifier implements JsonWriter {
  // TODO: convert in-line characters to use 'package:charcode/charcode.dart'
  // Character code constants.
  static const int backspace = 0x08;
  static const int tab = 0x09;
  static const int newline = 0x0a;
  static const int carriageReturn = 0x0d;
  static const int formFeed = 0x0c;
  static const int quote = 0x22;
  static const int char_0 = 0x30;
  static const int backslash = 0x5c;
  static const int char_b = 0x62;
  static const int char_f = 0x66;
  static const int char_n = 0x6e;
  static const int char_r = 0x72;
  static const int char_t = 0x74;
  static const int char_u = 0x75;

  /// List of objects currently being traversed. Used to detect cycles.
  final List _seen = [];

  /// Function called for each un-encodable object encountered.
  final ToEncodable _toEncodable;

  final WriteJson _jsonWriter;

  int _mapWritingDepth = 0;
  bool _writtenMapValue;

  JsonStringifier(Function(dynamic o) toEncodable, WriteJson jsonWriter)
      : _toEncodable = toEncodable ?? _defaultToEncodable,
        _jsonWriter = jsonWriter ?? _defaultJsonWriter;

  @protected
  String get partialResult;

  /// Append a string to the JSON output.
  void writeString(String characters);

  /// Append part of a string to the JSON output.
  void writeStringSlice(String characters, int start, int end);

  /// Append a single character, given by its code point, to the JSON output.
  void writeCharCode(int charCode);

  /// Write a number to the JSON output.
  void writeNumber(num number);

  /// Write, and suitably escape, a string's content as a JSON string literal.
  void _writeStringContent(String s) {
    int offset = 0;
    final int length = s.length;
    for (int i = 0; i < length; i++) {
      int charCode = s.codeUnitAt(i);
      if (charCode > backslash) continue;
      if (charCode < 32) {
        if (i > offset) writeStringSlice(s, offset, i);
        offset = i + 1;
        writeCharCode(backslash);
        switch (charCode) {
          case backspace:
            writeCharCode(char_b);
            break;
          case tab:
            writeCharCode(char_t);
            break;
          case newline:
            writeCharCode(char_n);
            break;
          case formFeed:
            writeCharCode(char_f);
            break;
          case carriageReturn:
            writeCharCode(char_r);
            break;
          default:
            writeCharCode(char_u);
            writeCharCode(char_0);
            writeCharCode(char_0);
            writeCharCode(_hexDigit((charCode >> 4) & 0xf));
            writeCharCode(_hexDigit(charCode & 0xf));
            break;
        }
      } else if (charCode == quote || charCode == backslash) {
        if (i > offset) writeStringSlice(s, offset, i);
        offset = i + 1;
        writeCharCode(backslash);
        writeCharCode(charCode);
      }
    }
    if (offset == 0) {
      writeString(s);
    } else if (offset < length) {
      writeStringSlice(s, offset, length);
    }
  }

  /// Check if an encountered object is already being traversed.
  ///
  /// Records the object if it isn't already seen. Should have a matching call to
  /// [_removeSeen] when the object is no longer being traversed.
  void _checkCycle(object) {
    for (int i = 0; i < _seen.length; i++) {
      if (identical(object, _seen[i])) {
        throw JsonCyclicError(object);
      }
    }
    _seen.add(object);
  }

  /// Remove [object] from the list of currently traversed objects.
  ///
  /// Should be called in the opposite order of the matching [_checkCycle]
  /// calls.
  void _removeSeen(object) {
    assert(_seen.isNotEmpty);
    assert(identical(_seen.last, object));
    _seen.removeLast();
  }

  /// Write an object.
  ///
  /// If [object] isn't directly encodable, the [_toEncodable] function gets one
  /// chance to return a replacement which is encodable.
  @override
  void writeObject(object) {
    // Tries stringifying object directly. If it's not a simple value, List or
    // Map, call toJson() to get a custom representation and try serializing
    // that.
    if (_writeJsonValue(object)) return;
    _checkCycle(object);
    try {
      var customJson = _toEncodable(object);
      if (!_writeJsonValue(customJson)) {
        throw JsonUnsupportedObjectError(object, partialResult: partialResult);
      }
      _removeSeen(object);
    } catch (e) {
      throw JsonUnsupportedObjectError(object,
          cause: e, partialResult: partialResult);
    }
  }

  /// Serialize a [num], [String], [bool], [Null], [List] or [Map] value.
  ///
  /// Returns true if the value is one of these types, and false if not.
  /// If a value is both a [List] and a [Map], it's serialized as a [List].
  bool _writeJsonValue(Object object) {
    if (object is num) {
      if (!object.isFinite) return false;
      writeNumber(object);
      return true;
    } else if (identical(object, true)) {
      writeString('true');
      return true;
    } else if (identical(object, false)) {
      writeString('false');
      return true;
    } else if (object == null) {
      writeString('null');
      return true;
    } else if (object is String) {
      writeString('"');
      _writeStringContent(object);
      writeString('"');
      return true;
    } else if (object is List) {
      _checkCycle(object);
      _writeList(object);
      _removeSeen(object);
      return true;
    } else if (object is Map) {
      _checkCycle(object);
      // writeMap can fail if keys are not all strings.
      var success = _writeMap(object);
      _removeSeen(object);
      return success;
    } else {
      return _jsonWriter(object, this);
    }
  }

  /// Serialize a [List].
  void _writeList(List list) {
    startList();
    for (var i = 0; i < list.length; i++) {
      writeListValue(list[i]);
    }
    endList();
  }

  @override
  void startList() {
    if (_writtenMapValue != null) {
      _mapWritingDepth++;
    }
    _writtenMapValue = false;
    writeString('[');
  }

  @override
  void writeListValue(Object value) {
    assert(_writtenMapValue != null);
    if (_writtenMapValue) {
      writeString(',');
    } else {
      _writtenMapValue = true;
    }
    writeObject(value);
  }

  @override
  void endList() {
    assert(_writtenMapValue != null);
    writeString(']');
    if (_mapWritingDepth > 0) {
      _mapWritingDepth--;
      _writtenMapValue = true;
    } else {
      _writtenMapValue = null;
    }
  }

  /// Serialize a [Map].
  bool _writeMap(Map map) {
    if (map.isEmpty) {
      startMap();
      endMap();
      return true;
    }
    List keyValueList = List(map.length * 2);
    int i = 0;
    bool allStringKeys = true;
    map.forEach((key, value) {
      if (key is! String) {
        allStringKeys = false;
      }
      keyValueList[i++] = key;
      keyValueList[i++] = value;
    });
    if (!allStringKeys) return false;
    startMap();
    for (int i = 0; i < keyValueList.length; i += 2) {
      writeKeyValue(keyValueList[i] as String, keyValueList[i + 1]);
    }
    endMap();
    return true;
  }

  @override
  void startMap() {
    if (_writtenMapValue != null) {
      _mapWritingDepth++;
    }
    _writtenMapValue = false;
    writeString("{");
  }

  @override
  void writeKeyValue(String key, Object value) {
    assert(_writtenMapValue != null);
    if (_writtenMapValue) {
      writeString(',"');
    } else {
      _writtenMapValue = true;
      writeString('"');
    }
    _writeStringContent(key);
    writeString('":');
    writeObject(value);
  }

  @override
  void endMap() {
    assert(_writtenMapValue != null);
    writeString('}');
    if (_mapWritingDepth > 0) {
      _mapWritingDepth--;
      _writtenMapValue = true;
    } else {
      _writtenMapValue = null;
    }
  }
}

/// A modification of [JsonStringifier] which indents the contents of [List] and
/// [Map] objects using the specified indent value.
///
/// Subclasses should implement [writeIndentation].
mixin JsonPrettyPrintMixin on JsonStringifier {
  int _indentLevel = 0;

  /// Add [indentLevel] indentations to the JSON output.
  void writeIndentation(int indentLevel);

  @override
  void writeListValue(Object value) {
    assert(_writtenMapValue != null);
    if (_writtenMapValue) {
      writeString(',\n');
    } else {
      _indentLevel++;
      writeString('\n');
      _writtenMapValue = true;
    }
    writeIndentation(_indentLevel);
    writeObject(value);
  }

  @override
  void endList() {
    if (_writtenMapValue) {
      _indentLevel--;
      writeString('\n');
      writeIndentation(_indentLevel);
    }
    super.endList();
  }

  @override
  void writeKeyValue(String key, Object value) {
    assert(_writtenMapValue != null);
    if (_writtenMapValue) {
      writeString(',\n');
    } else {
      _indentLevel++;
      writeString('\n');
      _writtenMapValue = true;
    }
    writeIndentation(_indentLevel);
    writeString('"');
    _writeStringContent(key);
    writeString('": ');
    writeObject(value);
  }

  @override
  void endMap() {
    if (_writtenMapValue) {
      _indentLevel--;
      writeString('\n');
      writeIndentation(_indentLevel);
    }
    super.endMap();
  }
}
