import 'package:equatable/equatable.dart';

class ShoppingListModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingListModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingListModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'is_default': isDefault,
    };
  }

  ShoppingListModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingListModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        isDefault,
        createdAt,
        updatedAt,
      ];
}

class ShoppingListItemModel extends Equatable {
  final String id;
  final String shoppingListId;
  final String itemName;
  final String? quantity;
  final String? category;
  final double? estimatedCost;
  final double? actualCost;
  final bool purchased;
  final DateTime? purchasedDate;
  final String? storeName;
  final String? notes;
  final String? giftId;
  final String? mealItemId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ShoppingListItemModel({
    required this.id,
    required this.shoppingListId,
    required this.itemName,
    this.quantity,
    this.category,
    this.estimatedCost,
    this.actualCost,
    this.purchased = false,
    this.purchasedDate,
    this.storeName,
    this.notes,
    this.giftId,
    this.mealItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShoppingListItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingListItemModel(
      id: json['id'] as String,
      shoppingListId: json['shopping_list_id'] as String,
      itemName: json['item_name'] as String,
      quantity: json['quantity'] as String?,
      category: json['category'] as String?,
      estimatedCost: json['estimated_cost'] != null
          ? (json['estimated_cost'] as num).toDouble()
          : null,
      actualCost: json['actual_cost'] != null
          ? (json['actual_cost'] as num).toDouble()
          : null,
      purchased: json['purchased'] as bool? ?? false,
      purchasedDate: json['purchased_date'] != null
          ? DateTime.parse(json['purchased_date'] as String)
          : null,
      storeName: json['store_name'] as String?,
      notes: json['notes'] as String?,
      giftId: json['gift_id'] as String?,
      mealItemId: json['meal_item_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopping_list_id': shoppingListId,
      'item_name': itemName,
      'quantity': quantity,
      'category': category,
      'estimated_cost': estimatedCost,
      'actual_cost': actualCost,
      'purchased': purchased,
      'purchased_date': purchasedDate?.toIso8601String(),
      'store_name': storeName,
      'notes': notes,
      'gift_id': giftId,
      'meal_item_id': mealItemId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'shopping_list_id': shoppingListId,
      'item_name': itemName,
      'quantity': quantity,
      'category': category,
      'estimated_cost': estimatedCost,
      'actual_cost': actualCost,
      'purchased': purchased,
      'purchased_date': purchasedDate?.toIso8601String(),
      'store_name': storeName,
      'notes': notes,
      'gift_id': giftId,
      'meal_item_id': mealItemId,
    };
  }

  ShoppingListItemModel copyWith({
    String? id,
    String? shoppingListId,
    String? itemName,
    String? quantity,
    String? category,
    double? estimatedCost,
    double? actualCost,
    bool? purchased,
    DateTime? purchasedDate,
    String? storeName,
    String? notes,
    String? giftId,
    String? mealItemId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShoppingListItemModel(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      purchased: purchased ?? this.purchased,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      storeName: storeName ?? this.storeName,
      notes: notes ?? this.notes,
      giftId: giftId ?? this.giftId,
      mealItemId: mealItemId ?? this.mealItemId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get effectiveCost => actualCost ?? estimatedCost ?? 0.0;

  @override
  List<Object?> get props => [
        id,
        shoppingListId,
        itemName,
        quantity,
        category,
        estimatedCost,
        actualCost,
        purchased,
        purchasedDate,
        storeName,
        notes,
        giftId,
        mealItemId,
        createdAt,
        updatedAt,
      ];
}
