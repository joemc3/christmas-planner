import 'package:equatable/equatable.dart';

import '../../core/domain/ordering.dart' as ordering;

/// The account's settings (PRD ACC-3).
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.currency = 'USD',
    this.defaultShippingDays = ordering.defaultShippingDays,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String currency;
  final int defaultShippingDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String?,
    currency: json['currency'] as String? ?? 'USD',
    defaultShippingDays: ordering.clampShippingDays(
      json['default_shipping_days'] as int? ?? ordering.defaultShippingDays,
    ),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toUpdateJson() => {
    'full_name': fullName,
    'currency': currency,
    'default_shipping_days': ordering.clampShippingDays(defaultShippingDays),
  };

  UserProfile copyWith({
    String? fullName,
    String? currency,
    int? defaultShippingDays,
  }) => UserProfile(
    id: id,
    email: email,
    fullName: fullName ?? this.fullName,
    currency: currency ?? this.currency,
    defaultShippingDays: defaultShippingDays ?? this.defaultShippingDays,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    currency,
    defaultShippingDays,
    createdAt,
    updatedAt,
  ];
}
