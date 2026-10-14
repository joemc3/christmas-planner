import 'package:equatable/equatable.dart';

/// A person you are buying for: a name and a budget (PRD GIFT-1).
class RecipientModel extends Equatable {
  const RecipientModel({
    required this.id,
    required this.planId,
    required this.name,
    required this.budgetLimit,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String planId;
  final String name;
  final double budgetLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RecipientModel.fromJson(Map<String, dynamic> json) => RecipientModel(
    id: json['id'] as String,
    planId: json['plan_id'] as String,
    name: json['name'] as String,
    budgetLimit: (json['budget_limit'] as num).toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'plan_id': planId,
    'name': name,
    'budget_limit': budgetLimit,
  };

  RecipientModel copyWith({String? name, double? budgetLimit}) =>
      RecipientModel(
        id: id,
        planId: planId,
        name: name ?? this.name,
        budgetLimit: budgetLimit ?? this.budgetLimit,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// The monogram shown on rows.
  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  @override
  List<Object?> get props => [
    id,
    planId,
    name,
    budgetLimit,
    createdAt,
    updatedAt,
  ];
}
