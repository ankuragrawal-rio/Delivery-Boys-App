import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/user_model.dart';
import '../../data/mock_services/web_duty_service.dart';

final webDutyServiceProvider = Provider<WebDutyService>((ref) => WebDutyService());

final dutyServiceProvider = Provider<DutyService>((ref) => DutyService(ref.read(webDutyServiceProvider)));

final currentShiftProvider = StateNotifierProvider<CurrentShiftNotifier, ShiftModel?>((ref) {
  return CurrentShiftNotifier(ref.read(dutyServiceProvider));
});

final currentBreakProvider = StateNotifierProvider<CurrentBreakNotifier, BreakRecord?>((ref) {
  return CurrentBreakNotifier(ref.read(dutyServiceProvider));
});

final dutyStatusProvider = StateProvider<UserStatus>((ref) => UserStatus.offline);

final dutyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(dutyServiceProvider).getTodayStats();
});

class DutyService {
  final WebDutyService _webDutyService;
  static const String _dutyStatusKey = 'duty_status';
  
  DutyService(this._webDutyService);
  
  Future<void> initialize() async {
    await _webDutyService.initialize();
  }

  ShiftModel? getCurrentShift() {
    return _webDutyService.getCurrentShift();
  }

  BreakRecord? getCurrentBreak() {
    return _webDutyService.getCurrentBreak();
  }

  Stream<ShiftModel?> get currentShiftStream => _webDutyService.currentShiftStream;
  Stream<BreakRecord?> get currentBreakStream => _webDutyService.currentBreakStream;

  Future<UserStatus> getDutyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(_dutyStatusKey) ?? 'offline';
    return UserStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusString,
      orElse: () => UserStatus.offline,
    );
  }

  Future<ShiftModel> clockIn({String? location}) async {
    final shift = await _webDutyService.clockIn(
      userId: 'current_user', // TODO: Get from auth service
      location: location,
    );
    
    // Update duty status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dutyStatusKey, UserStatus.available.toString().split('.').last);

    return shift;
  }

  Future<ShiftModel?> clockOut({String? location}) async {
    final shift = await _webDutyService.clockOut(location: location);
    
    // Update duty status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dutyStatusKey, UserStatus.offline.toString().split('.').last);

    return shift;
  }

  Future<BreakRecord> startBreak(BreakType type, {String? reason}) async {
    final breakRecord = await _webDutyService.startBreak(
      type: type,
      reason: reason,
    );
    
    // Update duty status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dutyStatusKey, UserStatus.onBreak.toString().split('.').last);

    return breakRecord;
  }

  Future<BreakRecord?> endBreak() async {
    final breakRecord = await _webDutyService.endBreak();
    
    // Update duty status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dutyStatusKey, UserStatus.available.toString().split('.').last);

    return breakRecord;
  }

  Future<void> updateDutyStatus(UserStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dutyStatusKey, status.toString().split('.').last);
  }

  Future<List<ShiftModel>> getShiftHistory({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    return await _webDutyService.getShiftHistory(
      limit: 50,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> getTodayStats() async {
    return _webDutyService.getTodayStats();
  }
}

class CurrentShiftNotifier extends StateNotifier<ShiftModel?> {
  final DutyService _dutyService;

  CurrentShiftNotifier(this._dutyService) : super(null) {
    _loadCurrentShift();
    _listenToShiftChanges();
  }

  void _loadCurrentShift() {
    final shift = _dutyService.getCurrentShift();
    state = shift;
  }

  void _listenToShiftChanges() {
    _dutyService.currentShiftStream.listen((shift) {
      state = shift;
    });
  }

  Future<void> clockIn({String? location}) async {
    await _dutyService.clockIn(location: location);
    // State will be updated via stream
  }

  Future<void> clockOut({String? location}) async {
    await _dutyService.clockOut(location: location);
    // State will be updated via stream
  }

  Future<void> startBreak(BreakType type, {String? reason}) async {
    await _dutyService.startBreak(type, reason: reason);
    // State will be updated via stream
  }

  Future<void> endBreak() async {
    await _dutyService.endBreak();
    // State will be updated via stream
  }
}

class CurrentBreakNotifier extends StateNotifier<BreakRecord?> {
  final DutyService _dutyService;

  CurrentBreakNotifier(this._dutyService) : super(null) {
    _loadCurrentBreak();
    _listenToBreakChanges();
  }

  void _loadCurrentBreak() {
    final breakRecord = _dutyService.getCurrentBreak();
    state = breakRecord;
  }

  void _listenToBreakChanges() {
    _dutyService.currentBreakStream.listen((breakRecord) {
      state = breakRecord;
    });
  }

  Future<void> startBreak(BreakType type, {String? reason}) async {
    await _dutyService.startBreak(type, reason: reason);
    // State will be updated via stream
  }

  Future<void> endBreak() async {
    await _dutyService.endBreak();
    // State will be updated via stream
  }

  Duration? get remainingTime {
    if (state == null) return null;
    
    final maxDuration = _getMaxBreakDuration(state!.type);
    final elapsed = state!.duration;
    final remaining = maxDuration - elapsed;
    
    return remaining.inSeconds > 0 ? remaining : Duration.zero;
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
}
