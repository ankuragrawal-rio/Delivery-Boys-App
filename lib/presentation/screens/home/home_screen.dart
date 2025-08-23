import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/duty_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/shift_model.dart';
import '../../../data/mock_services/mock_order_service.dart';
import '../../../data/mock_services/mock_earnings_service.dart';
import '../../../data/mock_services/mock_cash_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  int _notificationCount = 3; // Mock notification count

  final List<Widget> _screens = [
    const DashboardTab(),
    const OrdersTab(),
    const EarningsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rio Delivery'),
        actions: [
          // Notifications Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // TODO: Navigate to notifications screen
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Status Indicator
          Consumer(
            builder: (context, ref, child) {
              final dutyStatus = ref.watch(dutyStatusProvider);
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(dutyStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusText(dutyStatus),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? Consumer(
        builder: (context, ref, child) {
          final currentShift = ref.watch(currentShiftProvider);
          final isOnDuty = currentShift != null;
          
          return FloatingActionButton.extended(
            onPressed: () => _showDutyDialog(ref, isOnDuty),
            icon: Icon(isOnDuty ? Icons.work_off : Icons.work),
            label: Text(isOnDuty ? 'Clock Out' : 'Clock In'),
            backgroundColor: isOnDuty ? Colors.red : Colors.green,
          );
        },
      ) : null,
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.available:
        return Colors.green;
      case UserStatus.busy:
        return Colors.orange;
      case UserStatus.onBreak:
        return Colors.blue;
      case UserStatus.offline:
        return Colors.grey;
    }
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.available:
        return 'Available';
      case UserStatus.busy:
        return 'Busy';
      case UserStatus.onBreak:
        return 'On Break';
      case UserStatus.offline:
        return 'Offline';
    }
  }

  void _showDutyDialog(WidgetRef ref, bool isOnDuty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOnDuty ? 'Clock Out' : 'Clock In'),
        content: Text(
          isOnDuty 
            ? 'Are you sure you want to end your shift?'
            : 'Ready to start your shift?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                if (isOnDuty) {
                  await ref.read(currentShiftProvider.notifier).clockOut();
                  ref.read(dutyStatusProvider.notifier).state = UserStatus.offline;
                } else {
                  await ref.read(currentShiftProvider.notifier).clockIn();
                  ref.read(dutyStatusProvider.notifier).state = UserStatus.available;
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isOnDuty ? 'Shift ended successfully' : 'Shift started successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isOnDuty ? 'Clock Out' : 'Clock In'),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(WidgetRef ref) {
    final currentStatus = ref.read(dutyStatusProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserStatus.values.map((status) {
            return RadioListTile<UserStatus>(
              title: Text(_getStatusText(status)),
              value: status,
              groupValue: currentStatus,
              onChanged: (value) {
                ref.read(dutyStatusProvider.notifier).state = value!;
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentShift = ref.watch(currentShiftProvider);
    final dutyStatus = ref.watch(dutyStatusProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            _buildGreetingCard(currentShift, dutyStatus),
            
            const SizedBox(height: 16),
            
            // Today's Summary Card
            _buildTodaysSummaryCard(),
            
            const SizedBox(height: 16),
            
            // Duty Status Card
            if (currentShift != null) _buildDutyStatusCard(currentShift),
            
            const SizedBox(height: 16),
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  'Scan QR',
                  Icons.qr_code_scanner,
                  () => context.pushNamed('qr-scanner'),
                  Colors.blue,
                ),
                _buildActionCard(
                  'Cash Management',
                  Icons.account_balance_wallet,
                  () => context.pushNamed('cash-management'),
                  Colors.green,
                ),
                _buildActionCard(
                  'View Orders',
                  Icons.assignment,
                  () => context.pushNamed('orders'),
                  Colors.orange,
                ),
                _buildActionCard(
                  'Earnings',
                  Icons.trending_up,
                  () => context.pushNamed('earnings'),
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGreetingCard(ShiftModel? currentShift, UserStatus dutyStatus) {
    final now = DateTime.now();
    final timeOfDay = DateFormat('HH:mm').format(now);
    final greeting = _getGreeting();
    
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, Delivery Boy!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Current time: $timeOfDay',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  currentShift != null ? Icons.work : Icons.work_off,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  currentShift != null 
                    ? 'On Duty since ${DateFormat('HH:mm').format(currentShift.clockInTime)}'
                    : 'Not on duty',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTodaysSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Deliveries', '12', Icons.assignment, Colors.orange),
                _buildSummaryItem('Earnings', '₹850', Icons.currency_rupee, Colors.green),
                _buildSummaryItem('Cash', '₹2,400', Icons.account_balance_wallet, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDutyStatusCard(ShiftModel shift) {
    final workingDuration = shift.workingDuration;
    final hours = workingDuration.inHours;
    final minutes = workingDuration.inMinutes % 60;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Shift',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildShiftInfo(
                    'Clock In',
                    DateFormat('HH:mm').format(shift.clockInTime),
                    Icons.login,
                  ),
                ),
                Expanded(
                  child: _buildShiftInfo(
                    'Working Time',
                    '${hours}h ${minutes}m',
                    Icons.timer,
                  ),
                ),
                Expanded(
                  child: _buildShiftInfo(
                    'Breaks',
                    '${shift.breaks.length}',
                    Icons.coffee,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShiftInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Orders Screen - Coming Soon'),
    );
  }
}

class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Earnings Screen - Coming Soon'),
    );
  }
}

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Delivery Boy',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '+91 9876543210',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text('Documents'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          
          const Spacer(),
          
          ElevatedButton(
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
