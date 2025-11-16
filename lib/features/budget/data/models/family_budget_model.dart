import 'package:equatable/equatable.dart';

class FamilyBudgetModel extends Equatable {
  final String id;
  final String userId;
  final double giftBudgetTotal;
  final double mealBudgetEve;
  final double mealBudgetDay;
  final double decorationsBudget;
  final double activitiesBudget;
  final double miscellaneousBudget;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FamilyBudgetModel({
    required this.id,
    required this.userId,
    required this.giftBudgetTotal,
    required this.mealBudgetEve,
    required this.mealBudgetDay,
    this.decorationsBudget = 0.0,
    this.activitiesBudget = 0.0,
    this.miscellaneousBudget = 0.0,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FamilyBudgetModel.fromJson(Map<String, dynamic> json) {
    return FamilyBudgetModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      giftBudgetTotal: (json['gift_budget_total'] as num).toDouble(),
      mealBudgetEve: (json['meal_budget_eve'] as num).toDouble(),
      mealBudgetDay: (json['meal_budget_day'] as num).toDouble(),
      decorationsBudget: json['decorations_budget'] != null
          ? (json['decorations_budget'] as num).toDouble()
          : 0.0,
      activitiesBudget: json['activities_budget'] != null
          ? (json['activities_budget'] as num).toDouble()
          : 0.0,
      miscellaneousBudget: json['miscellaneous_budget'] != null
          ? (json['miscellaneous_budget'] as num).toDouble()
          : 0.0,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'gift_budget_total': giftBudgetTotal,
      'meal_budget_eve': mealBudgetEve,
      'meal_budget_day': mealBudgetDay,
      'decorations_budget': decorationsBudget,
      'activities_budget': activitiesBudget,
      'miscellaneous_budget': miscellaneousBudget,
      'year': year,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'gift_budget_total': giftBudgetTotal,
      'meal_budget_eve': mealBudgetEve,
      'meal_budget_day': mealBudgetDay,
      'decorations_budget': decorationsBudget,
      'activities_budget': activitiesBudget,
      'miscellaneous_budget': miscellaneousBudget,
      'year': year,
    };
  }

  FamilyBudgetModel copyWith({
    String? id,
    String? userId,
    double? giftBudgetTotal,
    double? mealBudgetEve,
    double? mealBudgetDay,
    double? decorationsBudget,
    double? activitiesBudget,
    double? miscellaneousBudget,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyBudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      giftBudgetTotal: giftBudgetTotal ?? this.giftBudgetTotal,
      mealBudgetEve: mealBudgetEve ?? this.mealBudgetEve,
      mealBudgetDay: mealBudgetDay ?? this.mealBudgetDay,
      decorationsBudget: decorationsBudget ?? this.decorationsBudget,
      activitiesBudget: activitiesBudget ?? this.activitiesBudget,
      miscellaneousBudget: miscellaneousBudget ?? this.miscellaneousBudget,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get totalBudget =>
      giftBudgetTotal +
      mealBudgetEve +
      mealBudgetDay +
      decorationsBudget +
      activitiesBudget +
      miscellaneousBudget;

  double get totalMealBudget => mealBudgetEve + mealBudgetDay;

  @override
  List<Object?> get props => [
        id,
        userId,
        giftBudgetTotal,
        mealBudgetEve,
        mealBudgetDay,
        decorationsBudget,
        activitiesBudget,
        miscellaneousBudget,
        year,
        createdAt,
        updatedAt,
      ];
}
