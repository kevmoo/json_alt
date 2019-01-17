import 'package:meta/meta.dart';

/// Listener for parsing events from `ChunkedJsonParser`.
abstract class JsonListener<T> {
  void handleString(String value) => _notSupported();

  void handleNumber(num value) => _notSupported();

  void handleBool(bool value) => _notSupported();

  void handleNull() => _notSupported();

  JsonObjectListener objectStart() => _notSupported();

  JsonArrayListener arrayStart() => _notSupported();

  T get result;

  @alwaysThrows
  S _notSupported<S>() =>
      throw UnsupportedError('Not supported in this type ($runtimeType)');
}

abstract class JsonObjectListener<T> implements JsonListener<T> {
  void objectEnd();

  void propertyName();

  void propertyValue();
}

abstract class JsonArrayListener<T> implements JsonListener<T> {
  void arrayEnd();

  void arrayElement();
}
