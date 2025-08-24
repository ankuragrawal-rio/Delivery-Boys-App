import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shift_model.dart';

class WebDutyService {
  static const String _currentShiftKey = 'current_shift_web';
  static const String _shiftsHistoryKey = 'shifts_history_web';
  
  final StreamController<ShiftModel?> _currentShiftController = StreamController<ShiftModel?>.broadcast();
  final StreamController<BreakRecord?> _currentBreakController = StreamController<BreakRecord?>.broadcast();
  
  Timer? _breakTimer;
  Timer? _notificationTimer;
  
  ShiftModel? _currentShift;
  List<ShiftModel> _shiftsHistory = [];

  Stream<ShiftModel?> get currentShiftStream => _currentShiftController.stream;
  Stream<BreakRecord?> get currentBreakStream => _currentBreakController.stream;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load current shift
      final currentShiftJson = prefs.getString(_currentShiftKey);
      if (currentShiftJson != null) {
        final shiftData = json.decode(currentShiftJson);
        _currentShift = ShiftModel.fromJson(shiftData);
        _currentShiftController.add(_currentShift);
        
        // Check if on break and resume break timer
        final activeBreak = _currentShift?.breaks.where((b) => b.isActive).firstOrNull;
        if (activeBreak != null) {
          _currentBreakController.add(activeBreak);
          _startBreakTimer(activeBreak);
        }
      }
      
      // Load shifts history
      final historyJson = prefs.getString(_shiftsHistoryKey);
      if (historyJson != null) {
        final historyData = json.decode(historyJson) as List;
        _shiftsHistory = historyData.map((e) => ShiftModel.fromJson(e)).toList();
      }
      
