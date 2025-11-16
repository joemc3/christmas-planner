import 'package:equatable/equatable.dart';

class RecipientModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? relationship;
  final String? ageGroup;
  final List<String> interests;
  final double budgetLimit;
  final String? notes;
  final String? avatarUrl;
  final int priority;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecipientModel({
    required this.id,
    required this.userId,
    required this.name,
    this.relationship,
    this.ageGroup,
    this.interests = const [],
    required this.budgetLimit,
    this.notes,
    this.avatarUrl,
    this.priority = 0,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String?,
      ageGroup: json['age_group'] as String?,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'] as List)
          : const [],
      budgetLimit: (json['budget_limit'] as num).toDouble(),
      notes: json['notes'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      priority: json['priority'] as int? ?? 0,
      archived: json['archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'relationship': relationship,
      'age_group': ageGroup,
      'interests': interests,
      'budget_limit': budgetLimit,
      'notes': notes,
      'avatar_url': avatarUrl,
      'priority': priority,
      'archived': archived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'relationship': relationship,
      'age_group': ageGroup,
      'interests': interests,
      'budget_limit': budgetLimit,
      'notes': notes,
      'avatar_url': avatarUrl,
      'priority': priority,
      'archived': archived,
    };
  }

  RecipientModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? relationship,
    String? ageGroup,
    List<String>? interests,
    double? budgetLimit,
    String? notes,
    String? avatarUrl,
    int? priority,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecipientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      ageGroup: ageGroup ?? this.ageGroup,
      interests: interests ?? this.interests,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      notes: notes ?? this.notes,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      priority: priority ?? this.priority,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        relationship,
        ageGroup,
        interests,
        budgetLimit,
        notes,
        avatarUrl,
        priority,
        archived,
        createdAt,
        updatedAt,
      ];
}
