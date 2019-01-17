part of 'fun_class.dart';

// crazy goes here!
bool _$FunWriter(Object object, JsonWriter writer) {
  if (object is Fun) {
    writer.startMap();
    writer.writeKeyValue('a', object.a);
    writer.writeKeyValue('b', object.b);
    writer.writeKeyValue('c', object.c);
    writer.writeKeyValue('child', object.child);
    writer.writeKeyValue('innerFun', object.innerFun);
    writer.writeKeyValue('funMap', object.funMap);
    writer.writeKeyValue('dates', object.dates);
    writer.writeKeyValue('random', object.random);
    writer.endMap();
    return true;
  }
  return false;
}


class _FunListener extends CustomObjectListenerBase<Fun> {
  int _a;
  String _b;
  bool _c;
  Fun _child;
  List<Fun> _innerFun;
  List<DateTime> _dates;
  Map<String, Fun> _funMap;

  @override
  void handleNumber(num value) {
    switch (key) {
      case 'a':
        _a = value as int;
        return;
    }
    super.handleNumber(value);
  }

  @override
  void handleString(String value) {
    switch (key) {
      case 'b':
        _b = value;
        return;
    }
    super.handleString(value);
  }

  @override
  void handleBool(bool value) {
    switch (key) {
      case 'c':
        _c = value;
        return;
    }
    super.handleBool(value);
  }

  @override
  void propertyValue() {
    switch (key) {
      case 'child':
        _child = storage as Fun;
        break;
      case 'innerFun':
        _innerFun = storage as List<Fun>;
        break;
      case 'dates':
        _dates = storage as List<DateTime>;
        break;
      case 'funMap':
        _funMap = storage as Map<String, Fun>;
        break;
      case 'a':
      case 'b':
      case 'c':
        // handled closer to the supported type to avoid casting here
        break;
      default:
      // throw? We have properties that are not supported
    }
    super.propertyValue();
  }

  @override
  JsonObjectListener objectStart() {
    switch (key) {
      case 'child':
        return _FunListener();
      case 'funMap':
        return convertObject<String, Fun>(
          (k) => k,
          customListener: () => _FunListener(),
          //valueConvert: (e) => Fun.fromJson(e as Map<String, dynamic>),
        );
    }
    return super.objectStart();
  }

  @override
  JsonArrayListener arrayStart() {
    switch (key) {
      case 'dates':
        return convertArray<String, DateTime>(convert: DateTime.parse);
      case 'innerFun':
        return convertArray<Map<String, dynamic>, Fun>(
          //convert: (e) => Fun.fromJson(e),
          customListener: () => _FunListener()
        );
    }
    return super.arrayStart();
  }

  @override
  Fun create() => Fun(
      a: _a,
      b: _b,
      c: _c,
      innerFun: _innerFun,
      child: _child,
      dates: _dates,
      funMap: _funMap);
}
