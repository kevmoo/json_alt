// ignore_for_file: slash_for_doc_comments

import '../dart_convert_exports.dart';
import '../listeners/json_reader.dart';
import '../parser/json_utf8_parser.dart';

/// Implements the chunked conversion from a UTF-8 encoding of JSON
/// to its corresponding object.
class JsonUtf8DecoderSink extends ByteConversionSinkBase {
  final JsonUtf8Parser _parser;
  final Sink<Object> _sink;

  JsonUtf8DecoderSink(
      this._sink, bool allowMalformed, JsonReader<Object> jsonReader)
      : _parser = JsonUtf8Parser(jsonReader, allowMalformed);

  @override
  void addSlice(List<int> chunk, int start, int end, bool isLast) {
    _addChunk(chunk, start, end);
    if (isLast) close();
  }

  @override
  void add(List<int> chunk) {
    _addChunk(chunk, 0, chunk.length);
  }

  void _addChunk(List<int> chunk, int start, int end) {
    _parser.parse(chunk, start, end);
  }

  @override
  void close() {
    var decoded = _parser.close();
    _sink.add(decoded);
    _sink.close();
  }
}
