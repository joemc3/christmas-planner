import 'package:equatable/equatable.dart';

import '../../../../core/domain/statuses.dart';

export '../../../../core/domain/statuses.dart' show MealType;

/// One of the plan's two meals (PRD MEAL-1, MEAL-2).
class MealModel extends Equatable {
  const MealModel({
    required this.id,
    required this.planId,
    required this.type,
    required this.guestCount,
    required this.budgetLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String planId;
  final MealType type;
  final int guestCount;
  final double budgetLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id: json['id'] as String,
    planId: json['plan_id'] as String,
    type: MealType.fromString(json['type'] as String),
    guestCount: json['guest_count'] as int,
    budgetLimit: (json['budget_limit'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  /// Only guests and budget are editable; type and plan are fixed.
  Map<String, dynamic> toUpdateJson() => {
    'guest_count': guestCount,
    'budget_limit': budgetLimit,
  };

  MealModel copyWith({int? guestCount, double? budgetLimit}) => MealModel(
    id: id,
    planId: planId,
    type: type,
    guestCount: guestCount ?? this.guestCount,
    budgetLimit: budgetLimit ?? this.budgetLimit,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  String get name => type.displayName;

  /// Zero means unset (spec section 11).
  bool get hasGuests => guestCount > 0;
  bool get hasBudget => budgetLimit > 0;

  @override
  List<Object?> get props => [
    id,
    planId,
    type,
    guestCount,
    budgetLimit,
    createdAt,
    updatedAt,
  ];
}
