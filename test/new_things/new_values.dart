import '../../example/fun_class.dart';

final _empty = Fun(),
    _oneField = Fun(a: 41),
    _simple = Fun(a: 42, b: 'hello', c: true);
final _withDates = Fun(dates: [DateTime(1979), null]);

final _complexJson = const [
  {
    'list': [
      {'map': {}}
    ],
    'map': {
      'another map': {
        'list': [{}]
      }
    }
  },
  {
    'list': [
      [{}]
    ],
    'map': {
      'another map': {
        'list': [{}]
      }
    }
  },
];

final newTestItems = {
  'empty': _empty,
  'one field': _oneField,
  'simple': _simple,
  'with child': Fun(child: _empty),
  'nested': Fun(a: 3, innerFun: [_empty, _oneField, _simple]),
  'nested map': Fun(a: 3, funMap: {
    'null': null,
    'empty': _empty,
    'one field': _oneField,
    'simple': _simple,
    'with dates': _withDates,
  }),
  'json values': _complexJson,
  'with dates': _withDates,
};
