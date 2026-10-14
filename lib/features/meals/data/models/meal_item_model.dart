import 'package:equatable/equatable.dart';

import '../../../../core/domain/money.dart';
import '../../../../core/domain/statuses.dart';

export '../../../../core/domain/statuses.dart' show MealItemStatus;

/// A menu item under a meal (PRD MEAL-3).
class MealItemModel extends Equatable implements MealItemLike {
  const MealItemModel({
    required this.id,
    required this.mealId,
    required this.itemName,
    required this.cost,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String mealId;
  final String itemName;
  @override
  final double cost;
  @override
  final MealItemStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MealItemModel.fromJson(Map<String, dynamic> json) => MealItemModel(
    id: json['id'] as String,
    mealId: json['meal_id'] as String,
    itemName: json['item_name'] as String,
    cost: (json['cost'] as num).toDouble(),
    status: MealItemStatus.fromString(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'meal_id': mealId,
    'item_name': itemName,
    'cost': cost,
    'status': status.value,
  };

  MealItemModel copyWith({
    String? itemName,
    double? cost,
    MealItemStatus? status,
  }) => MealItemModel(
    id: id,
    mealId: mealId,
    itemName: itemName ?? this.itemName,
    cost: cost ?? this.cost,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    mealId,
    itemName,
    cost,
    status,
    createdAt,
    updatedAt,
  ];
}
