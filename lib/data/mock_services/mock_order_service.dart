import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';

final mockOrderServiceProvider = Provider<MockOrderService>((ref) {
  return MockOrderService();
});

class MockOrderService {
  static final List<OrderModel> _orders = [
    OrderModel(
      orderId: 'order_001',
      orderNumber: 'RIO001',
      customerName: 'Rajesh Kumar',
      customerPhone: '+91 98765****0',
      deliveryAddress: 'Sector 62, Noida, Uttar Pradesh 201309',
      orderItems: [
        OrderItem(itemId: 'item_001', itemName: 'Paracetamol 500mg', quantity: 2, price: 50.0),
        OrderItem(itemId: 'item_002', itemName: 'Cough Syrup', quantity: 1, price: 120.0),
      ],
      totalAmount: 170.0,
      paymentMethod: PaymentMethod.cash,
      pickupLocationCode: 'A1',
      status: OrderStatus.assigned,
      timeline: [
        StatusChange(status: OrderStatus.newOrder, timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
        StatusChange(status: OrderStatus.assigned, timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      ],
      deliveryOtp: '123456',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      slaTime: DateTime.now().add(const Duration(minutes: 5)),
    ),
    OrderModel(
      orderId: 'order_002',
      orderNumber: 'RIO002',
      customerName: 'Priya Sharma',
      customerPhone: '+91 98765****1',
      deliveryAddress: 'Sector 18, Noida, Uttar Pradesh 201301',
      orderItems: [
        OrderItem(itemId: 'item_003', itemName: 'Vitamin D3', quantity: 1, price: 250.0),
      ],
      totalAmount: 250.0,
      paymentMethod: PaymentMethod.online,
      paymentStatus: PaymentStatus.onlinePaid,
      pickupLocationCode: 'B2',
      status: OrderStatus.accepted,
      timeline: [
        StatusChange(status: OrderStatus.newOrder, timestamp: DateTime.now().subtract(const Duration(minutes: 20))),
        StatusChange(status: OrderStatus.assigned, timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
        StatusChange(status: OrderStatus.accepted, timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
      ],
      deliveryOtp: '789012',
      createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      slaTime: DateTime.now().add(const Duration(minutes: 10)),
    ),
    OrderModel(
      orderId: 'order_003',
      orderNumber: 'RIO003',
      customerName: 'Amit Singh',
      customerPhone: '+91 98765****2',
      deliveryAddress: 'Sector 15, Noida, Uttar Pradesh 201301',
      orderItems: [
        OrderItem(itemId: 'item_004', itemName: 'Blood Pressure Monitor', quantity: 1, price: 1200.0),
        OrderItem(itemId: 'item_005', itemName: 'Digital Thermometer', quantity: 1, price: 300.0),
      ],
      totalAmount: 1500.0,
      paymentMethod: PaymentMethod.cash,
      pickupLocationCode: 'C3',
      status: OrderStatus.completed,
      paymentStatus: PaymentStatus.cashCollected,
      timeline: [
        StatusChange(status: OrderStatus.newOrder, timestamp: DateTime.now().subtract(const Duration(hours: 2))),
        StatusChange(status: OrderStatus.assigned, timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55))),
        StatusChange(status: OrderStatus.accepted, timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50))),
        StatusChange(status: OrderStatus.pickedUp, timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30))),
        StatusChange(status: OrderStatus.inTransit, timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 25))),
        StatusChange(status: OrderStatus.delivered, timestamp: DateTime.now().subtract(const Duration(hours: 1))),
        StatusChange(status: OrderStatus.completed, timestamp: DateTime.now().subtract(const Duration(minutes: 55))),
      ],
      deliveryOtp: '345678',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      deliveredAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    OrderModel(
      orderId: 'order_004',
      orderNumber: 'RIO004',
      customerName: 'Sunita Devi',
      customerPhone: '+91 98765****3',
      deliveryAddress: 'Sector 22, Noida, Uttar Pradesh 201301',
      orderItems: [
        OrderItem(itemId: 'item_006', itemName: 'Insulin Pen', quantity: 2, price: 800.0),
      ],
      totalAmount: 800.0,
      paymentMethod: PaymentMethod.online,
      paymentStatus: PaymentStatus.onlinePaid,
      pickupLocationCode: 'A2',
      status: OrderStatus.pickedUp,
      timeline: [
        StatusChange(status: OrderStatus.newOrder, timestamp: DateTime.now().subtract(const Duration(minutes: 30))),
        StatusChange(status: OrderStatus.assigned, timestamp: DateTime.now().subtract(const Duration(minutes: 25))),
        StatusChange(status: OrderStatus.accepted, timestamp: DateTime.now().subtract(const Duration(minutes: 20))),
        StatusChange(status: OrderStatus.pickedUp, timestamp: DateTime.now().subtract(const Duration(minutes: 10))),
      ],
      deliveryOtp: '901234',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      slaTime: DateTime.now().add(const Duration(minutes: 20)),
    ),
    OrderModel(
      orderId: 'order_005',
      orderNumber: 'RIO005',
      customerName: 'Vikram Gupta',
      customerPhone: '+91 98765****4',
      deliveryAddress: 'Sector 50, Noida, Uttar Pradesh 201301',
      orderItems: [
        OrderItem(itemId: 'item_007', itemName: 'Face Mask N95', quantity: 10, price: 500.0),
        OrderItem(itemId: 'item_008', itemName: 'Hand Sanitizer', quantity: 2, price: 200.0),
      ],
      totalAmount: 700.0,
      paymentMethod: PaymentMethod.cash,
      pickupLocationCode: 'B1',
      status: OrderStatus.inTransit,
      timeline: [
        StatusChange(status: OrderStatus.newOrder, timestamp: DateTime.now().subtract(const Duration(minutes: 45))),
        StatusChange(status: OrderStatus.assigned, timestamp: DateTime.now().subtract(const Duration(minutes: 40))),
        StatusChange(status: OrderStatus.accepted, timestamp: DateTime.now().subtract(const Duration(minutes: 35))),
        StatusChange(status: OrderStatus.pickedUp, timestamp: DateTime.now().subtract(const Duration(minutes: 20))),
        StatusChange(status: OrderStatus.inTransit, timestamp: DateTime.now().subtract(const Duration(minutes: 15))),
      ],
      deliveryOtp: '567890',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      slaTime: DateTime.now().add(const Duration(minutes: 5)),
    ),
  ];

  List<OrderModel> getAllOrders() {
    return List.from(_orders);
  }

  List<OrderModel> getActiveOrders() {
    return _orders.where((order) => 
      order.status != OrderStatus.completed && 
      order.status != OrderStatus.delivered
    ).toList();
  }

  List<OrderModel> getCompletedOrders() {
    return _orders.where((order) => 
      order.status == OrderStatus.completed || 
      order.status == OrderStatus.delivered
    ).toList();
  }

  List<OrderModel> getPendingOrders() {
    return _orders.where((order) => 
      order.status == OrderStatus.assigned
    ).toList();
  }

  List<OrderModel> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  bool acceptOrder(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1 && _orders[orderIndex].status == OrderStatus.assigned) {
      _orders[orderIndex].status = OrderStatus.accepted;
      _orders[orderIndex].timeline.add(
        StatusChange(status: OrderStatus.accepted, timestamp: DateTime.now()),
      );
      return true;
    }
    return false;
  }

  bool rejectOrder(String orderId, String reason) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1 && _orders[orderIndex].status == OrderStatus.assigned) {
      // In a real app, you might have a rejected status
      // For now, we'll just remove it from the assigned orders
      _orders.removeAt(orderIndex);
      return true;
    }
    return false;
  }

  bool markOrderAsPickedUp(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1 && _orders[orderIndex].status == OrderStatus.accepted) {
      _orders[orderIndex].status = OrderStatus.pickedUp;
      _orders[orderIndex].timeline.add(
        StatusChange(status: OrderStatus.pickedUp, timestamp: DateTime.now()),
      );
      return true;
    }
    return false;
  }

  bool markOrderAsInTransit(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1 && _orders[orderIndex].status == OrderStatus.pickedUp) {
      _orders[orderIndex].status = OrderStatus.inTransit;
      _orders[orderIndex].timeline.add(
        StatusChange(status: OrderStatus.inTransit, timestamp: DateTime.now()),
      );
      return true;
    }
    return false;
  }

  bool markOrderAsDelivered(String orderId, String? proofUrl) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1 && _orders[orderIndex].status == OrderStatus.inTransit) {
      _orders[orderIndex].status = OrderStatus.delivered;
      _orders[orderIndex].deliveredAt = DateTime.now();
      _orders[orderIndex].deliveryProofUrl = proofUrl;
      _orders[orderIndex].timeline.add(
        StatusChange(status: OrderStatus.delivered, timestamp: DateTime.now()),
      );
      return true;
    }
    return false;
  }

  bool markOrderAsCompleted(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.orderId == orderId);
    if (orderIndex != -1 && _orders[orderIndex].status == OrderStatus.delivered) {
      _orders[orderIndex].status = OrderStatus.completed;
      _orders[orderIndex].timeline.add(
        StatusChange(status: OrderStatus.completed, timestamp: DateTime.now()),
      );
      return true;
    }
    return false;
  }

  bool verifyDeliveryOtp(String orderId, String otp) {
    final order = getOrderById(orderId);
    if (order != null && order.deliveryOtp == otp) {
      return markOrderAsDelivered(orderId, null);
    }
    return false;
  }

  // Simulate new order assignment
  void simulateNewOrder() {
    final newOrder = OrderModel(
      orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: 'RIO${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      customerName: 'New Customer',
      customerPhone: '+91 98765****9',
      deliveryAddress: 'Sector 10, Noida, Uttar Pradesh 201301',
      orderItems: [
        OrderItem(itemId: 'item_new', itemName: 'Medicine', quantity: 1, price: 100.0),
      ],
      totalAmount: 100.0,
      paymentMethod: PaymentMethod.cash,
      pickupLocationCode: 'A1',
      status: OrderStatus.assigned,
      timeline: [
        StatusChange(status: OrderStatus.newOrder, timestamp: DateTime.now().subtract(const Duration(seconds: 30))),
        StatusChange(status: OrderStatus.assigned, timestamp: DateTime.now()),
      ],
      deliveryOtp: '${DateTime.now().millisecondsSinceEpoch % 1000000}',
      createdAt: DateTime.now(),
      slaTime: DateTime.now().add(const Duration(minutes: 15)),
    );
    
    _orders.insert(0, newOrder);
  }
}
