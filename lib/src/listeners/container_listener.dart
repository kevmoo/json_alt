import 'package:meta/meta.dart';

import 'impl.dart';

abstract class ContainerListener<T> extends BaseListener<T> {
  T _result;

  @protected
  final T container;

  @override
  T get result => _result;

  ContainerListener(this.container);

  @protected
  void close() {
    _result = container;
  }
}
