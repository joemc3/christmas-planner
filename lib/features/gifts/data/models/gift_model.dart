import 'package:equatable/equatable.dart';

enum GiftStatus {
  toBuy('To Buy'),
  ordered('Ordered'),
  purchased('Purchased'),
  wrapped('Wrapped'),
  delivered('Delivered');

  const GiftStatus(this.value);
  final String value;

  static GiftStatus fromString(String value) {
    return GiftStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GiftStatus.toBuy,
    );
  }
}

class GiftModel extends Equatable {
  final String id;
  final String recipientId;
  final String name;
  final String? description;
  final double price;
  final double? actualPrice;
  final GiftStatus status;
  final String? orderLink;
  final String? storeName;
  final String? trackingNumber;
  final DateTime? orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final DateTime? wrappedDate;
  final String? category;
  final String? imageUrl;
  final int priority;
  final String? notes;
  final bool isSurprise;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GiftModel({
    required this.id,
    required this.recipientId,
    required this.name,
    this.description,
    required this.price,
    this.actualPrice,
    required this.status,
    this.orderLink,
    this.storeName,
    this.trackingNumber,
    this.orderDate,
    this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.wrappedDate,
    this.category,
    this.imageUrl,
    this.priority = 0,
    this.notes,
    this.isSurprise = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      actualPrice: json['actual_price'] != null ? (json['actual_price'] as num).toDouble() : null,
      status: GiftStatus.fromString(json['status'] as String),
      orderLink: json['order_link'] as String?,
      storeName: json['store_name'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      orderDate: json['order_date'] != null ? DateTime.parse(json['order_date'] as String) : null,
      expectedDeliveryDate: json['expected_delivery_date'] != null ? DateTime.parse(json['expected_delivery_date'] as String) : null,
      actualDeliveryDate: json['actual_delivery_date'] != null ? DateTime.parse(json['actual_delivery_date'] as String) : null,
      wrappedDate: json['wrapped_date'] != null ? DateTime.parse(json['wrapped_date'] as String) : null,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      priority: json['priority'] as int? ?? 0,
      notes: json['notes'] as String?,
      isSurprise: json['is_surprise'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'name': name,
      'description': description,
      'price': price,
      'actual_price': actualPrice,
      'status': status.value,
      'order_link': orderLink,
      'store_name': storeName,
      'tracking_number': trackingNumber,
      'order_date': orderDate?.toIso8601String(),
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'wrapped_date': wrappedDate?.toIso8601String(),
      'category': category,
      'image_url': imageUrl,
      'priority': priority,
      'notes': notes,
      'is_surprise': isSurprise,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'recipient_id': recipientId,
      'name': name,
      'description': description,
      'price': price,
      'actual_price': actualPrice,
      'status': status.value,
      'order_link': orderLink,
      'store_name': storeName,
      'tracking_number': trackingNumber,
      'order_date': orderDate?.toIso8601String(),
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
      'actual_delivery_date': actualDeliveryDate?.toIso8601String(),
      'wrapped_date': wrappedDate?.toIso8601String(),
      'category': category,
      'image_url': imageUrl,
      'priority': priority,
      'notes': notes,
      'is_surprise': isSurprise,
    };
  }

  GiftModel copyWith({
    String? id,
    String? recipientId,
    String? name,
    String? description,
    double? price,
    double? actualPrice,
    GiftStatus? status,
    String? orderLink,
    String? storeName,
    String? trackingNumber,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    DateTime? wrappedDate,
    String? category,
    String? imageUrl,
    int? priority,
    String? notes,
    bool? isSurprise,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GiftModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      actualPrice: actualPrice ?? this.actualPrice,
      status: status ?? this.status,
      orderLink: orderLink ?? this.orderLink,
      storeName: storeName ?? this.storeName,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      wrappedDate: wrappedDate ?? this.wrappedDate,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      isSurprise: isSurprise ?? this.isSurprise,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get effectivePrice => actualPrice ?? price;

  @override
  List<Object?> get props => [
        id,
        recipientId,
        name,
        description,
        price,
        actualPrice,
        status,
        orderLink,
        storeName,
        trackingNumber,
        orderDate,
        expectedDeliveryDate,
        actualDeliveryDate,
        wrappedDate,
        category,
        imageUrl,
        priority,
        notes,
        isSurprise,
        createdAt,
        updatedAt,
      ];
}
