import 'dart:math' as math;

import 'package:json_annotation/json_annotation.dart';

part 'stats.g.dart';

@JsonSerializable()
class DateStats {
  final int count;
  final DateTime mean, median, max, min;
  final int standardDeviationDays, standardErrorDays;

  DateStats(this.count, this.mean, this.median, this.max, this.min,
      this.standardDeviationDays, this.standardErrorDays);

  factory DateStats.fromJson(Map<String, dynamic> json) =>
      _$DateStatsFromJson(json);

  factory DateStats.fromStatsMillis(Stats stats) {
    return DateStats(
        stats.count,
        DateTime.fromMillisecondsSinceEpoch(stats.mean.toInt()),
        DateTime.fromMillisecondsSinceEpoch(stats.median.toInt()),
        DateTime.fromMillisecondsSinceEpoch(stats.max.toInt()),
        DateTime.fromMillisecondsSinceEpoch(stats.min.toInt()),
        Duration(milliseconds: stats.standardDeviation.toInt()).inDays,
        Duration(milliseconds: stats.standardError.toInt()).inDays);
  }

  Map<String, dynamic> toJson() => _$DateStatsToJson(this);
}

@JsonSerializable()
class Stats {
  final int count;
  final num mean;
  final num median;
  final num max;
  final num min;
  final num standardDeviation;
  final num standardError;

  Stats(this.count, this.mean, this.median, this.max, this.min,
      this.standardDeviation)
      : standardError = standardDeviation / math.sqrt(count);

  factory Stats.fromData(Iterable<num> source, {int precision = 4}) {
    assert(source != null);

    var list = source.toList()..sort();

    assert(list.isNotEmpty);

    var count = list.length;

    var max = list.last;
    var min = list.first;

    var sum = list.fold(0, (num sum, next) => sum + next);

    var mean = sum / count;

    // variance
    // The average of the squared difference from the Mean

    num sumOfSquaredDiffFromMean = 0;
    for (var value in list) {
      var squareDiffFromMean = math.pow(value - mean, 2);
      sumOfSquaredDiffFromMean += squareDiffFromMean;
    }

    var variance = sumOfSquaredDiffFromMean / count;

    // standardDeviation: sqrt of the variance
    var standardDeviation = math.sqrt(variance);

    num median;
    // if length is odd, take middle value
    if (count % 2 == 1) {
      var middleIndex = (count / 2 - 0.5).toInt();
      median = list[middleIndex];
    } else {
      var secondMiddle = count ~/ 2;
      var firstMiddle = secondMiddle - 1;
      median = (list[firstMiddle] + list[secondMiddle]) / 2.0;
    }

    num fix(num input) {
      if (precision == null) {
        return input;
      }

      if (input is int) {
        return input;
      }

      return double.parse((input as double).toStringAsPrecision(precision));
    }

    return Stats(count, fix(mean), fix(median), fix(max), fix(min),
        fix(standardDeviation));
  }

  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);

  Map<String, dynamic> toJson() => _$StatsToJson(this);
}
