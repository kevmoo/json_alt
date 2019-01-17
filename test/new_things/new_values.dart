import '../../example/example.dart';

final _empty = Example(),
    _oneField = Example(a: 41),
    _simple = Example(a: 42, b: 'hello', c: true);
final _withDates = Example(dateList: [DateTime(1979), null]);

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
  'with child': Example(child: _empty),
  'nested': Example(a: 3, nestedList: [_empty, _oneField, _simple]),
  'nested map': Example(a: 3, nestedMap: {
    'null': null,
    'empty': _empty,
    'one field': _oneField,
    'simple': _simple,
    'with dates': _withDates,
  }),
  'json values': _complexJson,
  'with dates': _withDates,
};
