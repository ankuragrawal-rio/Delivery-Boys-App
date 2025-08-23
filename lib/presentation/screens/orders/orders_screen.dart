import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order_model.dart';
import '../../../data/mock_services/mock_order_service.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ActiveOrdersTab(),
          _CompletedOrdersTab(),
          _AllOrdersTab(),
        ],
      ),
    );
  }
}

class _ActiveOrdersTab extends ConsumerWidget {
  const _ActiveOrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockOrderService = ref.watch(mockOrderServiceProvider);
    final activeOrders = mockOrderService.getActiveOrders();

    if (activeOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No active orders',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            Text(
              'New orders will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _CompletedOrdersTab extends ConsumerWidget {
  const _CompletedOrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockOrderService = ref.watch(mockOrderServiceProvider);
    final completedOrders = mockOrderService.getCompletedOrders();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedOrders.length,
      itemBuilder: (context, index) {
        final order = completedOrders[index];
        return _OrderCard(order: order, isCompleted: true);
      },
    );
  }
}

class _AllOrdersTab extends ConsumerWidget {
  const _AllOrdersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockOrderService = ref.watch(mockOrderServiceProvider);
    final allOrders = mockOrderService.getAllOrders();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        final order = allOrders[index];
        return _OrderCard(
          order: order,
          isCompleted: order.status == OrderStatus.completed,
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isCompleted;

  const _OrderCard({
    required this.order,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order.customerName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: order.paymentMethod == PaymentMethod.cash
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.paymentMethod == PaymentMethod.cash ? 'Cash' : 'Online',
                          style: TextStyle(
                            fontSize: 12,
                            color: order.paymentMethod == PaymentMethod.cash
                                ? Colors.orange
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isCompleted) _buildActionButtons(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.newOrder:
        color = Colors.blue;
        text = 'New';
        break;
      case OrderStatus.assigned:
        color = Colors.orange;
        text = 'Assigned';
        break;
      case OrderStatus.accepted:
        color = Colors.green;
        text = 'Accepted';
        break;
      case OrderStatus.pickupPending:
        color = Colors.purple;
        text = 'Pickup Pending';
        break;
      case OrderStatus.pickedUp:
        color = Colors.indigo;
        text = 'Picked Up';
        break;
      case OrderStatus.inTransit:
        color = Colors.teal;
        text = 'In Transit';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Delivered';
        break;
      case OrderStatus.completed:
        color = Colors.grey;
        text = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (order.status == OrderStatus.assigned) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => _rejectOrder(context),
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => _acceptOrder(context),
            child: const Text('Accept'),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showOrderDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OrderDetailsSheet(order: order),
    );
  }

  void _acceptOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order accepted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Order'),
        content: const Text('Please select a reason for rejecting this order:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Order rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailsSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Customer Info
          _buildSection(
            'Customer Information',
            [
              _buildDetailRow('Name', order.customerName),
              _buildDetailRow('Phone', order.customerPhone),
            ],
          ),
          
          // Delivery Address
          _buildSection(
            'Delivery Address',
            [
              _buildDetailRow('Address', order.deliveryAddress),
              if (order.specialInstructions != null)
                _buildDetailRow('Instructions', order.specialInstructions!),
            ],
          ),
          
          // Order Items
          _buildSection(
            'Order Items',
            order.orderItems.map((item) =>
              _buildDetailRow('${item.itemName} (${item.quantity}x)', '₹${item.price.toStringAsFixed(0)}')
            ).toList(),
          ),
          
          // Payment Info
          _buildSection(
            'Payment Information',
            [
              _buildDetailRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}'),
              _buildDetailRow('Payment Method', order.paymentMethod == PaymentMethod.cash ? 'Cash' : 'Online'),
              _buildDetailRow('Pickup Location', order.pickupLocationCode),
            ],
          ),
          
          const Spacer(),
          
          // Action Buttons
          if (order.status == OrderStatus.accepted)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to QR scanner
              },
              child: const Text('Start Pickup'),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