      print('WebDutyService initialized successfully');
    } catch (e) {
      print('Error initializing WebDutyService: $e');
    }
  }

  // Clock In functionality
  Future<ShiftModel> clockIn({
    required String userId,
    String? location,
  }) async {
    // End any existing active shift first
    if (_currentShift != null && _currentShift!.isOnDuty) {
      await clockOut();
    }

    final shift = ShiftModel(
      id: _generateId(),
      userId: userId,
      clockInTime: DateTime.now(),
      clockInLocation: location ?? _getMockLocation(),
      breaks: [],
      status: ShiftStatus.active,
    );

    _currentShift = shift;
    await _saveCurrentShift();
    
    _currentShiftController.add(shift);
    return shift;
  }

  // Clock Out functionality
  Future<ShiftModel?> clockOut({String? location}) async {
    if (_currentShift == null || !_currentShift!.isOnDuty) {
      throw Exception('No active shift to clock out');
    }

    // End any active break first
    if (_currentShift!.isOnBreak) {
      await endBreak();
    }

    _currentShift!.clockOutTime = DateTime.now();
    _currentShift!.clockOutLocation = location ?? _getMockLocation();
    _currentShift!.status = ShiftStatus.completed;
    
    // Calculate total hours
    _currentShift!.totalHours = _currentShift!.workingDuration.inMinutes / 60.0;
    _currentShift!.totalBreakHours = _currentShift!.breaks.fold<double>(
      0.0,
      (sum, breakRecord) => sum + (breakRecord.duration.inMinutes / 60.0),
    );

    // Save to history
    _shiftsHistory.add(_currentShift!);
    await _saveShiftsHistory();
    
    final completedShift = _currentShift;
    _currentShift = null;
    await _clearCurrentShift();
    
    _currentShiftController.add(null);
    _stopBreakTimer();
    
    return completedShift;
  }

  // Start Break functionality
  Future<BreakRecord> startBreak({
    required BreakType type,
    String? reason,
  }) async {
    if (_currentShift == null || !_currentShift!.isOnDuty) {
      throw Exception('No active shift to take break');
    }

    if (_currentShift!.isOnBreak) {
      throw Exception('Already on break');
    }

    final breakRecord = BreakRecord(
      id: _generateId(),
      startTime: DateTime.now(),
      type: type,
      reason: reason,
    );

    _currentShift!.breaks.add(breakRecord);
    await _saveCurrentShift();
    
    _currentBreakController.add(breakRecord);
    _startBreakTimer(breakRecord);
    
    return breakRecord;
  }

  // End Break functionality
  Future<BreakRecord?> endBreak() async {
    if (_currentShift == null || !_currentShift!.isOnDuty) {
      throw Exception('No active shift');
    }

    final activeBreak = _currentShift!.breaks.where((b) => b.isActive).firstOrNull;
    if (activeBreak == null) {
      throw Exception('No active break to end');
    }

    activeBreak.endTime = DateTime.now();
    await _saveCurrentShift();
    
    _currentBreakController.add(null);
    _stopBreakTimer();
    
    return activeBreak;
  }

  // Get current active shift
  ShiftModel? getCurrentShift() {
    return _currentShift;
  }

  // Get current active break
  BreakRecord? getCurrentBreak() {
    if (_currentShift == null) return null;
    
    return _currentShift!.breaks.where((b) => b.isActive).firstOrNull;
  }

  // Get shift history
  Future<List<ShiftModel>> getShiftHistory({
    int limit = 30,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filteredShifts = List<ShiftModel>.from(_shiftsHistory);
    
    // Filter by date range if provided
    if (startDate != null) {
      filteredShifts = filteredShifts.where((s) => s.clockInTime.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filteredShifts = filteredShifts.where((s) => s.clockInTime.isBefore(endDate)).toList();
    }
    
    // Sort by clock in time (most recent first)
    filteredShifts.sort((a, b) => b.clockInTime.compareTo(a.clockInTime));
    
    return filteredShifts.take(limit).toList();
  }

  // Get today's shift statistics
  Map<String, dynamic> getTodayStats() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final todayShifts = _shiftsHistory.where((shift) {
      return shift.clockInTime.isAfter(todayStart) && 
             shift.clockInTime.isBefore(todayEnd);
    }).toList();
    
    // Include current shift if active
    if (_currentShift != null && _currentShift!.clockInTime.isAfter(todayStart)) {
      todayShifts.add(_currentShift!);
    }
    
    double totalHours = 0;
    double totalBreakHours = 0;
    int completedShifts = 0;
    
    for (final shift in todayShifts) {
      if (shift.status == ShiftStatus.completed) {
        totalHours += shift.totalHours ?? 0;
        totalBreakHours += shift.totalBreakHours ?? 0;
        completedShifts++;
      } else if (shift.status == ShiftStatus.active) {
        // Calculate current working hours for active shift
        totalHours += shift.workingDuration.inMinutes / 60.0;
        totalBreakHours += shift.breaks.fold<double>(
          0.0,
          (sum, b) => sum + (b.duration.inMinutes / 60.0),
        );
      }
    }
    
    return {
      'totalHours': totalHours,
      'totalBreakHours': totalBreakHours,
      'completedShifts': completedShifts,
      'activeShift': getCurrentShift(),
      'isOnDuty': getCurrentShift()?.isOnDuty ?? false,
      'isOnBreak': getCurrentShift()?.isOnBreak ?? false,
    };
  }

  // Break timer management
  void _startBreakTimer(BreakRecord breakRecord) {
    _stopBreakTimer(); // Stop any existing timer
    
    final maxDuration = _getMaxBreakDuration(breakRecord.type);
    final elapsed = breakRecord.duration;
    final remaining = maxDuration - elapsed;
    
    if (remaining.inSeconds > 0) {
      _breakTimer = Timer(remaining, () {
        _notifyBreakTimeUp(breakRecord);
      });
      
      // Set notification timer for 5 minutes before break ends
      final notificationTime = remaining - const Duration(minutes: 5);
      if (notificationTime.inSeconds > 0) {
        _notificationTimer = Timer(notificationTime, () {
          _notifyBreakEndingSoon(breakRecord);
        });
      }
    }
  }

  void _stopBreakTimer() {
    _breakTimer?.cancel();
    _breakTimer = null;
    _notificationTimer?.cancel();
    _notificationTimer = null;
  }

  Duration _getMaxBreakDuration(BreakType type) {
    switch (type) {
      case BreakType.lunch:
        return const Duration(minutes: 30);
      case BreakType.short:
        return const Duration(minutes: 10);
      case BreakType.emergency:
        return const Duration(minutes: 15);
    }
  }

  void _notifyBreakTimeUp(BreakRecord breakRecord) {
    print('Break time is up! Please return to duty.');
  }

  void _notifyBreakEndingSoon(BreakRecord breakRecord) {
    print('Break ending in 5 minutes. Please prepare to return to duty.');
  }

  // Storage helpers
  Future<void> _saveCurrentShift() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentShift != null) {
      await prefs.setString(_currentShiftKey, json.encode(_currentShift!.toJson()));
    }
  }

  Future<void> _clearCurrentShift() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentShiftKey);
  }

  Future<void> _saveShiftsHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(_shiftsHistory.map((e) => e.toJson()).toList());
    await prefs.setString(_shiftsHistoryKey, historyJson);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  String _getMockLocation() {
    final locations = [
      'Rio Delivery Hub - Sector 18',
      'Rio Delivery Hub - Cyber City',
      'Rio Delivery Hub - MG Road',
      'Rio Delivery Hub - Connaught Place',
      'Rio Delivery Hub - Karol Bagh',
    ];
    return locations[Random().nextInt(locations.length)];
  }

  void dispose() {
    _currentShiftController.close();
    _currentBreakController.close();
    _stopBreakTimer();
  }
}
