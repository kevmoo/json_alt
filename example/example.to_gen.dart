part of 'example.dart';

// crazy goes here!
bool _$FunWriter(Object object, JsonWriter writer) {
  if (object is Example) {
    writer.startMap();
    writer.writeKeyValue('a', object.a);
    writer.writeKeyValue('b', object.b);
    writer.writeKeyValue('c', object.c);
    writer.writeKeyValue('child', object.child);
    writer.writeKeyValue('nestedList', object.nestedList);
    writer.writeKeyValue('nestedMap', object.nestedMap);
    writer.writeKeyValue('dateList', object.dateList);
    writer.writeKeyValue('random', object.random);
    writer.endMap();
    return true;
  }
  return false;
}

class _FunListener extends CustomObjectReader<Example> {
  int _a;
  String _b;
  bool _c;
  Example _child;
  List<Example> _nestedList;
  List<DateTime> _dateList;
  Map<String, Example> _nestedMap;

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
        _child = storage as Example;
        break;
      case 'nestedList':
        _nestedList = storage as List<Example>;
        break;
      case 'dateList':
        _dateList = storage as List<DateTime>;
        break;
      case 'nestedMap':
        _nestedMap = storage as Map<String, Example>;
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
      case 'nestedMap':
        return convertObject<String, Example>(
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
      case 'dateList':
        return convertArray<String, DateTime>(convert: DateTime.parse);
      case 'nestedList':
        return convertArray<Map<String, dynamic>, Example>(
            //convert: (e) => Fun.fromJson(e),
            customListener: () => _FunListener());
    }
    return super.arrayStart();
  }

  @override
  Example create() => Example(
      a: _a,
      b: _b,
      c: _c,
      nestedList: _nestedList,
      child: _child,
      dateList: _dateList,
      nestedMap: _nestedMap);
}
