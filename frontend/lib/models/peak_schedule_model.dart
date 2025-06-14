class PeakSchedule {
  final String id;
  final String provider;
  final int? dayOfWeek;
  final DateTime? specificDate;
  final String startTime;
  final String endTime;
  final bool isPeak;

  PeakSchedule({
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
      id: json['id'],
      provider: json['provider'],
      dayOfWeek: json['dayOfWeek'],
      specificDate: json['specificDate'] != null
          ? DateTime.parse(json['specificDate']).toLocal()
          : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      isPeak: json['isPeak'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'dayOfWeek': dayOfWeek,
      'specificDate': specificDate?.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isPeak': isPeak,
    };
  }

  @override
  String toString() {
    return 'PeakSchedule{id: $id, provider: $provider, dayOfWeek: $dayOfWeek, specificDate: $specificDate, startTime: $startTime, endTime: $endTime, isPeak: $isPeak}';
  }
}
