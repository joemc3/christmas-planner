import 'package:equatable/equatable.dart';

enum MealItemStatus {
  toBuy('To Buy'),
  purchased('Purchased'),
  prepared('Prepared');

  const MealItemStatus(this.value);
  final String value;

  static MealItemStatus fromString(String value) {
    return MealItemStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => MealItemStatus.toBuy,
    );
  }
}

class MealItemModel extends Equatable {
  final String id;
  final String mealId;
  final String itemName;
  final String? description;
  final String? quantity;
  final double cost;
  final double? actualCost;
  final MealItemStatus status;
  final String? storeName;
  final String? category;
  final String? recipeLink;
  final int? prepTime;
  final int? cookTime;
  final String? assignedTo;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealItemModel({
    required this.id,
    required this.mealId,
    required this.itemName,
    this.description,
    this.quantity,
    required this.cost,
    this.actualCost,
    required this.status,
    this.storeName,
    this.category,
    this.recipeLink,
    this.prepTime,
    this.cookTime,
    this.assignedTo,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealItemModel.fromJson(Map<String, dynamic> json) {
    return MealItemModel(
      id: json['id'] as String,
      mealId: json['meal_id'] as String,
      itemName: json['item_name'] as String,
      description: json['description'] as String?,
      quantity: json['quantity'] as String?,
      cost: (json['cost'] as num).toDouble(),
      actualCost: json['actual_cost'] != null ? (json['actual_cost'] as num).toDouble() : null,
      status: MealItemStatus.fromString(json['status'] as String),
      storeName: json['store_name'] as String?,
      category: json['category'] as String?,
      recipeLink: json['recipe_link'] as String?,
      prepTime: json['prep_time'] as int?,
      cookTime: json['cook_time'] as int?,
      assignedTo: json['assigned_to'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_id': mealId,
      'item_name': itemName,
      'description': description,
      'quantity': quantity,
      'cost': cost,
      'actual_cost': actualCost,
      'status': status.value,
      'store_name': storeName,
      'category': category,
      'recipe_link': recipeLink,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'assigned_to': assignedTo,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'meal_id': mealId,
      'item_name': itemName,
      'description': description,
      'quantity': quantity,
      'cost': cost,
      'actual_cost': actualCost,
      'status': status.value,
      'store_name': storeName,
      'category': category,
      'recipe_link': recipeLink,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'assigned_to': assignedTo,
      'notes': notes,
    };
  }

  MealItemModel copyWith({
    String? id,
    String? mealId,
    String? itemName,
    String? description,
    String? quantity,
    double? cost,
    double? actualCost,
    MealItemStatus? status,
    String? storeName,
    String? category,
    String? recipeLink,
    int? prepTime,
    int? cookTime,
    String? assignedTo,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealItemModel(
      id: id ?? this.id,
      mealId: mealId ?? this.mealId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      cost: cost ?? this.cost,
      actualCost: actualCost ?? this.actualCost,
      status: status ?? this.status,
      storeName: storeName ?? this.storeName,
      category: category ?? this.category,
      recipeLink: recipeLink ?? this.recipeLink,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      assignedTo: assignedTo ?? this.assignedTo,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get effectiveCost => actualCost ?? cost;

  int get totalTime => (prepTime ?? 0) + (cookTime ?? 0);

  @override
  List<Object?> get props => [
        id,
        mealId,
        itemName,
        description,
        quantity,
        cost,
        actualCost,
        status,
        storeName,
        category,
        recipeLink,
        prepTime,
        cookTime,
        assignedTo,
        notes,
        createdAt,
        updatedAt,
      ];
}
