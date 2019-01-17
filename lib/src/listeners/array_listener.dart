import 'container_listener.dart';
import 'json_listener.dart';

class ArrayListener<T> extends ContainerListener<List<T>>
    implements JsonArrayListener<List<T>> {
  ArrayListener() : super(<T>[]);

  @override
  void arrayElement() {
    container.add(storage as T);
  }

  @override
  void arrayEnd() => close();
}

ArrayListener<T> convertArray<S, T>({
  T Function(S) convert,
  bool skipConvertOnNull,
  JsonObjectListener<T> Function() customListener,
}) =>
    _ConvertArrayListener(convert, skipConvertOnNull ?? true, customListener);

class _ConvertArrayListener<S, T> extends ArrayListener<T> {
  final bool skipConvertOnNull;
  final T Function(S) convert;
  final JsonObjectListener<T> Function() customListenerFactory;

  _ConvertArrayListener(
      this.convert, this.skipConvertOnNull, this.customListenerFactory)
      : assert((convert == null) != (customListenerFactory == null));

  @override
  void arrayElement() {
    if (skipConvertOnNull && storage == null) {
      container.add(null);
    } else if (customListenerFactory != null) {
      container.add(storage as T);
    } else {
      container.add(convert(storage as S));
    }
  }

  @override
  JsonObjectListener objectStart() {
    if (customListenerFactory != null) {
      return customListenerFactory();
    }
    return super.objectStart();
  }
}
