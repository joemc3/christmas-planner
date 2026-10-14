import 'package:equatable/equatable.dart';

/// One year's plan: the master gift budget and the container that
/// recipients and meals hang off (spec section 4).
class PlanModel extends Equatable {
  const PlanModel({
    required this.id,
    required this.userId,
    required this.year,
    required this.giftBudgetTotal,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final int year;
  final double giftBudgetTotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    year: json['year'] as int,
    giftBudgetTotal: (json['gift_budget_total'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'year': year,
    'gift_budget_total': giftBudgetTotal,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  PlanModel copyWith({double? giftBudgetTotal}) => PlanModel(
    id: id,
    userId: userId,
    year: year,
    giftBudgetTotal: giftBudgetTotal ?? this.giftBudgetTotal,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    year,
    giftBudgetTotal,
    createdAt,
    updatedAt,
  ];
}
