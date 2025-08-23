import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 4)
class OrderModel extends HiveObject {
  @HiveField(0)
  String orderId;

  @HiveField(1)
  String orderNumber;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  String customerPhone;

  @HiveField(4)
  String deliveryAddress;

  @HiveField(5)
  Map<String, double>? addressCoordinates;

  @HiveField(6)
  List<OrderItem> orderItems;

  @HiveField(7)
  double totalAmount;

  @HiveField(8)
  PaymentMethod paymentMethod;

  @HiveField(9)
  PaymentStatus paymentStatus;

  @HiveField(10)
  String pickupLocationCode;

  @HiveField(11)
  String? assignedTo;

  @HiveField(12)
  OrderStatus status;

  @HiveField(13)
  List<StatusChange> timeline;

  @HiveField(14)
  String? deliveryOtp;

  @HiveField(15)
  String? deliveryProofUrl;

  @HiveField(16)
  String? specialInstructions;

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  DateTime? deliveredAt;

  @HiveField(19)
  DateTime? slaTime;

  OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.addressCoordinates,
    required this.orderItems,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    required this.pickupLocationCode,
    this.assignedTo,
    this.status = OrderStatus.newOrder,
    this.timeline = const [],
    this.deliveryOtp,
    this.deliveryProofUrl,
    this.specialInstructions,
    required this.createdAt,
    this.deliveredAt,
    this.slaTime,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'],
      orderNumber: json['order_number'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      deliveryAddress: json['delivery_address'],
      addressCoordinates: json['address_coordinates'] != null
          ? Map<String, double>.from(json['address_coordinates'])
          : null,
      orderItems: (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['total_amount'].toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      pickupLocationCode: json['pickup_location_code'],
      assignedTo: json['assigned_to'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.newOrder,
      ),
      timeline: (json['timeline'] as List?)
              ?.map((item) => StatusChange.fromJson(item))
              .toList() ??
          [],
      deliveryOtp: json['delivery_otp'],
      deliveryProofUrl: json['delivery_proof_url'],
      specialInstructions: json['special_instructions'],
      createdAt: DateTime.parse(json['created_at']),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      slaTime: json['sla_time'] != null
          ? DateTime.parse(json['sla_time'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': deliveryAddress,
      'address_coordinates': addressCoordinates,
      'order_items': orderItems.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'payment_method': paymentMethod.name,
      'payment_status': paymentStatus.name,
      'pickup_location_code': pickupLocationCode,
      'assigned_to': assignedTo,
      'status': status.name,
      'timeline': timeline.map((item) => item.toJson()).toList(),
      'delivery_otp': deliveryOtp,
      'delivery_proof_url': deliveryProofUrl,
      'special_instructions': specialInstructions,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'sla_time': slaTime?.toIso8601String(),
    };
  }
}

@HiveType(typeId: 5)
class OrderItem extends HiveObject {
  @HiveField(0)
  String itemId;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      itemId: json['item_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
    };
  }
}

@HiveType(typeId: 6)
class StatusChange extends HiveObject {
  @HiveField(0)
  OrderStatus status;

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String? notes;

  StatusChange({
    required this.status,
    required this.timestamp,
    this.notes,
  });

  factory StatusChange.fromJson(Map<String, dynamic> json) {
    return StatusChange(
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}

@HiveType(typeId: 7)
enum OrderStatus {
  @HiveField(0)
  newOrder,
  @HiveField(1)
  assigned,
  @HiveField(2)
  accepted,
  @HiveField(3)
  pickupPending,
  @HiveField(4)
  pickedUp,
  @HiveField(5)
  inTransit,
  @HiveField(6)
  delivered,
  @HiveField(7)
  completed,
}

@HiveType(typeId: 8)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  online,
}

@HiveType(typeId: 9)
enum PaymentStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  cashCollected,
  @HiveField(2)
  onlinePaid,
}
