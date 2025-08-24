import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/availability_service.dart';
import '../../data/models/user_model.dart';

class StatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final bool isCompact;

  const StatusIndicator({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(availabilityStatusProvider);
    final availabilityService = ref.read(availabilityServiceProvider);
    final statusInfo = availabilityService.getStatusDisplayInfo(status);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusInfo.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusInfo.color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusInfo.icon,
              size: 16,
              color: statusInfo.color,
            ),
            if (showLabel) ...[
              const SizedBox(width: 4),
              Text(
                statusInfo.label,
                style: TextStyle(
                  color: statusInfo.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusInfo.color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                statusInfo.icon,
                color: statusInfo.color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                statusInfo.label,
                style: TextStyle(
                  color: statusInfo.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            statusInfo.description,
            style: TextStyle(
              color: statusInfo.color.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusSelector extends ConsumerWidget {
  const StatusSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStatus = ref.watch(availabilityStatusProvider);
    final availabilityService = ref.read(availabilityServiceProvider);
    final statusNotifier = ref.read(availabilityStatusProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...UserStatus.values.map((status) {
              final statusInfo = availabilityService.getStatusDisplayInfo(status);
              final isSelected = currentStatus == status;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () async {
                    await statusNotifier.updateStatus(status, isManual: true);
                    ref.read(manualOverrideProvider.notifier).state = true;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? statusInfo.color.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                            ? statusInfo.color 
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          statusInfo.icon,
                          color: statusInfo.color,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusInfo.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: statusInfo.color,
                                ),
                              ),
                              Text(
                                statusInfo.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: statusInfo.color,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class StatusOverrideInfo extends ConsumerWidget {
  const StatusOverrideInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManualOverride = ref.watch(manualOverrideProvider);
    final statusNotifier = ref.read(availabilityStatusProvider.notifier);

    if (!isManualOverride) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.sync, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Status is automatically synced with duty state',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.orange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Manual Override Active',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Status is manually set and won\'t auto-sync with duty state',
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await statusNotifier.syncWithDuty();
                ref.read(manualOverrideProvider.notifier).state = false;
              },
              icon: const Icon(Icons.sync),
              label: const Text('Resume Auto-Sync'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
