class EpgProgram {
  final int id;
  final int channelId;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;

  EpgProgram({
    required this.id,
    required this.channelId,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
  });

  factory EpgProgram.fromJson(Map<String, dynamic> json) => EpgProgram(
    id: json['id'] as int,
    channelId: json['channel_id'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    startTime: DateTime.parse(json['start_time'] as String),
    endTime: DateTime.parse(json['end_time'] as String),
  );
}
