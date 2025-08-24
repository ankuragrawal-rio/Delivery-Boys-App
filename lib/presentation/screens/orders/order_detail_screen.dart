import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/order_model.dart';
import '../../../data/mock_services/mock_order_service.dart';
import '../../../core/services/availability_service.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.orderNumber}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Order Status Header
                  _buildStatusHeader(),
                  
                  // Customer Information
                  _buildCustomerSection(),
                  
                  // Pickup Location (Prominent)
                  _buildPickupLocationSection(),
                  
                  // Order Items
                  _buildOrderItemsSection(),
                  
                  // Special Instructions
                  if (widget.order.specialInstructions != null)
                    _buildSpecialInstructionsSection(),
                  
                  // Payment Information
                  _buildPaymentSection(),
                  
                  // Order Timeline
                  _buildTimelineSection(),
                  
                  // Delivery Information
                  _buildDeliverySection(),
                  
                  const SizedBox(height: 100), // Space for floating buttons
                ],
              ),
            ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.order.status).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor(widget.order.status).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(widget.order.status),
            size: 48,
            color: _getStatusColor(widget.order.status),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusText(widget.order.status),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(widget.order.status),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Created: ${_formatDateTime(widget.order.createdAt)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (widget.order.slaTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'SLA: ${_formatDateTime(widget.order.slaTime!)}',
              style: TextStyle(
                fontSize: 14,
                color: widget.order.slaTime!.isBefore(DateTime.now())
                    ? Colors.red
                    : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return _buildSection(
      title: 'Customer Information',
      icon: Icons.person,
      child: Column(
        children: [
          _buildInfoRow(
            'Name',
            widget.order.customerName,
            Icons.person_outline,
          ),
          _buildInfoRow(
            'Phone',
            _maskPhoneNumber(widget.order.customerPhone),
            Icons.phone_outlined,
            onTap: () => _callCustomer(),
          ),
          _buildInfoRow(
            'Delivery Address',
            widget.order.deliveryAddress,
            Icons.location_on_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupLocationSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PICKUP LOCATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.pickupLocationCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text(
                      'Scan QR code at this location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return _buildSection(
      title: 'Order Items (${widget.order.orderItems.length})',
      icon: Icons.shopping_bag,
      child: Column(
        children: widget.order.orderItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${item.quantity}x',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Item ID: ${item.itemId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${item.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpecialInstructionsSection() {
    return _buildSection(
      title: 'Special Instructions',
      icon: Icons.info_outline,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          widget.order.specialInstructions!,
          style: const TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      title: 'Payment Information',
      icon: Icons.payment,
      child: Column(
        children: [
          _buildInfoRow(
            'Total Amount',
            '₹${widget.order.totalAmount.toStringAsFixed(0)}',
            Icons.currency_rupee,
            valueColor: Colors.green,
            valueWeight: FontWeight.bold,
          ),
          _buildInfoRow(
            'Payment Method',
            widget.order.paymentMethod == PaymentMethod.cash ? 'Cash on Delivery' : 'Online Payment',
            widget.order.paymentMethod == PaymentMethod.cash ? Icons.money : Icons.credit_card,
          ),
          _buildInfoRow(
            'Payment Status',
            _getPaymentStatusText(widget.order.paymentStatus),
            Icons.check_circle_outline,
            valueColor: _getPaymentStatusColor(widget.order.paymentStatus),
          ),
          if (widget.order.deliveryOtp != null)
            _buildInfoRow(
              'Delivery OTP',
              widget.order.deliveryOtp!,
              Icons.lock_outline,
              valueWeight: FontWeight.bold,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return _buildSection(
      title: 'Order Timeline',
      icon: Icons.timeline,
      child: Column(
        children: widget.order.timeline.map((statusChange) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(statusChange.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStatusText(statusChange.status),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDateTime(statusChange.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (statusChange.notes != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          statusChange.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return _buildSection(
      title: 'Delivery Information',
      icon: Icons.local_shipping,
      child: Column(
        children: [
          if (widget.order.assignedTo != null)
            _buildInfoRow(
              'Assigned To',
              widget.order.assignedTo!,
              Icons.person_pin,
            ),
          if (widget.order.deliveredAt != null)
            _buildInfoRow(
              'Delivered At',
              _formatDateTime(widget.order.deliveredAt!),
              Icons.check_circle,
              valueColor: Colors.green,
            ),
          if (widget.order.deliveryProofUrl != null)
            _buildInfoRow(
              'Delivery Proof',
              'Photo Available',
              Icons.photo_camera,
              onTap: () => _viewDeliveryProof(),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Color? valueColor,
    FontWeight? valueWeight,
    int maxLines = 1,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: valueWeight ?? FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.order.status == OrderStatus.assigned) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _rejectOrder(),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text('Reject', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _acceptOrder(),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Accept Order', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _callCustomer(),
        icon: const Icon(Icons.phone, color: Colors.white),
        label: const Text('Call Customer', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  // Helper Methods
  String _maskPhoneNumber(String phone) {
    if (phone.length >= 10) {
      return '${phone.substring(0, 6)}****${phone.substring(phone.length - 1)}';
    }
    return phone;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.blue;
      case OrderStatus.assigned:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.green;
      case OrderStatus.pickupPending:
        return Colors.purple;
      case OrderStatus.pickedUp:
        return Colors.indigo;
      case OrderStatus.inTransit:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return Icons.fiber_new;
      case OrderStatus.assigned:
        return Icons.assignment;
      case OrderStatus.accepted:
        return Icons.check_circle;
      case OrderStatus.pickupPending:
        return Icons.pending_actions;
      case OrderStatus.pickedUp:
        return Icons.inventory;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.completed:
        return Icons.check_circle_outline;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return 'New Order';
      case OrderStatus.assigned:
        return 'Assigned';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.pickupPending:
        return 'Pickup Pending';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inTransit:
        return 'In Transit';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.cashCollected:
        return 'Cash Collected';
      case PaymentStatus.onlinePaid:
        return 'Online Paid';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.cashCollected:
        return Colors.green;
      case PaymentStatus.onlinePaid:
        return Colors.blue;
    }
  }

  // Action Methods
  Future<void> _acceptOrder() async {
    setState(() => _isLoading = true);
    
    try {
      final orderService = ref.read(mockOrderServiceProvider);
      final success = orderService.acceptOrder(widget.order.orderId);
      
      if (success) {
        // Update availability status to busy
        await ref.read(availabilityStatusProvider.notifier).onOrderAccepted();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order accepted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate order was accepted
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to accept order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectOrder() async {
    final reason = await _showRejectDialog();
    if (reason == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final orderService = ref.read(mockOrderServiceProvider);
      final success = orderService.rejectOrder(widget.order.orderId, reason);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate order was rejected
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to reject order'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showRejectDialog() async {
    return showDialog<String>(
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
            onPressed: () => Navigator.pop(context, 'Vehicle breakdown'),
            child: const Text('Vehicle Issue'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Too far from pickup location'),
            child: const Text('Too Far'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Already have too many orders'),
            child: const Text('Too Busy'),
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer() async {
    final phoneNumber = widget.order.customerPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot make phone calls on this device'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewDeliveryProof() {
    // In a real app, this would open the delivery proof image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery proof viewer not implemented'),
      ),
    );
  }
}
