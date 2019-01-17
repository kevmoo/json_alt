// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fun_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Fun _$FunFromJson(Map<String, dynamic> json) {
  return Fun(
      a: json['a'] as int,
      b: json['b'] as String,
      c: json['c'] as bool,
      innerFun: (json['innerFun'] as List)
          ?.map(
              (e) => e == null ? null : Fun.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      dates: (json['dates'] as List)
          ?.map((e) => e == null ? null : DateTime.parse(e as String))
          ?.toList(),
      child: json['child'] == null
          ? null
          : Fun.fromJson(json['child'] as Map<String, dynamic>),
      funMap: (json['funMap'] as Map<String, dynamic>)?.map((k, e) => MapEntry(
          k, e == null ? null : Fun.fromJson(e as Map<String, dynamic>))))
    ..random = json['random'];
}

Map<String, dynamic> _$FunToJson(Fun instance) => <String, dynamic>{
      'a': instance.a,
      'b': instance.b,
      'c': instance.c,
      'child': instance.child,
      'innerFun': instance.innerFun,
      'funMap': instance.funMap,
      'dates': instance.dates?.map((e) => e?.toIso8601String())?.toList(),
      'random': instance.random
    };
