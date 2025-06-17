// lib/models/peak_schedule_model.dart

import 'package:flutter/foundation.dart';

@immutable
class PeakSchedule {
  final String id;
  final String provider;
  final int? dayOfWeek; // 0 = Sun, 1 = Mon, ..., 6 = Sat
  final DateTime? specificDate;
  final String startTime; // "HH:mm"
  final String endTime; // "HH:mm"
  final bool isPeak;

  const PeakSchedule({
    required this.id,
    required this.provider,
    this.dayOfWeek,
    this.specificDate,
    required this.startTime,
    required this.endTime,
    required this.isPeak,
  });

  factory PeakSchedule.fromJson(Map<String, dynamic> json) {
    return PeakSchedule(
      id: json['id'] as String,
      provider: json['provider'] as String,
      dayOfWeek: json['dayOfWeek'] as int?,
      specificDate: json['specificDate'] != null
          ? DateTime.parse(json['specificDate'] as String).toLocal()
          : null,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isPeak: json['isPeak'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'dayOfWeek': dayOfWeek,
      'specificDate': specificDate?.toUtc().toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isPeak': isPeak,
    };
  }
}
