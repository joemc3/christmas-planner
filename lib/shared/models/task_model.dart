import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool completed;
  final DateTime? completedDate;
  final int priority;
  final String? category;
  final String? assignedTo;
  final String? giftId;
  final String? mealId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.completed = false,
    this.completedDate,
    this.priority = 0,
    this.category,
    this.assignedTo,
    this.giftId,
    this.mealId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completed: json['completed'] as bool? ?? false,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      priority: json['priority'] as int? ?? 0,
      category: json['category'] as String?,
      assignedTo: json['assigned_to'] as String?,
      giftId: json['gift_id'] as String?,
      mealId: json['meal_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'completed': completed,
      'completed_date': completedDate?.toIso8601String(),
      'priority': priority,
      'category': category,
      'assigned_to': assignedTo,
      'gift_id': giftId,
      'meal_id': mealId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'completed': completed,
      'completed_date': completedDate?.toIso8601String(),
      'priority': priority,
      'category': category,
      'assigned_to': assignedTo,
      'gift_id': giftId,
      'meal_id': mealId,
    };
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
    DateTime? completedDate,
    int? priority,
    String? category,
    String? assignedTo,
    String? giftId,
    String? mealId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      completedDate: completedDate ?? this.completedDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
      giftId: giftId ?? this.giftId,
      mealId: mealId ?? this.mealId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null || completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        dueDate,
        completed,
        completedDate,
        priority,
        category,
        assignedTo,
        giftId,
        mealId,
        createdAt,
        updatedAt,
      ];
}
