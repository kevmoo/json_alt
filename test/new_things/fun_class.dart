import 'package:json_alt/shared_things.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fun_class.g.dart';

part 'fun_class_to_gen.dart';

@JsonSerializable()
class Fun {
  final int a;
  final String b;
  final bool c;
  final Fun child;
  final List<Fun> innerFun;
  final Map<String, Fun> funMap;
  final List<DateTime> dates;

  Object random;

  Fun({
    this.a,
    this.b,
    this.c,
    this.innerFun,
    this.dates,
    this.child,
    this.funMap,
  });

  factory Fun.fromJson(Map<String, dynamic> json) => _$FunFromJson(json);

  Map<String, dynamic> toJson() => _$FunToJson(this);

  static bool writeJson(Object object, JsonWriter writer) =>
      _$FunWriter(object, writer);

  static JsonReader<Fun> createReader() =>
      createCustomJsonReader(_FunListener());
}
