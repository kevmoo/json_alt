// ignore_for_file: slash_for_doc_comments

import '../dart_convert_exports.dart';
import '../listeners/any_value_listener.dart';
import '../listeners/json_reader.dart';
import '../parser/json_string_parser.dart';
import 'json_string_decoder_sink.dart';

/// This class parses JSON strings and builds the corresponding objects.
class MyJsonDecoder extends Converter<String, Object> {
  final JsonReader _reader;

  /// Constructs a new JsonDecoder.
  const MyJsonDecoder({JsonReader reader}) : _reader = reader;

  /// Converts the given JSON-string [input] to its corresponding object.
  ///
  /// Parsed JSON values are of the types [num], [String], [bool], [Null],
  /// [List]s of parsed JSON values or [Map]s from [String] to parsed JSON
  /// values.
  ///
  /// If `this` was initialized with a reviver, then the parsing operation
  /// invokes the reviver on every object or list property that has been parsed.
  /// The arguments are the property name ([String]) or list index ([int]), and
  /// the value is the parsed value. The return value of the reviver is used as
  /// the value of that property instead the parsed value.
  ///
  /// Throws [FormatException] if the input is not valid JSON text.
  @override
  dynamic convert(String input) =>
      parseJsonExperimental(input, _reader ?? anyValueListener());

  /// Starts a conversion from a chunked JSON string to its corresponding object.
  ///
  /// The output [sink] receives exactly one decoded element through `add`.
  @override
  StringConversionSink startChunkedConversion(Sink<Object> sink) {
    return JsonStringDecoderSink(sink, _reader ?? anyValueListener());
  }
}

T parseJsonExperimental<T>(String source, JsonReader<T> listener) {
  var parser = JsonStringParser(listener);
  parser.parse(source, 0, source.length);
  parser.close();
  return listener.result;
}
