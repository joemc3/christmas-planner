import 'package:equatable/equatable.dart';

import '../../../../core/domain/gift_dates.dart';
import '../../../../core/domain/money.dart';
import '../../../../core/domain/statuses.dart';
import '../../../../core/errors/guard.dart';

export '../../../../core/domain/statuses.dart' show GiftStatus;

/// A gift under a recipient (PRD GIFT-2, GIFT-5).
class GiftModel extends Equatable implements GiftLike {
  const GiftModel({
    required this.id,
    required this.recipientId,
    required this.name,
    required this.price,
    required this.status,
    this.storeName,
    this.orderLink,
    this.orderDate,
    this.purchasedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String recipientId;
  final String name;
  @override
  final double price;
  @override
  final GiftStatus status;
  final String? storeName;
  final String? orderLink;
  final DateTime? orderDate;
  final DateTime? purchasedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory GiftModel.fromJson(Map<String, dynamic> json) => GiftModel(
    id: json['id'] as String,
    recipientId: json['recipient_id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    status: GiftStatus.fromString(json['status'] as String),
    storeName: json['store_name'] as String?,
    orderLink: json['order_link'] as String?,
    orderDate: parseDateColumn(json['order_date']),
    purchasedDate: parseDateColumn(json['purchased_date']),
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toInsertJson() => {
    'recipient_id': recipientId,
    'name': name,
    'price': price,
    'status': status.value,
    'store_name': storeName,
    'order_link': orderLink,
    'order_date': dateColumn(orderDate),
    'purchased_date': dateColumn(purchasedDate),
  };

  GiftModel copyWith({
    String? name,
    double? price,
    GiftStatus? status,
    String? storeName,
    String? orderLink,
    DateTime? orderDate,
    DateTime? purchasedDate,
    bool clearOrderDate = false,
    bool clearPurchasedDate = false,
  }) => GiftModel(
    id: id,
    recipientId: recipientId,
    name: name ?? this.name,
    price: price ?? this.price,
    status: status ?? this.status,
    storeName: storeName ?? this.storeName,
    orderLink: orderLink ?? this.orderLink,
    orderDate: clearOrderDate ? null : (orderDate ?? this.orderDate),
    purchasedDate: clearPurchasedDate
        ? null
        : (purchasedDate ?? this.purchasedDate),
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// The gift with [to] applied and its dates stamped or cleared per spec
  /// section 11.
  GiftModel withStatus(GiftStatus to, {required DateTime today}) {
    final dates = datesAfterStatusChange(
      to: to,
      current: (orderDate: orderDate, purchasedDate: purchasedDate),
      today: today,
    );
    return GiftModel(
      id: id,
      recipientId: recipientId,
      name: name,
      price: price,
      status: to,
      storeName: storeName,
      orderLink: orderLink,
      orderDate: dates.orderDate,
      purchasedDate: dates.purchasedDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// A store name, or the link's host when only a link was given.
  String? get storeLabel {
    if (storeName != null && storeName!.trim().isNotEmpty) return storeName;
    final link = orderLink;
    if (link == null || link.isEmpty) return null;
    final host = Uri.tryParse(link)?.host;
    return (host == null || host.isEmpty) ? link : host;
  }

  @override
  List<Object?> get props => [
    id,
    recipientId,
    name,
    price,
    status,
    storeName,
    orderLink,
    orderDate,
    purchasedDate,
    createdAt,
    updatedAt,
  ];
}
