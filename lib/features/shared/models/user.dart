class User {
  final int id;
  final String name;
  final String email;
  final String? subscriptionStatus;
  final int? planId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.subscriptionStatus,
    this.planId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    subscriptionStatus: json['subscription_status'] as String?,
    planId: json['plan_id'] as int?,
  );
}
