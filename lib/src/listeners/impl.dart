import 'package:meta/meta.dart';

import 'array_listener.dart';
import 'json_listener.dart';
import 'json_reader.dart';
import 'object_listener.dart';

abstract class JsonListenerWithStorage<T> extends JsonListener<T> {
  void writeValue(Object value);
}

abstract class BaseListener<T> extends JsonListener<T> {
  Object _storage;

  @protected
  Object get storage => _storage;

  @override
  void handleString(String value) {
    _storage = value;
  }

  @override
  void handleNumber(num value) {
    _storage = value;
  }

  @override
  void handleBool(bool value) {
    _storage = value;
  }

  @override
  void handleNull() {
    _storage = null;
  }

  @override
  JsonObjectListener objectStart() => ObjectListener<String, dynamic>();

  @override
  JsonArrayListener arrayStart() => ArrayListener();
}

abstract class JsonReaderImpl<T> implements JsonReader<T> {
  final List<JsonListener> _listeners;

  JsonReaderImpl(JsonListener root) : _listeners = <JsonListener>[root];

  JsonListener get _listener => _listeners.last;

  @override
  void handleString(String value) => _listener.handleString(value);

  @override
  void handleNumber(num value) => _listener.handleNumber(value);

  @override
  void handleBool(bool value) => _listener.handleBool(value);

  @override
  void handleNull() => _listener.handleNull();

  @override
  void objectStart() {
    _listeners.add(_listener.objectStart());
  }

  @override
  void propertyName() => (_listener as JsonObjectListener).propertyName();

  @override
  void propertyValue() => (_listener as JsonObjectListener).propertyValue();

  @override
  void objectEnd() {
    var objListener = _listeners.removeLast() as JsonObjectListener;
    objListener.objectEnd();
    _writeStorage(objListener.result);
  }

  @override
  void arrayStart() {
    _listeners.add(_listener.arrayStart());
  }

  @override
  void arrayElement() => (_listener as JsonArrayListener).arrayElement();

  @override
  void arrayEnd() {
    var arrayListener = _listeners.removeLast() as JsonArrayListener;
    arrayListener.arrayEnd();
    _writeStorage(arrayListener.result);
  }

  void _writeStorage(Object value) {
    var listener = _listener;
    if (listener is JsonListenerWithStorage) {
      listener.writeValue(value);
    } else {
      (listener as BaseListener)._storage = value;
    }
  }
}
