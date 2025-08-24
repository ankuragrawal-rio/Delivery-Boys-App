import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/duty_service.dart';
import '../../data/models/shift_model.dart';
import '../../data/models/user_model.dart';

class DutyTestScreen extends ConsumerStatefulWidget {
  const DutyTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DutyTestScreen> createState() => _DutyTestScreenState();
}

class _DutyTestScreenState extends ConsumerState<DutyTestScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize duty service
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(dutyServiceProvider).initialize();
      } catch (e) {
        print('Error initializing duty service: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentShift = ref.watch(currentShiftProvider);
    final currentBreak = ref.watch(currentBreakProvider);
    final dutyStats = ref.watch(dutyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Duty Management Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature 1: Location Capture
            _buildFeatureCard(
              title: '📍 Feature 1: Automatic Location Capture',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(currentShift),
                  const SizedBox(height: 16),
                  _buildClockButtons(currentShift),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feature 2: Break Timer Notifications
            _buildFeatureCard(
              title: '⏰ Feature 2: Break Timer Notifications',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreakControls(currentShift, currentBreak),
                  const SizedBox(height: 16),
                  _buildBreakStatus(currentBreak),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feature 3: Working Hours Calculation
            _buildFeatureCard(
              title: '⏱️ Feature 3: Real-time Working Hours',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWorkingHoursDisplay(currentShift, dutyStats),
                  const SizedBox(height: 16),
                  _buildLiveTimer(currentShift),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Debug Information
            _buildFeatureCard(
              title: '🔍 Debug Information',
              child: _buildDebugInfo(currentShift, currentBreak, dutyStats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusCard(ShiftModel? currentShift) {
    final isOnDuty = currentShift?.isOnDuty ?? false;
    final isOnBreak = currentShift?.isOnBreak ?? false;
    
    String status = 'Off Duty';
    Color statusColor = Colors.grey;
    
    if (isOnDuty && isOnBreak) {
      status = 'On Break';
      statusColor = Colors.orange;
    } else if (isOnDuty) {
      status = 'On Duty';
      statusColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 12),
              const SizedBox(width: 8),
              Text(
                'Status: $status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (currentShift?.clockInLocation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Location: ${currentShift!.clockInLocation}',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClockButtons(ShiftModel? currentShift) {
    final isOnDuty = currentShift?.isOnDuty ?? false;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isOnDuty ? null : () => _clockIn(),
            icon: const Icon(Icons.login),
            label: const Text('Clock In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isOnDuty ? () => _clockOut() : null,
            icon: const Icon(Icons.logout),
            label: const Text('Clock Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakControls(ShiftModel? currentShift, BreakRecord? currentBreak) {
    final isOnDuty = currentShift?.isOnDuty ?? false;
    final isOnBreak = currentBreak != null;

    if (!isOnDuty) {
      return const Text(
        'Clock in first to take breaks',
        style: TextStyle(color: Colors.grey),
      );
    }

    if (isOnBreak) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: Column(
              children: [
                Text(
                  'On ${currentBreak!.type.toString().split('.').last.toUpperCase()} Break',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder(
                  stream: Stream.periodic(const Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    final elapsed = currentBreak.duration;
                    final maxDuration = _getMaxBreakDuration(currentBreak.type);
                    final remaining = maxDuration - elapsed;
                    
                    final minutes = remaining.inMinutes;
                    final seconds = remaining.inSeconds % 60;
                    
                    return Text(
                      remaining.inSeconds > 0 
                        ? '${minutes}:${seconds.toString().padLeft(2, '0')} remaining'
                        : 'TIME UP!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: remaining.inSeconds <= 300 ? Colors.red : Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _endBreak(),
            icon: const Icon(Icons.stop),
            label: const Text('End Break'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startBreak(BreakType.short),
                icon: const Icon(Icons.coffee),
                label: const Text('Short (10m)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _startBreak(BreakType.lunch),
                icon: const Icon(Icons.restaurant),
                label: const Text('Lunch (30m)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startBreak(BreakType.emergency),
            icon: const Icon(Icons.warning),
            label: const Text('Emergency Break (15m)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakStatus(BreakRecord? currentBreak) {
    if (currentBreak == null) {
      return const Text(
        'No active break',
        style: TextStyle(color: Colors.grey),
      );
    }

    final elapsed = currentBreak.duration;
    final maxDuration = _getMaxBreakDuration(currentBreak.type);
    final remaining = maxDuration - elapsed;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: remaining.inSeconds <= 300 ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: remaining.inSeconds <= 300 ? Colors.red[300]! : Colors.orange[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Break Details:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Type: ${currentBreak.type.toString().split('.').last.toUpperCase()}'),
          Text('Started: ${_formatTime(currentBreak.startTime)}'),
          Text('Elapsed: ${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s'),
          if (remaining.inSeconds <= 300 && remaining.inSeconds > 0)
            Text(
              '⚠️ Break ending soon!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (remaining.inSeconds <= 0)
            Text(
              '🔔 Break time is up!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursDisplay(ShiftModel? currentShift, AsyncValue<Map<String, dynamic>> dutyStats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: dutyStats.when(
        data: (stats) => Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${stats['totalHours']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    'Working Hours',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${stats['totalBreakHours']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text(
                    'Break Hours',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  Widget _buildLiveTimer(ShiftModel? currentShift) {
    if (currentShift == null || !currentShift.isOnDuty) {
      return const Center(
        child: Text(
          '00:00:00',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final workingDuration = currentShift.workingDuration;
        final hours = workingDuration.inHours;
        final minutes = workingDuration.inMinutes % 60;
        final seconds = workingDuration.inSeconds % 60;

        return Column(
          children: [
            Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'monospace',
              ),
            ),
            const Text(
              'Live Working Time (excludes breaks)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDebugInfo(ShiftModel? currentShift, BreakRecord? currentBreak, AsyncValue<Map<String, dynamic>> dutyStats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Shift ID: ${currentShift?.id ?? 'None'}'),
        Text('Clock In Time: ${currentShift?.clockInTime != null ? _formatTime(currentShift!.clockInTime) : 'None'}'),
        Text('Is On Duty: ${currentShift?.isOnDuty ?? false}'),
        Text('Is On Break: ${currentShift?.isOnBreak ?? false}'),
        Text('Current Break ID: ${currentBreak?.id ?? 'None'}'),
        Text('Break Type: ${currentBreak?.type.toString().split('.').last ?? 'None'}'),
        const SizedBox(height: 8),
        dutyStats.when(
          data: (stats) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Stats:'),
              Text('  - Total Hours: ${stats['totalHours']?.toStringAsFixed(4)}'),
              Text('  - Break Hours: ${stats['totalBreakHours']?.toStringAsFixed(4)}'),
              Text('  - Completed Shifts: ${stats['completedShifts']}'),
              Text('  - Is On Duty: ${stats['isOnDuty']}'),
              Text('  - Is On Break: ${stats['isOnBreak']}'),
            ],
          ),
          loading: () => const Text('Loading stats...'),
          error: (error, stack) => Text('Stats error: $error'),
        ),
      ],
    );
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

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _clockIn() async {
    try {
      await ref.read(currentShiftProvider.notifier).clockIn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Clocked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Clock in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clockOut() async {
    try {
      await ref.read(currentShiftProvider.notifier).clockOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Clocked out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Clock out failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startBreak(BreakType type) async {
    try {
      await ref.read(currentBreakProvider.notifier).startBreak(type);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${type.toString().split('.').last.toUpperCase()} break started!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Break start failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _endBreak() async {
    try {
      await ref.read(currentBreakProvider.notifier).endBreak();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Break ended successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ End break failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
