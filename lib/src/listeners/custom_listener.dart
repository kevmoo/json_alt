import 'impl.dart';
import 'json_listener.dart';
import 'json_reader.dart';

JsonReader<T> createCustomJsonReader<T>(CustomObjectReader<T> base) =>
    _CustomObjectListenerRoot(base);

abstract class CustomObjectReader<T> extends BaseListener<T>
    implements JsonObjectListener<T> {
  T _result;

  @override
  T get result => _result;

  String _key;

  String get key => _key;

  @override
  void propertyName() {
    _key = storage as String;
    assert(_key != null);
  }

  @override
  void propertyValue() {
    _key = null;
  }

  @override
  void objectEnd() {
    assert(_result == null);
    _result = create();
  }

  T create();
}

class _CustomObjectListenerRoot<T> extends JsonReaderImpl<T> {
  final CustomObjectReader<T> _rootListener;

  _CustomObjectListenerRoot(this._rootListener)
      : super(_ObjectProxy(_rootListener));

  @override
  T get result => _rootListener.result;
}

class _ObjectProxy<T> extends JsonListener<T>
    implements JsonListenerWithStorage<T> {
  final CustomObjectReader<T> _rootListener;

  _ObjectProxy(this._rootListener);

  @override
  JsonObjectListener objectStart() => _rootListener;

  @override
  T get result => throw UnsupportedError('Should never be called!');

  @override
  void writeValue(Object value) {
    assert(value is T);
  }
}
