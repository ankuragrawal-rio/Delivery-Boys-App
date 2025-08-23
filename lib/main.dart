import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app.dart';
import 'core/services/notification_service.dart';
import 'core/services/duty_service.dart';
import 'data/models/user_model.dart';
import 'data/models/order_model.dart';
import 'data/models/shift_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(VehicleDetailsAdapter());
  Hive.registerAdapter(BankAccountDetailsAdapter());
  Hive.registerAdapter(UserStatusAdapter());
  Hive.registerAdapter(OrderModelAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  Hive.registerAdapter(StatusChangeAdapter());
  Hive.registerAdapter(OrderStatusAdapter());
  Hive.registerAdapter(PaymentMethodAdapter());
  Hive.registerAdapter(PaymentStatusAdapter());
  Hive.registerAdapter(ShiftModelAdapter());
  Hive.registerAdapter(BreakRecordAdapter());
  Hive.registerAdapter(ShiftStatusAdapter());
  Hive.registerAdapter(BreakTypeAdapter());
  
  // Initialize notification service (temporarily disabled for web)
  // await NotificationService.initialize();
  
  // Initialize duty service
  final dutyService = DutyService();
  await dutyService.initialize();
  
  runApp(
    const ProviderScope(
      child: RioDeliveryApp(),
    ),
  );
}
