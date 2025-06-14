class Note {
  final String id;
  final String content;
  final String peakPeriod; // "ON_PEAK" or "OFF_PEAK"
  final DateTime date;

  Note({
    required this.id,
    required this.content,
    required this.peakPeriod,
    required this.date,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      content: json['content'],
      peakPeriod: json['peakPeriod'],
      date: DateTime.parse(json['date']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'peakPeriod': peakPeriod,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Note{id: $id, content: $content, peakPeriod: $peakPeriod, date: $date}';
  }
}
