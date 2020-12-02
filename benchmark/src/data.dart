import '../../example/example.dart';

export '../../example/example.dart';

List _getValues() => [
      null,
      true,
      false,
      0,
      1,
      3.14,
      'pi',
      {'a': 'b'},
      [1, null, true, false, 'pi']
    ];

Example getExampleClass(int depth, int width) {
  if (depth <= 0) {
    return null;
  }

  return Example(
    a: 5,
    b: 'foo',
    c: true,
    dateList: List<DateTime>.generate(0, (e) => DateTime(e)),
    child: getExampleClass(depth - 1, width),
    nestedList: List<Example>.generate(
      width,
      (i) => getExampleClass(depth - 1, width),
    ),
    nestedMap: {
      for (var i = 0; i < width; i++) '$i': getExampleClass(depth - 1, width),
    },
  )..random = _getValues();
}
