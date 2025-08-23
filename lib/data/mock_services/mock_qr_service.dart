import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import 'mock_order_service.dart';

final mockQrServiceProvider = Provider<MockQrService>((ref) {
  return MockQrService(ref);
});

class MockQrService {
  final Ref _ref;
  
  MockQrService(this._ref);

  static final List<PickupLocationInfo> _locations = [
    PickupLocationInfo(
      locationId: 'loc_001',
      locationCode: 'A1',
      qrCodeData: 'RIO_PICKUP_A1_001',
      description: 'Pharmacy Section A - Rack 1',
      isActive: true,
      lastScannedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      lastScannedBy: 'user_001',
    ),
    PickupLocationInfo(
      locationId: 'loc_002',
      locationCode: 'A2',
      qrCodeData: 'RIO_PICKUP_A2_002',
      description: 'Pharmacy Section A - Rack 2',
      isActive: true,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 1)),
      lastScannedBy: 'user_002',
    ),
    PickupLocationInfo(
      locationId: 'loc_003',
      locationCode: 'B1',
      qrCodeData: 'RIO_PICKUP_B1_003',
      description: 'Medical Equipment Section B - Rack 1',
      isActive: true,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 2)),
      lastScannedBy: 'user_001',
    ),
    PickupLocationInfo(
      locationId: 'loc_004',
      locationCode: 'B2',
      qrCodeData: 'RIO_PICKUP_B2_004',
      description: 'Medical Equipment Section B - Rack 2',
      isActive: true,
      lastScannedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      lastScannedBy: 'user_003',
    ),
    PickupLocationInfo(
      locationId: 'loc_005',
      locationCode: 'C3',
      qrCodeData: 'RIO_PICKUP_C3_005',
      description: 'Special Items Section C - Rack 3',
      isActive: true,
      lastScannedAt: DateTime.now().subtract(const Duration(hours: 3)),
      lastScannedBy: 'user_001',
    ),
  ];

  PickupLocationInfo? verifyLocationQr(String qrData) {
    try {
      final location = _locations.firstWhere((loc) => loc.qrCodeData == qrData);
      if (location.isActive) {
        // Update last scanned info
        location.lastScannedAt = DateTime.now();
        location.lastScannedBy = 'user_001'; // Current user
        
        // Get orders for this location
        final orderService = _ref.read(mockOrderServiceProvider);
        final ordersAtLocation = orderService.getAllOrders()
            .where((order) => order.pickupLocationCode == location.locationCode)
            .where((order) => order.status == OrderStatus.accepted || order.status == OrderStatus.pickupPending)
            .toList();
        
        location.orders = ordersAtLocation;
        return location;
      }
    } catch (e) {
      // Location not found
    }
    return null;
  }

  PickupLocationInfo? getLocationByCode(String locationCode) {
    try {
      final location = _locations.firstWhere((loc) => 
        loc.locationCode.toUpperCase() == locationCode.toUpperCase());
      if (location.isActive) {
        // Get orders for this location
        final orderService = _ref.read(mockOrderServiceProvider);
        final ordersAtLocation = orderService.getAllOrders()
            .where((order) => order.pickupLocationCode == location.locationCode)
            .where((order) => order.status == OrderStatus.accepted || order.status == OrderStatus.pickupPending)
            .toList();
        
        location.orders = ordersAtLocation;
        return location;
      }
    } catch (e) {
      // Location not found
    }
    return null;
  }

  List<PickupLocationInfo> getAllLocations() {
    return List.from(_locations);
  }

  List<OrderModel> getOrdersAtLocation(String locationCode) {
    final orderService = _ref.read(mockOrderServiceProvider);
    return orderService.getAllOrders()
        .where((order) => order.pickupLocationCode == locationCode)
        .where((order) => order.status == OrderStatus.accepted || order.status == OrderStatus.pickupPending)
        .toList();
  }

  bool confirmPickup(String locationCode, List<String> orderIds) {
    final orderService = _ref.read(mockOrderServiceProvider);
    bool allSuccess = true;
    
    for (String orderId in orderIds) {
      if (!orderService.markOrderAsPickedUp(orderId)) {
        allSuccess = false;
      }
    }
    
    // Update location last scanned info
    try {
      final location = _locations.firstWhere((loc) => loc.locationCode == locationCode);
      location.lastScannedAt = DateTime.now();
      location.lastScannedBy = 'user_001';
    } catch (e) {
      // Location not found
    }
    
    return allSuccess;
  }

  // Generate QR code data for a location (for testing purposes)
  String generateQrData(String locationCode) {
    return 'RIO_PICKUP_${locationCode}_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Validate if QR code follows Rio's format
  bool isValidRioQrCode(String qrData) {
    return qrData.startsWith('RIO_PICKUP_') && qrData.split('_').length >= 3;
  }
}

class PickupLocationInfo {
  final String locationId;
  final String locationCode;
  final String qrCodeData;
  final String description;
  final bool isActive;
  DateTime lastScannedAt;
  String lastScannedBy;
  List<OrderModel> orders;

  PickupLocationInfo({
    required this.locationId,
    required this.locationCode,
    required this.qrCodeData,
    required this.description,
    required this.isActive,
    required this.lastScannedAt,
    required this.lastScannedBy,
    this.orders = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'location_code': locationCode,
      'qr_code_data': qrCodeData,
      'description': description,
      'is_active': isActive,
      'last_scanned_at': lastScannedAt.toIso8601String(),
      'last_scanned_by': lastScannedBy,
    };
  }

  factory PickupLocationInfo.fromJson(Map<String, dynamic> json) {
    return PickupLocationInfo(
      locationId: json['location_id'],
      locationCode: json['location_code'],
      qrCodeData: json['qr_code_data'],
      description: json['description'],
      isActive: json['is_active'],
      lastScannedAt: DateTime.parse(json['last_scanned_at']),
      lastScannedBy: json['last_scanned_by'],
    );
  }
}
