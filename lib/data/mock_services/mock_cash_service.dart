import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockCashServiceProvider = Provider<MockCashService>((ref) {
  return MockCashService();
});

class MockCashService {
  static double _currentBalance = 890.0;
  static const double _cashLimit = 10000.0;
  static double _openingBalance = 500.0;
  
  static final List<CashTransaction> _transactions = [
    CashTransaction(
      transactionId: 'tx_001',
      userId: 'user_001',
      transactionType: CashTransactionType.opening,
      amount: 500.0,
      runningBalance: 500.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      notes: 'Opening balance for the day',
    ),
    CashTransaction(
      transactionId: 'tx_002',
      userId: 'user_001',
      orderId: 'order_001',
      transactionType: CashTransactionType.collection,
      amount: 170.0,
      runningBalance: 670.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      notes: 'Cash collection from Order #RIO001',
    ),
    CashTransaction(
      transactionId: 'tx_003',
      userId: 'user_001',
      orderId: 'order_005',
      transactionType: CashTransactionType.collection,
      amount: 700.0,
      runningBalance: 1370.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'Cash collection from Order #RIO005',
    ),
    CashTransaction(
      transactionId: 'tx_004',
      userId: 'user_001',
      transactionType: CashTransactionType.deposit,
      amount: -800.0,
      runningBalance: 570.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Cash deposit at collection center',
    ),
    CashTransaction(
      transactionId: 'tx_005',
      userId: 'user_001',
      orderId: 'order_007',
      transactionType: CashTransactionType.collection,
      amount: 320.0,
      runningBalance: 890.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      notes: 'Cash collection from Order #RIO007',
    ),
  ];

  double getCurrentBalance() => _currentBalance;
  
  double getCashLimit() => _cashLimit;
  
  List<CashTransaction> getTransactionHistory() => List.from(_transactions);

  bool collectCash(String orderId, double amount) {
    final transaction = CashTransaction(
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      orderId: orderId,
      transactionType: CashTransactionType.collection,
      amount: amount,
      runningBalance: _currentBalance + amount,
      timestamp: DateTime.now(),
      notes: 'Cash collection from Order #$orderId',
    );
    
    _transactions.add(transaction);
    _currentBalance += amount;
    return true;
  }

  bool depositCash(double amount, String? receiptNumber) {
    final transaction = CashTransaction(
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      transactionType: CashTransactionType.deposit,
      amount: -amount,
      runningBalance: _currentBalance - amount,
      timestamp: DateTime.now(),
      notes: 'Cash deposit${receiptNumber != null ? ' - Receipt: $receiptNumber' : ''}',
    );
    
    _transactions.add(transaction);
    _currentBalance -= amount;
    return true;
  }

  bool declareOpeningBalance(double balance) {
    _openingBalance = balance;
    _currentBalance = balance;
    
    final transaction = CashTransaction(
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      transactionType: CashTransactionType.opening,
      amount: balance,
      runningBalance: balance,
      timestamp: DateTime.now(),
      notes: 'Opening balance declared',
    );
    
    _transactions.insert(0, transaction);
    return true;
  }

  bool deductPenalty(double amount, String reason) {
    final transaction = CashTransaction(
      transactionId: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      transactionType: CashTransactionType.penalty,
      amount: -amount,
      runningBalance: _currentBalance - amount,
      timestamp: DateTime.now(),
      notes: 'Penalty: $reason',
    );
    
    _transactions.add(transaction);
    _currentBalance -= amount;
    return true;
  }

  DayReconciliation getDayReconciliation() {
    final todayTransactions = _transactions.where((tx) =>
      tx.timestamp.day == DateTime.now().day &&
      tx.timestamp.month == DateTime.now().month &&
      tx.timestamp.year == DateTime.now().year
    ).toList();

    double totalCollections = todayTransactions
        .where((tx) => tx.transactionType == CashTransactionType.collection)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    double totalDeposits = todayTransactions
        .where((tx) => tx.transactionType == CashTransactionType.deposit)
        .fold(0.0, (sum, tx) => sum + tx.amount.abs());

    double totalPenalties = todayTransactions
        .where((tx) => tx.transactionType == CashTransactionType.penalty)
        .fold(0.0, (sum, tx) => sum + tx.amount.abs());

    double expectedBalance = _openingBalance + totalCollections - totalDeposits - totalPenalties;
    double variance = _currentBalance - expectedBalance;

    return DayReconciliation(
      date: DateTime.now(),
      openingBalance: _openingBalance,
      totalCollections: totalCollections,
      totalDeposits: totalDeposits,
      totalPenalties: totalPenalties,
      expectedBalance: expectedBalance,
      actualBalance: _currentBalance,
      variance: variance,
    );
  }

  bool performReconciliation() {
    // In a real app, this would sync with backend and reset for next day
    return true;
  }

  bool isCashLimitReached() {
    return _currentBalance >= _cashLimit * 0.8; // 80% of limit
  }
}

class CashTransaction {
  final String transactionId;
  final String userId;
  final String? orderId;
  final CashTransactionType transactionType;
  final double amount;
  final double runningBalance;
  final DateTime timestamp;
  final String? reconciliationId;
  final String? notes;

  CashTransaction({
    required this.transactionId,
    required this.userId,
    this.orderId,
    required this.transactionType,
    required this.amount,
    required this.runningBalance,
    required this.timestamp,
    this.reconciliationId,
    this.notes,
  });

  CashTransactionType get type => transactionType;
}

enum CashTransactionType {
  collection,
  deposit,
  penalty,
  opening,
}

class DayReconciliation {
  final DateTime date;
  final double openingBalance;
  final double totalCollections;
  final double totalDeposits;
  final double totalPenalties;
  final double expectedBalance;
  final double actualBalance;
  final double variance;

  DayReconciliation({
    required this.date,
    required this.openingBalance,
    required this.totalCollections,
    required this.totalDeposits,
    required this.totalPenalties,
    required this.expectedBalance,
    required this.actualBalance,
    required this.variance,
  });
}
