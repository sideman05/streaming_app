class Plan {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;

  Plan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'] as int,
    name: json['name'] as String,
    description: (json['description'] ?? '') as String,
    price: double.parse(json['price'].toString()),
    durationDays: json['duration_days'] as int,
  );
}
