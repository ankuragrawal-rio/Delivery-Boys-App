import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/availability_service.dart';
import '../../core/services/duty_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/shift_model.dart';
import '../widgets/status_indicator.dart';

class AvailabilityTestScreen extends ConsumerStatefulWidget {
  const AvailabilityTestScreen({super.key});

  @override
  ConsumerState<AvailabilityTestScreen> createState() => _AvailabilityTestScreenState();
}

class _AvailabilityTestScreenState extends ConsumerState<AvailabilityTestScreen> {
  String _lastAction = 'No actions yet';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(dutyServiceProvider).initialize();
      await ref.read(availabilityStatusProvider.notifier).syncWithDuty();
      setState(() => _lastAction = 'Services initialized successfully');
    } catch (e) {
      setState(() => _lastAction = 'Initialization error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performAction(String action, Future<void> Function() actionFunction) async {
    setState(() => _isLoading = true);
    try {
      await actionFunction();
      setState(() => _lastAction = '$action completed successfully');
    } catch (e) {
      setState(() => _lastAction = '$action failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = ref.watch(availabilityStatusProvider);
    final isManualOverride = ref.watch(manualOverrideProvider);
    final dutyService = ref.read(dutyServiceProvider);
    final statusNotifier = ref.read(availabilityStatusProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Status Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusIndicator(
              isCompact: true,
              showLabel: true,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Status Display
                  const Text(
                    'Current Status',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StatusIndicator(showLabel: true, isCompact: false),
                  
                  const SizedBox(height: 24),
                  
                  // Status Override Info
                  StatusOverrideInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // Manual Status Selector
                  StatusSelector(),
                  
                  const SizedBox(height: 24),
                  
                  // Duty Actions (to test auto-sync)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Duty Actions (Test Auto-Sync)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _performAction(
                                  'Clock In',
                                  () async {
                                    await dutyService.clockIn(location: 'Test Location');
                                    await statusNotifier.syncWithDuty();
                                  },
                                ),
                                icon: const Icon(Icons.login),
                                label: const Text('Clock In'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _performAction(
                                  'Start Break',
                                  () async {
                                    await dutyService.startBreak(BreakType.short, reason: 'Test break');
                                    await statusNotifier.syncWithDuty();
                                  },
                                ),
                                icon: const Icon(Icons.coffee),
                                label: const Text('Start Break'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _performAction(
                                  'End Break',
                                  () async {
                                    await dutyService.endBreak();
                                    await statusNotifier.syncWithDuty();
                                  },
                                ),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('End Break'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _performAction(
                                  'Clock Out',
                                  () async {
                                    await dutyService.clockOut(location: 'Test Location');
                                    await statusNotifier.syncWithDuty();
                                  },
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text('Clock Out'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Order Actions (to test status changes)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Actions (Test Status Changes)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _performAction(
                                  'Accept Order',
                                  () async {
                                    await statusNotifier.onOrderAccepted();
                                    ref.read(manualOverrideProvider.notifier).state = false;
                                  },
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text('Accept Order'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _performAction(
                                  'Complete Order',
                                  () async {
                                    await statusNotifier.onOrderCompleted();
                                  },
                                ),
                                icon: const Icon(Icons.done_all),
                                label: const Text('Complete Order'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Debug Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildDebugRow('Current Status', currentStatus.name),
                          _buildDebugRow('Manual Override', isManualOverride.toString()),
                          _buildDebugRow('Last Action', _lastAction),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _performAction(
                              'Force Sync',
                              () async {
                                await statusNotifier.syncWithDuty();
                              },
                            ),
                            icon: const Icon(Icons.sync),
                            label: const Text('Force Sync with Duty'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Test Instructions
                  Card(
                    color: Colors.blue.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Test Instructions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Clock In → Status should auto-change to Available\n'
                            '2. Start Break → Status should auto-change to On Break\n'
                            '3. End Break → Status should auto-change to Available\n'
                            '4. Accept Order → Status should auto-change to Busy\n'
                            '5. Complete Order → Status should revert to Available\n'
                            '6. Manually change status → Manual override activates\n'
                            '7. Resume Auto-Sync → Status syncs with duty state\n'
                            '8. Clock Out → Status should auto-change to Offline',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
