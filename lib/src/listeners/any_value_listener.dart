import 'impl.dart';
import 'json_reader.dart';

JsonReader<T> anyValueListener<T>() => _AnyValueReader(_AnyValueListener());

class _AnyValueReader<T> extends JsonReaderImpl<T> {
  final _AnyValueListener<T> _listener;

  _AnyValueReader(this._listener) : super(_listener);

  @override
  T get result => _listener.result;
}

class _AnyValueListener<T> extends BaseListener<T> {
  @override
  T get result => storage as T;
}
