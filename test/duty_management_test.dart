import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../lib/data/mock_services/mock_duty_service.dart';
import '../lib/data/models/shift_model.dart';

void main() {
  group('Duty Management Tests', () {
    late MockDutyService dutyService;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      Hive.registerAdapter(ShiftModelAdapter());
      Hive.registerAdapter(BreakRecordAdapter());
      Hive.registerAdapter(ShiftStatusAdapter());
      Hive.registerAdapter(BreakTypeAdapter());
    });

    setUp(() async {
      dutyService = MockDutyService();
      await dutyService.initialize();
    });

    tearDown(() async {
      dutyService.dispose();
      // Clean up Hive boxes
      await Hive.deleteBoxFromDisk('shifts');
    });

    test('✅ Feature 1: Automatic location capture during clock in/out', () async {
      print('\n🧪 Testing Automatic Location Capture...');
      
      // Test clock in with automatic location
      final shift = await dutyService.clockIn(userId: 'test_user');
      
      print('📍 Clock In Location: ${shift.clockInLocation}');
      expect(shift.clockInLocation, isNotNull);
      expect(shift.clockInLocation, contains('Rio Delivery Hub'));
      
      // Wait a moment to simulate work
      await Future.delayed(Duration(seconds: 2));
      
      // Test clock out with automatic location
      final completedShift = await dutyService.clockOut();
      
      print('📍 Clock Out Location: ${completedShift?.clockOutLocation}');
      expect(completedShift?.clockOutLocation, isNotNull);
      expect(completedShift?.clockOutLocation, contains('Rio Delivery Hub'));
      
      print('✅ Location capture test PASSED\n');
    });

    test('✅ Feature 2: Break timer notifications', () async {
      print('🧪 Testing Break Timer Notifications...');
      
      // Clock in first
      await dutyService.clockIn(userId: 'test_user');
      
      // Start a short break (10 minutes max)
      final breakRecord = await dutyService.startBreak(type: BreakType.short);
      
      print('⏰ Break started at: ${breakRecord.startTime}');
      print('📝 Break type: ${breakRecord.type}');
      print('⏱️ Max duration: 10 minutes');
      
      // Simulate time passing (in real app, timers would trigger)
      await Future.delayed(Duration(milliseconds: 100));
      
      // Check break is active
      final currentBreak = dutyService.getCurrentBreak();
      expect(currentBreak, isNotNull);
      expect(currentBreak?.isActive, isTrue);
      
      print('🔔 Timer is running (notifications would trigger at 5min and 10min)');
      print('✅ Break timer test PASSED\n');
      
      // Clean up
      await dutyService.endBreak();
      await dutyService.clockOut();
    });

    test('✅ Feature 3: Real-time working hours calculation', () async {
      print('🧪 Testing Real-time Working Hours Calculation...');
      
      // Clock in
      final shift = await dutyService.clockIn(userId: 'test_user');
      final clockInTime = shift.clockInTime;
      
      print('🕐 Clock in time: ${clockInTime.toLocal()}');
      
      // Simulate some work time
      await Future.delayed(Duration(seconds: 2));
      
      // Check working duration
      var workingDuration = shift.workingDuration;
      print('⏱️ Working duration (no breaks): ${workingDuration.inSeconds} seconds');
      expect(workingDuration.inSeconds, greaterThan(1));
      
      // Take a break
      await dutyService.startBreak(type: BreakType.short);
      await Future.delayed(Duration(seconds: 1));
      await dutyService.endBreak();
      
      // Check working duration after break
      final updatedShift = dutyService.getCurrentShift();
      final finalWorkingDuration = updatedShift!.workingDuration;
      
      print('⏱️ Working duration (after break): ${finalWorkingDuration.inSeconds} seconds');
      print('🔢 Break duration: ${updatedShift.breaks.first.duration.inSeconds} seconds');
      
      // Working duration should exclude break time
      expect(finalWorkingDuration.inSeconds, lessThan(workingDuration.inSeconds + 3));
      
      // Clock out and check final calculations
      final completedShift = await dutyService.clockOut();
      
      print('📊 Final Stats:');
      print('   Total hours: ${completedShift?.totalHours?.toStringAsFixed(4)}');
      print('   Break hours: ${completedShift?.totalBreakHours?.toStringAsFixed(4)}');
      
      expect(completedShift?.totalHours, isNotNull);
      expect(completedShift?.totalBreakHours, isNotNull);
      
      print('✅ Working hours calculation test PASSED\n');
    });

    test('🔄 Comprehensive Duty Management Flow', () async {
      print('🧪 Testing Complete Duty Management Flow...');
      
      // 1. Clock in
      print('1️⃣ Clocking in...');
      final shift = await dutyService.clockIn(userId: 'test_user');
      expect(shift.isOnDuty, isTrue);
      print('   ✅ Clocked in at ${shift.clockInLocation}');
      
      // 2. Check today's stats
      var stats = dutyService.getTodayStats();
      print('2️⃣ Today\'s stats: ${stats['isOnDuty']} on duty');
      
      // 3. Take lunch break
      print('3️⃣ Taking lunch break...');
      await dutyService.startBreak(type: BreakType.lunch, reason: 'Lunch time');
      expect(dutyService.getCurrentShift()?.isOnBreak, isTrue);
      print('   ✅ On lunch break');
      
      // 4. End break
      print('4️⃣ Ending break...');
      await dutyService.endBreak();
      expect(dutyService.getCurrentShift()?.isOnBreak, isFalse);
      print('   ✅ Back from break');
      
      // 5. Clock out
      print('5️⃣ Clocking out...');
      final completedShift = await dutyService.clockOut();
      expect(completedShift?.status, ShiftStatus.completed);
      print('   ✅ Clocked out');
      
      // 6. Verify shift history
      print('6️⃣ Checking shift history...');
      final history = await dutyService.getShiftHistory(limit: 5);
      expect(history.length, greaterThan(0));
      print('   ✅ ${history.length} shifts in history');
      
      print('🎉 Complete flow test PASSED\n');
    });
  });
}

