import '../dart_convert_exports.dart';
import '../listeners/json_reader.dart';
import '../parser/json_string_parser.dart';
import 'json_utf8_decoder_sink.dart';

/// Implements the chunked conversion from a JSON string to its corresponding
/// object.
///
/// The sink only creates one object, but its input can be chunked.
class JsonStringDecoderSink extends StringConversionSinkBase {
  final JsonStringParser _parser;
  final JsonReader _reader;
  final Sink<Object> _sink;

  JsonStringDecoderSink(this._sink, this._reader)
      : _parser = JsonStringParser(_reader);

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    _parser.parse(str, start, end);
    if (isLast) _parser.close();
  }

  @override
  void add(String str) {
    addSlice(str, 0, str.length, false);
  }

  @override
  void close() {
    var decoded = _parser.close();
    _sink.add(decoded);
    _sink.close();
  }

  @override
  ByteConversionSink asUtf8Sink(bool allowMalformed) {
    return JsonUtf8DecoderSink(_sink, allowMalformed, _reader);
  }
}
