import '../dart_convert_exports.dart';
import '../listeners/any_value_listener.dart';
import '../listeners/json_reader.dart';
import '../parser/json_utf8_parser.dart';
import 'json_utf8_decoder_sink.dart';

// TODO(kevmoo): test!
class MyJsonUtf8Decoder<T> extends Converter<List<int>, T> {
  final bool _allowMalformed;
  final JsonReader<T> _reader;

  const MyJsonUtf8Decoder({bool allowMalformed, JsonReader<T> reader})
      : _allowMalformed = allowMalformed ?? false,
        _reader = reader;

  @override
  T convert(List<int> input) {
    var parser =
        JsonUtf8Parser<T>(_reader ?? anyValueListener(), _allowMalformed);
    parser.parse(input, 0, input.length);
    return parser.close();
  }

  @override
  ByteConversionSink startChunkedConversion(Sink<Object> sink) {
    return JsonUtf8DecoderSink(
        sink, _allowMalformed, _reader ?? anyValueListener());
  }
}
