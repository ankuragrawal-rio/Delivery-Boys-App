import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/shift_model.dart';
import 'duty_service.dart';

// Provider for the availability service
final availabilityServiceProvider = Provider<AvailabilityService>((ref) {
  return AvailabilityService(ref.read(dutyServiceProvider));
});

// Provider for current availability status
final availabilityStatusProvider = StateNotifierProvider<AvailabilityStatusNotifier, UserStatus>((ref) {
  return AvailabilityStatusNotifier(ref.read(availabilityServiceProvider));
});

// Provider for manual override status
final manualOverrideProvider = StateProvider<bool>((ref) => false);

class AvailabilityService {
  final DutyService _dutyService;
  static const String _statusKey = 'availability_status';
  static const String _manualOverrideKey = 'manual_override';
  
  AvailabilityService(this._dutyService);

  /// Get current availability status from storage
  Future<UserStatus> getCurrentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(_statusKey) ?? 'offline';
    return UserStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => UserStatus.offline,
    );
  }

  /// Update availability status
  Future<void> updateStatus(UserStatus status, {bool isManual = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statusKey, status.name);
    await prefs.setBool(_manualOverrideKey, isManual);
  }

  /// Check if status is manually overridden
  Future<bool> isManualOverride() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_manualOverrideKey) ?? false;
  }

  /// Clear manual override
  Future<void> clearManualOverride() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_manualOverrideKey, false);
  }

  /// Auto-update status based on duty state
  Future<UserStatus> getAutoStatus() async {
    final currentShift = _dutyService.getCurrentShift();
    final currentBreak = _dutyService.getCurrentBreak();
    
    // If not clocked in, user is offline
    if (currentShift == null || !currentShift.isOnDuty) {
      return UserStatus.offline;
    }
    
    // If on break, user is on break
    if (currentBreak != null && currentBreak.isActive) {
      return UserStatus.onBreak;
    }
    
    // If clocked in and not on break, user is available
    return UserStatus.available;
  }

  /// Get status with auto-sync logic
  Future<UserStatus> getEffectiveStatus() async {
    final isManual = await isManualOverride();
    
    if (isManual) {
      return await getCurrentStatus();
    } else {
      return await getAutoStatus();
    }
  }

  /// Sync status with duty state (called automatically)
  Future<void> syncWithDutyState() async {
    final isManual = await isManualOverride();
    
    // Don't auto-sync if manually overridden
    if (isManual) return;
    
    final autoStatus = await getAutoStatus();
    await updateStatus(autoStatus, isManual: false);
  }

  /// Handle order acceptance (auto-change to busy)
  Future<void> onOrderAccepted() async {
    await updateStatus(UserStatus.busy, isManual: false);
    await clearManualOverride(); // Clear any manual override
  }

  /// Handle order completion (revert to available if on duty)
  Future<void> onOrderCompleted() async {
    final autoStatus = await getAutoStatus();
    await updateStatus(autoStatus, isManual: false);
  }

  /// Manual status change by user
  Future<void> setManualStatus(UserStatus status) async {
    await updateStatus(status, isManual: true);
  }

  /// Get status display info
  StatusDisplayInfo getStatusDisplayInfo(UserStatus status) {
    switch (status) {
      case UserStatus.available:
        return StatusDisplayInfo(
          label: 'Available',
          color: const Color(0xFF4CAF50), // Green
          icon: Icons.check_circle,
          description: 'Ready to accept orders',
        );
      case UserStatus.busy:
        return StatusDisplayInfo(
          label: 'Busy',
          color: const Color(0xFFFF9800), // Orange
          icon: Icons.delivery_dining,
          description: 'Currently on delivery',
        );
      case UserStatus.onBreak:
        return StatusDisplayInfo(
          label: 'On Break',
          color: const Color(0xFF2196F3), // Blue
          icon: Icons.coffee,
          description: 'Taking a break',
        );
      case UserStatus.offline:
        return StatusDisplayInfo(
          label: 'Offline',
          color: const Color(0xFF9E9E9E), // Grey
          icon: Icons.offline_bolt,
          description: 'Not available for orders',
        );
    }
  }
}

class AvailabilityStatusNotifier extends StateNotifier<UserStatus> {
  final AvailabilityService _availabilityService;

  AvailabilityStatusNotifier(this._availabilityService) : super(UserStatus.offline) {
    _loadCurrentStatus();
    _startAutoSync();
  }

  Future<void> _loadCurrentStatus() async {
    final status = await _availabilityService.getEffectiveStatus();
    state = status;
  }

  /// Start automatic sync with duty state
  void _startAutoSync() {
    // Sync every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _availabilityService.syncWithDutyState();
      final newStatus = await _availabilityService.getEffectiveStatus();
      if (state != newStatus) {
        state = newStatus;
      }
    });
  }

  /// Update status manually
  Future<void> updateStatus(UserStatus status, {bool isManual = false}) async {
    if (isManual) {
      await _availabilityService.setManualStatus(status);
    } else {
      await _availabilityService.updateStatus(status, isManual: false);
    }
    state = status;
  }

  /// Handle order events
  Future<void> onOrderAccepted() async {
    await _availabilityService.onOrderAccepted();
    state = UserStatus.busy;
  }

  Future<void> onOrderCompleted() async {
    await _availabilityService.onOrderCompleted();
    final newStatus = await _availabilityService.getEffectiveStatus();
    state = newStatus;
  }

  /// Force sync with duty state
  Future<void> syncWithDuty() async {
    await _availabilityService.syncWithDutyState();
    final newStatus = await _availabilityService.getEffectiveStatus();
    state = newStatus;
  }
}

class StatusDisplayInfo {
  final String label;
  final Color color;
  final IconData icon;
  final String description;

  StatusDisplayInfo({
    required this.label,
    required this.color,
    required this.icon,
    required this.description,
  });
}
