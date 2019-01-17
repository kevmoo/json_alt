import 'container_listener.dart';
import 'json_listener.dart';

class ObjectListener<K, V> extends ContainerListener<Map<K, V>>
    implements JsonObjectListener<Map<K, V>> {
  K _key;

  ObjectListener() : super(<K, V>{});

  @override
  void propertyName() {
    _key = storage as K;
    assert(_key != null);
  }

  @override
  void propertyValue() {
    container[_key] = storage as V;
  }

  @override
  void objectEnd() => close();
}

ObjectListener<K, V> convertObject<K, V>(
  K Function(String) keyConvert, {
  bool skipConvertOnNull,
  JsonObjectListener<V> Function() customListener,
  V Function(dynamic) valueConvert,
}) =>
    _ConvertObjectListener<K, V>(
        keyConvert, valueConvert, skipConvertOnNull ?? true, customListener);

// TODO(kevmoo): consider splitting this into two classes: one for the simple
//               converter case and one for the child listener
class _ConvertObjectListener<K, V> extends ObjectListener<K, V> {
  final bool skipConvertOnNull;
  final K Function(String) keyConvert;
  final V Function(dynamic) valueConvert;
  final JsonObjectListener<V> Function() customListenerFactory;

  _ConvertObjectListener(
    this.keyConvert,
    this.valueConvert,
    this.skipConvertOnNull,
    this.customListenerFactory,
  )   : assert(keyConvert != null),
        assert((valueConvert == null) != (customListenerFactory == null)),
        assert(skipConvertOnNull != null);

  @override
  void propertyName() {
    if (storage == null && skipConvertOnNull) {
      _key = null;
    } else {
      _key = keyConvert(storage as String);
      assert(_key != null);
    }
  }

  @override
  void propertyValue() {
    assert(!container.containsKey(_key));
    container[_key] = (storage == null && skipConvertOnNull)
        ? null
        : valueConvert == null ? storage as V : valueConvert(storage);
  }

  @override
  JsonObjectListener objectStart() {
    if (customListenerFactory != null) {
      return customListenerFactory();
    }
    return super.objectStart();
  }
}
