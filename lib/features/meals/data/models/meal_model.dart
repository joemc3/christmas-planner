import 'package:equatable/equatable.dart';

enum MealType {
  xmasEve('Xmas_Eve'),
  xmasDay('Xmas_Day'),
  other('Other');

  const MealType(this.value);
  final String value;

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.other,
    );
  }

  String get displayName {
    switch (this) {
      case MealType.xmasEve:
        return 'Christmas Eve';
      case MealType.xmasDay:
        return 'Christmas Day';
      case MealType.other:
        return 'Other';
    }
  }
}

class MealModel extends Equatable {
  final String id;
  final String userId;
  final MealType type;
  final String name;
  final int guestCount;
  final double budgetLimit;
  final DateTime? mealTime;
  final String? location;
  final String? theme;
  final List<String> dietaryRestrictions;
  final String? notes;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.guestCount,
    required this.budgetLimit,
    this.mealTime,
    this.location,
    this.theme,
    this.dietaryRestrictions = const [],
    this.notes,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: MealType.fromString(json['type'] as String),
      name: json['name'] as String,
      guestCount: json['guest_count'] as int,
      budgetLimit: (json['budget_limit'] as num).toDouble(),
      mealTime: json['meal_time'] != null
          ? DateTime.tryParse('1970-01-01 ${json['meal_time']}')
          : null,
      location: json['location'] as String?,
      theme: json['theme'] as String?,
      dietaryRestrictions: json['dietary_restrictions'] != null
          ? List<String>.from(json['dietary_restrictions'] as List)
          : const [],
      notes: json['notes'] as String?,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'name': name,
      'guest_count': guestCount,
      'budget_limit': budgetLimit,
      'meal_time': mealTime != null
          ? '${mealTime!.hour.toString().padLeft(2, '0')}:${mealTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'location': location,
      'theme': theme,
      'dietary_restrictions': dietaryRestrictions,
      'notes': notes,
      'year': year,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'type': type.value,
      'name': name,
      'guest_count': guestCount,
      'budget_limit': budgetLimit,
      'meal_time': mealTime != null
          ? '${mealTime!.hour.toString().padLeft(2, '0')}:${mealTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'location': location,
      'theme': theme,
      'dietary_restrictions': dietaryRestrictions,
      'notes': notes,
      'year': year,
    };
  }

  MealModel copyWith({
    String? id,
    String? userId,
    MealType? type,
    String? name,
    int? guestCount,
    double? budgetLimit,
    DateTime? mealTime,
    String? location,
    String? theme,
    List<String>? dietaryRestrictions,
    String? notes,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      guestCount: guestCount ?? this.guestCount,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      mealTime: mealTime ?? this.mealTime,
      location: location ?? this.location,
      theme: theme ?? this.theme,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      notes: notes ?? this.notes,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        name,
        guestCount,
        budgetLimit,
        mealTime,
        location,
        theme,
        dietaryRestrictions,
        notes,
        year,
        createdAt,
        updatedAt,
      ];
}
