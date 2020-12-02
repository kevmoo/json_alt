// ignore_for_file: slash_for_doc_comments

import 'json_stringifier.dart';
import 'json_writer.dart';
import 'to_encodable.dart';

/// A specialization of [JsonStringifier] that writes its JSON to a string.
class JsonStringStringifier extends JsonStringifier {
  final StringSink _sink;

  JsonStringStringifier(this._sink, ToEncodable _toEncodable, WriteJson writer)
      : super(_toEncodable, writer);

  /// Convert object to a string.
  ///
  /// The [toEncodable] function is used to convert non-encodable objects
  /// to encodable ones.
  ///
  /// If [indent] is not `null`, the resulting JSON will be "pretty-printed"
  /// with newlines and indentation. The `indent` string is added as indentation
  /// for each indentation level. It should only contain valid JSON whitespace
  /// characters (space, tab, carriage return or line feed).
  static String stringify(
      Object object, ToEncodable toEncodable, WriteJson writer, String indent) {
    var output = StringBuffer();
    printOn(object, output, toEncodable, writer, indent);
    return output.toString();
  }

  /// Convert object to a string, and write the result to the [output] sink.
  ///
  /// The result is written piecemally to the sink.
  static void printOn(Object object, StringSink output, ToEncodable toEncodable,
      WriteJson writer, String indent) {
    JsonStringifier stringifier;
    if (indent == null) {
      stringifier = JsonStringStringifier(output, toEncodable, writer);
    } else {
      stringifier =
          _JsonStringStringifierPretty(output, toEncodable, writer, indent);
    }
    stringifier.writeObject(object);
  }

  @override
  String get partialResult => _sink is StringBuffer ? _sink.toString() : null;

  @override
  void writeNumber(num number) {
    _sink.write(number.toString());
  }

  @override
  void writeString(String characters) {
    _sink.write(characters);
  }

  @override
  void writeStringSlice(String characters, int start, int end) {
    _sink.write(characters.substring(start, end));
  }

  @override
  void writeCharCode(int charCode) {
    _sink.writeCharCode(charCode);
  }
}

class _JsonStringStringifierPretty extends JsonStringStringifier
    with JsonPrettyPrintMixin {
  final String _indent;

  _JsonStringStringifierPretty(
      StringSink sink, ToEncodable toEncodable, WriteJson writer, this._indent)
      : super(sink, toEncodable, writer);

  @override
  void writeIndentation(int count) {
    for (var i = 0; i < count; i++) {
      writeString(_indent);
    }
  }
}
