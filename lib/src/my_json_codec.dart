// ignore_for_file: slash_for_doc_comments

import 'dart_convert_exports.dart';
import 'decoder/my_json_decoder.dart';
import 'encoder/json_encoder.dart';
import 'encoder/to_encodable.dart';

const json = MyJsonCodec();

class MyJsonCodec extends Codec<Object, String> {
  final String indent;
  final ToEncodable _toEncodable;

  const MyJsonCodec({toEncodable(Object object), this.indent})
      : _toEncodable = toEncodable;

  /// Parses the string and returns the resulting Json object.
  @override
  dynamic decode(String source) => decoder.convert(source);

  /// Converts [value] to a JSON string.
  @override
  String encode(Object value) => encoder.convert(value);

  @override
  JsonEncoder get encoder {
    if (_toEncodable == null && indent == null) return const JsonEncoder();
    return JsonEncoder(toEncodable: _toEncodable, indent: indent);
  }

  @override
  MyJsonDecoder get decoder => const MyJsonDecoder();
}
