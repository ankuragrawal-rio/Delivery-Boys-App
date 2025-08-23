import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockEarningsServiceProvider = Provider<MockEarningsService>((ref) {
  return MockEarningsService();
});

class MockEarningsService {
  DailyEarnings getTodayEarnings() {
    return DailyEarnings(
      date: DateTime.now(),
      basePay: 400.0,
      incentives: 390.0,
      penalties: 40.0,
      totalEarnings: 750.0,
      totalOrders: 12,
      onTimeDeliveryRate: 92.0,
      averageRating: 4.8,
    );
  }

  WeeklyEarnings getWeeklyEarnings() {
    return WeeklyEarnings(
      weekStart: DateTime.now().subtract(const Duration(days: 6)),
      weekEnd: DateTime.now(),
      totalEarnings: 4250.0,
      averageDaily: 607.0,
      totalOrders: 84,
      dailyEarnings: [
        DailyEarnings(
          date: DateTime.now().subtract(const Duration(days: 6)),
          basePay: 400.0,
          incentives: 200.0,
          penalties: 0.0,
          totalEarnings: 600.0,
          totalOrders: 10,
          onTimeDeliveryRate: 100.0,
          averageRating: 4.9,
        ),
        DailyEarnings(
          date: DateTime.now().subtract(const Duration(days: 5)),
          basePay: 400.0,
          incentives: 250.0,
          penalties: 20.0,
          totalEarnings: 630.0,
          totalOrders: 13,
          onTimeDeliveryRate: 85.0,
          averageRating: 4.7,
        ),
        // Add more daily earnings...
      ],
    );
  }

  MonthlyEarnings getMonthlyEarnings() {
    return MonthlyEarnings(
      month: DateTime.now().month,
      year: DateTime.now().year,
      totalEarnings: 18500.0,
      target: 20000.0,
      totalOrders: 350,
      averageDaily: 617.0,
      weeklyEarnings: [
        // Add weekly breakdowns...
      ],
    );
  }
}

class DailyEarnings {
  final DateTime date;
  final double basePay;
  final double incentives;
  final double penalties;
  final double totalEarnings;
  final int totalOrders;
  final double onTimeDeliveryRate;
  final double averageRating;

  DailyEarnings({
    required this.date,
    required this.basePay,
    required this.incentives,
    required this.penalties,
    required this.totalEarnings,
    required this.totalOrders,
    required this.onTimeDeliveryRate,
    required this.averageRating,
  });
}

class WeeklyEarnings {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double totalEarnings;
  final double averageDaily;
  final int totalOrders;
  final List<DailyEarnings> dailyEarnings;

  WeeklyEarnings({
    required this.weekStart,
    required this.weekEnd,
    required this.totalEarnings,
    required this.averageDaily,
    required this.totalOrders,
    required this.dailyEarnings,
  });
}

class MonthlyEarnings {
  final int month;
  final int year;
  final double totalEarnings;
  final double target;
  final int totalOrders;
  final double averageDaily;
  final List<WeeklyEarnings> weeklyEarnings;

  MonthlyEarnings({
    required this.month,
    required this.year,
    required this.totalEarnings,
    required this.target,
    required this.totalOrders,
    required this.averageDaily,
    required this.weeklyEarnings,
  });
}
