import '../../example/fun_class.dart';

export '../../example/fun_class.dart';

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

Fun getExampleClass(int depth, int width) {
  if (depth <= 0) {
    return null;
  }

  return Fun(
      a: 5,
      b: 'foo',
      c: true,
      dates: List<DateTime>.generate(0, (e) => DateTime(e)),
      child: getExampleClass(depth - 1, width),
      innerFun:
          List<Fun>.generate(width, (i) => getExampleClass(depth - 1, width)))
    ..random = _getValues();
}
