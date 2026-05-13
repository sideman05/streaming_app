class Channel {
  final int id;
  final String name;
  final String logo;
  final String streamUrl;
  final String category;
  final String? description;
  final bool isPremium;
  final String? currentProgram;

  Channel({
    required this.id,
    required this.name,
    required this.logo,
    required this.streamUrl,
    required this.category,
    this.description,
    required this.isPremium,
    this.currentProgram,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json['id'] as int,
    name: json['name'] as String,
    logo: (json['logo_url'] ?? '') as String,
    streamUrl: (json['stream_url'] ?? '') as String,
    category:
        (json['category_name'] ?? json['category'] ?? 'General') as String,
    description: json['description'] as String?,
    isPremium:
        (json['is_premium'] ?? 0) == 1 || (json['is_premium'] ?? false) == true,
    currentProgram: json['current_program'] as String?,
  );
}
