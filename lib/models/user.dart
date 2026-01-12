class User {
  final String id;
  final String? displayName;
  final String? email;
  final double? height;
  final double? targetWeight;
  final DateTime? createdAt;

  User({
    required this.id,
    this.displayName,
    this.email,
    this.height,
    this.targetWeight,
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'height': height,
        'targetWeight': targetWeight,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        displayName: json['displayName'] as String?,
        email: json['email'] as String?,
        height: (json['height'] as num?)?.toDouble(),
        targetWeight: (json['targetWeight'] as num?)?.toDouble(),
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      );

  User copyWith({
    String? displayName,
    double? height,
    double? targetWeight,
  }) {
    return User(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      createdAt: createdAt,
    );
  }
}


