import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/mock_services/mock_cash_service.dart';

class CashManagementScreen extends ConsumerStatefulWidget {
  const CashManagementScreen({super.key});

  @override
  ConsumerState<CashManagementScreen> createState() => _CashManagementScreenState();
}

class _CashManagementScreenState extends ConsumerState<CashManagementScreen>
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
        title: const Text('Cash Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Balance'),
            Tab(text: 'Transactions'),
            Tab(text: 'Reconcile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CashBalanceTab(),
          _TransactionsTab(),
          _ReconciliationTab(),
        ],
      ),
    );
  }
}

class _CashBalanceTab extends ConsumerWidget {
  const _CashBalanceTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashService = ref.watch(mockCashServiceProvider);
    final currentBalance = cashService.getCurrentBalance();
    final cashLimit = cashService.getCashLimit();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current Balance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Cash in Hand',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${currentBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: currentBalance / cashLimit,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentBalance / cashLimit > 0.8 ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Limit: ₹${cashLimit.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDepositDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Deposit Cash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeclareBalanceDialog(context, ref),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Declare Balance'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Today's Cash Flow
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Today\'s Cash Flow',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView(
              children: [
                _buildCashFlowItem('Opening Balance', 500.0, true),
                _buildCashFlowItem('Order #RIO001 - Cash Collected', 170.0, true),
                _buildCashFlowItem('Order #RIO005 - Cash Collected', 700.0, true),
                _buildCashFlowItem('Cash Deposit', -800.0, false),
                _buildCashFlowItem('Order #RIO007 - Cash Collected', 320.0, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowItem(String description, double amount, bool isIncome) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isIncome ? Icons.add_circle : Icons.remove_circle,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '₹${amount.abs().toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final receiptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deposit Cash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount to Deposit',
                prefixText: '₹',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: receiptController,
              decoration: const InputDecoration(
                labelText: 'Receipt Number (Optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                ref.read(mockCashServiceProvider).depositCash(amount, receiptController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cash deposited successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  void _showDeclareBalanceDialog(BuildContext context, WidgetRef ref) {
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Declare Opening Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your current cash in hand to start the day:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Opening Balance',
                prefixText: '₹',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final balance = double.tryParse(balanceController.text);
              if (balance != null && balance >= 0) {
                ref.read(mockCashServiceProvider).declareOpeningBalance(balance);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening balance declared'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Declare'),
          ),
        ],
      ),
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashService = ref.watch(mockCashServiceProvider);
    final transactions = cashService.getTransactionHistory();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _getTransactionIcon(transaction.type),
                  color: _getTransactionColor(transaction.type),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTransactionDescription(transaction),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDateTime(transaction.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${transaction.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getTransactionColor(transaction.type),
                      ),
                    ),
                    Text(
                      'Balance: ₹${transaction.runningBalance.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTransactionIcon(CashTransactionType type) {
    switch (type) {
      case CashTransactionType.collection:
        return Icons.add_circle;
      case CashTransactionType.deposit:
        return Icons.remove_circle;
      case CashTransactionType.penalty:
        return Icons.warning;
      case CashTransactionType.opening:
        return Icons.account_balance_wallet;
    }
  }

  Color _getTransactionColor(CashTransactionType type) {
    switch (type) {
      case CashTransactionType.collection:
        return Colors.green;
      case CashTransactionType.deposit:
        return Colors.blue;
      case CashTransactionType.penalty:
        return Colors.red;
      case CashTransactionType.opening:
        return Colors.orange;
    }
  }

  String _getTransactionDescription(CashTransaction transaction) {
    switch (transaction.type) {
      case CashTransactionType.collection:
        return 'Cash Collection - Order #${transaction.orderId ?? 'Unknown'}';
      case CashTransactionType.deposit:
        return 'Cash Deposit';
      case CashTransactionType.penalty:
        return 'Penalty Deduction';
      case CashTransactionType.opening:
        return 'Opening Balance';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _ReconciliationTab extends ConsumerWidget {
  const _ReconciliationTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashService = ref.watch(mockCashServiceProvider);
    final reconciliation = cashService.getDayReconciliation();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'End of Day Reconciliation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildReconciliationRow('Opening Balance', reconciliation.openingBalance),
                  _buildReconciliationRow('Total Collections', reconciliation.totalCollections),
                  _buildReconciliationRow('Total Deposits', reconciliation.totalDeposits),
                  _buildReconciliationRow('Penalties', reconciliation.totalPenalties),
                  const Divider(),
                  _buildReconciliationRow('Expected Balance', reconciliation.expectedBalance, isTotal: true),
                  _buildReconciliationRow('Actual Balance', reconciliation.actualBalance, isTotal: true),
                  const Divider(),
                  _buildReconciliationRow('Variance', reconciliation.variance, isVariance: true),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: reconciliation.variance == 0 ? () => _performReconciliation(context, ref) : null,
            child: const Text('Complete Reconciliation'),
          ),
          
          if (reconciliation.variance != 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Variance detected: ₹${reconciliation.variance.abs().toStringAsFixed(0)}. Please check your cash and deposits.',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReconciliationRow(String label, double amount, {bool isTotal = false, bool isVariance = false}) {
    Color textColor = Colors.black;
    if (isVariance && amount != 0) {
      textColor = amount > 0 ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _performReconciliation(BuildContext context, WidgetRef ref) {
    ref.read(mockCashServiceProvider).performReconciliation();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reconciliation completed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