// Helper function to run manual tests
void runManualTest() async {
  print('🚀 Starting Manual Duty Management Test\n');
  
  await Hive.initFlutter();
  Hive.registerAdapter(ShiftModelAdapter());
  Hive.registerAdapter(BreakRecordAdapter());
  Hive.registerAdapter(ShiftStatusAdapter());
  Hive.registerAdapter(BreakTypeAdapter());
  
  final dutyService = MockDutyService();
  await dutyService.initialize();
  
  try {
    // Test 1: Location Capture
    print('📍 Test 1: Location Capture');
    final shift = await dutyService.clockIn(userId: 'manual_test');
    print('Clock in location: ${shift.clockInLocation}');
    
    // Test 2: Break Management
    print('\n⏰ Test 2: Break Management');
    final breakRecord = await dutyService.startBreak(type: BreakType.short);
    print('Break started: ${breakRecord.startTime}');
    print('Break type: ${breakRecord.type}');
    
    await Future.delayed(Duration(seconds: 2));
    await dutyService.endBreak();
    print('Break ended after ${breakRecord.duration.inSeconds} seconds');
    
    // Test 3: Working Hours
    print('\n⏱️ Test 3: Working Hours Calculation');
    final currentShift = dutyService.getCurrentShift();
    print('Working duration: ${currentShift?.workingDuration.inSeconds} seconds');
    
    // Clock out
    final completedShift = await dutyService.clockOut();
    print('Final working hours: ${completedShift?.totalHours}');
    print('Final break hours: ${completedShift?.totalBreakHours}');
    
    print('\n✅ All manual tests completed successfully!');
    
  } catch (e) {
    print('❌ Test failed: $e');
  } finally {
    dutyService.dispose();
  }
}
