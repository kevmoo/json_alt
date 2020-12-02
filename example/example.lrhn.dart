part of 'example.dart';

void _exampleSerializer(Object object, lrhn.JsonSink sink) {
  if (object == null) {
    sink.addNull();
  } else if (object is bool) {
    sink.addBool(object);
  } else if (object is num) {
    sink.addNumber(object);
  } else if (object is String) {
    sink.addString(object);
  } else if (object is Map<String, dynamic>) {
    sink.startObject();
    for (var entry in object.entries) {
      sink.addKey(entry.key);
      _exampleSerializer(entry.value, sink);
    }
    sink.endObject();
  } else if (object is Example) {
    sink.startObject();
    sink.addKey('a');
    sink.addNumber(object.a);
    sink.addKey('b');
    sink.addString(object.b);
    sink.addKey('c');
    sink.addBool(object.c);
    sink.addKey('child');
    _exampleSerializer(object.child, sink);
    sink.addKey('nestedList');
    _exampleSerializer(object.nestedList, sink);
    sink.addKey('nestedMap');
    _exampleSerializer(object.nestedMap, sink);
    sink.addKey('dateList');
    _exampleSerializer(object.dateList, sink);
    sink.addKey('random');
    _exampleSerializer(object.random, sink);
    sink.endObject();
  } else if (object is List) {
    sink.startArray();
    for (var element in object) {
      _exampleSerializer(element, sink);
    }
    sink.endArray();
  } else {
    throw UnsupportedError('cannot part on `${object.runtimeType}`');
  }
}

class LrhnConverter extends Converter<Object, List<int>> {
  @override
  List<int> convert(Object input) {
    var byteSync = _ByteSync();

    var stringConversionSync = utf8.encoder.startChunkedConversion(byteSync);

    var closableStringSync = stringConversionSync.asStringSink();

    var sink = lrhn.jsonStringWriter(closableStringSync);

    _exampleSerializer(input, sink);

    return byteSync._data;
  }

  @override
  Sink<Object> startChunkedConversion(Sink<List<int>> sink) {
    var stringConversionSync = utf8.encoder.startChunkedConversion(sink);

    var closableStringSync = stringConversionSync.asStringSink();

    return _ObjectSink(closableStringSync);
  }
}

class _ObjectSink implements Sink<Object> {
  final lrhn.JsonSink _source;
  final ClosableStringSink _sink;

  _ObjectSink(this._sink) : _source = lrhn.jsonStringWriter(_sink);

  @override
  void add(Object data) {
    _exampleSerializer(data, _source);
  }

  @override
  void close() {
    _sink.close();
  }
}

class _ByteSync implements Sink<List<int>> {
  final _data = <int>[];
  bool _closed = false;

  @override
  void add(List<int> data) {
    assert(!_closed);
    _data.addAll(data);
  }

  @override
  void close() {
    _closed = true;
  }
}
