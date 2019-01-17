// ignore_for_file: slash_for_doc_comments

import '../listeners/json_reader.dart';
import 'chunked_json_parser.dart';

/// Chunked JSON parser that parses [String] chunks.
class JsonStringParser<T> extends ChunkedJsonParser<String, T> {
  JsonStringParser(JsonReader<T> listener) : super(listener);

  @override
  int getChar(int index) => chunk.codeUnitAt(index);

  @override
  String getString(int start, int end, int bits) {
    return chunk.substring(start, end);
  }

  @override
  void beginString() {
    buffer = StringBuffer();
  }

  @override
  void addSliceToString(int start, int end) {
    var buffer = this.buffer as StringBuffer;
    buffer.write(chunk.substring(start, end));
  }

  @override
  void addCharToString(int charCode) {
    var buffer = this.buffer as StringBuffer;
    buffer.writeCharCode(charCode);
  }

  @override
  String endString() {
    var buffer = this.buffer as StringBuffer;
    this.buffer = null;
    return buffer.toString();
  }

  @override
  void copyCharsToList(int start, int end, List target, int offset) {
    var length = end - start;
    for (var i = 0; i < length; i++) {
      target[offset + i] = chunk.codeUnitAt(start + i);
    }
  }

  @override
  double parseDouble(int start, int end) {
    // TODO(kevmoo): not efficient!
    return double.parse(chunk.substring(start, end));
  }
}
