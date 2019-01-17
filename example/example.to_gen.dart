part of 'example.dart';

// One `write` method can handle all of the types in a given library.
bool _$writeExample(Object object, JsonWriter writer) {
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

class _$ExampleObjectReader extends CustomObjectReader<Example> {
  int _a;
  String _b;
  bool _c;
  Example _child;
  List<Example> _nestedList;
  List<DateTime> _dateList;
  Map<String, Example> _nestedMap;

  @override
  JsonArrayListener arrayStart() {
    switch (key) {
      case 'dateList':
        return convertArray<String, DateTime>(convert: DateTime.parse);
      case 'nestedList':
        return convertArray<Map<String, dynamic>, Example>(
            customListener: () => _$ExampleObjectReader());
    }
    return super.arrayStart();
  }

  @override
  JsonObjectListener objectStart() {
    switch (key) {
      case 'child':
        return _$ExampleObjectReader();
      case 'nestedMap':
        return convertObject<String, Example>(
          (k) => k,
          customListener: () => _$ExampleObjectReader(),
        );
    }
    return super.objectStart();
  }

  @override
  void propertyValue() {
    switch (key) {
      case 'a':
        _a = storage as int;
        break;
      case 'b':
        _b = storage as String;
        break;
      case 'c':
        _c = storage as bool;
        break;
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
      default:
      // throw? We have properties that are not supported
    }
    super.propertyValue();
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
