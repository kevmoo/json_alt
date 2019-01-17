// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Example _$ExampleFromJson(Map<String, dynamic> json) {
  return Example(
      a: json['a'] as int,
      b: json['b'] as String,
      c: json['c'] as bool,
      nestedList: (json['nestedList'] as List)
          ?.map((e) =>
              e == null ? null : Example.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      dateList: (json['dateList'] as List)
          ?.map((e) => e == null ? null : DateTime.parse(e as String))
          ?.toList(),
      child: json['child'] == null
          ? null
          : Example.fromJson(json['child'] as Map<String, dynamic>),
      nestedMap: (json['nestedMap'] as Map<String, dynamic>)?.map((k, e) =>
          MapEntry(k,
              e == null ? null : Example.fromJson(e as Map<String, dynamic>))))
    ..random = json['random'];
}

Map<String, dynamic> _$ExampleToJson(Example instance) => <String, dynamic>{
      'a': instance.a,
      'b': instance.b,
      'c': instance.c,
      'child': instance.child,
      'nestedList': instance.nestedList,
      'nestedMap': instance.nestedMap,
      'dateList': instance.dateList?.map((e) => e?.toIso8601String())?.toList(),
      'random': instance.random
    };
