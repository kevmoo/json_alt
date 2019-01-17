// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateStats _$DateStatsFromJson(Map<String, dynamic> json) {
  return DateStats(
      json['count'] as int,
      json['mean'] == null ? null : DateTime.parse(json['mean'] as String),
      json['median'] == null ? null : DateTime.parse(json['median'] as String),
      json['max'] == null ? null : DateTime.parse(json['max'] as String),
      json['min'] == null ? null : DateTime.parse(json['min'] as String),
      json['standardDeviationDays'] as int,
      json['standardErrorDays'] as int);
}

Map<String, dynamic> _$DateStatsToJson(DateStats instance) => <String, dynamic>{
      'count': instance.count,
      'mean': instance.mean?.toIso8601String(),
      'median': instance.median?.toIso8601String(),
      'max': instance.max?.toIso8601String(),
      'min': instance.min?.toIso8601String(),
      'standardDeviationDays': instance.standardDeviationDays,
      'standardErrorDays': instance.standardErrorDays
    };

Stats _$StatsFromJson(Map<String, dynamic> json) {
  return Stats(json['count'] as int, json['mean'] as num, json['median'] as num,
      json['max'] as num, json['min'] as num, json['standardDeviation'] as num);
}

Map<String, dynamic> _$StatsToJson(Stats instance) => <String, dynamic>{
      'count': instance.count,
      'mean': instance.mean,
      'median': instance.median,
      'max': instance.max,
      'min': instance.min,
      'standardDeviation': instance.standardDeviation
    };
