import 'package:equatable/equatable.dart';

class CalendarEventModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime? eventTime;
  final DateTime? endDate;
  final DateTime? endTime;
  final String? location;
  final String? eventType;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final String color;
  final bool allDay;
  final bool recurring;
  final String? recurringPattern;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CalendarEventModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.eventDate,
    this.eventTime,
    this.endDate,
    this.endTime,
    this.location,
    this.eventType,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 1,
    this.color = '#FF0000',
    this.allDay = false,
    this.recurring = false,
    this.recurringPattern,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventTime: json['event_time'] != null
          ? DateTime.tryParse('1970-01-01 ${json['event_time']}')
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.tryParse('1970-01-01 ${json['end_time']}')
          : null,
      location: json['location'] as String?,
      eventType: json['event_type'] as String?,
      reminderEnabled: json['reminder_enabled'] as bool? ?? true,
      reminderDaysBefore: json['reminder_days_before'] as int? ?? 1,
      color: json['color'] as String? ?? '#FF0000',
      allDay: json['all_day'] as bool? ?? false,
      recurring: json['recurring'] as bool? ?? false,
      recurringPattern: json['recurring_pattern'] as String?,
      notes: json['notes'] as String?,
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
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_time': eventTime != null
          ? '${eventTime!.hour.toString().padLeft(2, '0')}:${eventTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'end_date': endDate?.toIso8601String().split('T')[0],
      'end_time': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'location': location,
      'event_type': eventType,
      'reminder_enabled': reminderEnabled,
      'reminder_days_before': reminderDaysBefore,
      'color': color,
      'all_day': allDay,
      'recurring': recurring,
      'recurring_pattern': recurringPattern,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_time': eventTime != null
          ? '${eventTime!.hour.toString().padLeft(2, '0')}:${eventTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'end_date': endDate?.toIso8601String().split('T')[0],
      'end_time': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'location': location,
      'event_type': eventType,
      'reminder_enabled': reminderEnabled,
      'reminder_days_before': reminderDaysBefore,
      'color': color,
      'all_day': allDay,
      'recurring': recurring,
      'recurring_pattern': recurringPattern,
      'notes': notes,
    };
  }

  CalendarEventModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? eventTime,
    DateTime? endDate,
    DateTime? endTime,
    String? location,
    String? eventType,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    String? color,
    bool? allDay,
    bool? recurring,
    String? recurringPattern,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      eventType: eventType ?? this.eventType,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      color: color ?? this.color,
      allDay: allDay ?? this.allDay,
      recurring: recurring ?? this.recurring,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        eventDate,
        eventTime,
        endDate,
        endTime,
        location,
        eventType,
        reminderEnabled,
        reminderDaysBefore,
        color,
        allDay,
        recurring,
        recurringPattern,
        notes,
        createdAt,
        updatedAt,
      ];
}
