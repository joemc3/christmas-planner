import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String timezone;
  final String currency;
  final int defaultShippingDays;
  final Map<String, dynamic> notificationPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.timezone = 'UTC',
    this.currency = 'USD',
    this.defaultShippingDays = 7,
    this.notificationPreferences = const {
      'email': true,
      'push': true,
      'reminders': true,
    },
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      currency: json['currency'] as String? ?? 'USD',
      defaultShippingDays: json['default_shipping_days'] as int? ?? 7,
      notificationPreferences: json['notification_preferences'] as Map<String, dynamic>? ?? const {
        'email': true,
        'push': true,
        'reminders': true,
      },
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'timezone': timezone,
      'currency': currency,
      'default_shipping_days': defaultShippingDays,
      'notification_preferences': notificationPreferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? timezone,
    String? currency,
    int? defaultShippingDays,
    Map<String, dynamic>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      defaultShippingDays: defaultShippingDays ?? this.defaultShippingDays,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        timezone,
        currency,
        defaultShippingDays,
        notificationPreferences,
        createdAt,
        updatedAt,
      ];
}
