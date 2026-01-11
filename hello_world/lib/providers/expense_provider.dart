import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:rsellx/data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  // Stream subscription for proper cleanup
  StreamSubscription? _expensesBoxSubscription;
  
  ExpenseProvider() {
    _initializeListener();
  }
  
  void _initializeListener() {
    try {
      // Ensure box is open before watching
      if (Hive.isBoxOpen('expensesBox')) {
        _expensesBoxSubscription = _expensesBox.watch().listen((_) {
          notifyListeners();
        }, onError: (error) {
          // Handle stream errors gracefully
          debugPrint('ExpenseProvider stream error: $error');
        });
      }
    } catch (e) {
      debugPrint('ExpenseProvider initialization error: $e');
    }
  }
  
  @override
  void dispose() {
    _expensesBoxSubscription?.cancel();
    super.dispose();
  }

  Box<ExpenseItem> get _expensesBox => Hive.box<ExpenseItem>('expensesBox');

  List<ExpenseItem> get _allExpenses => _expensesBox.values.toList();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<ExpenseItem> get todayExpenses => _allExpenses
      .where((e) => _isSameDay(DateTime.now(), e.date))
      .toList();

  List<ExpenseItem> get yesterdayExpenses => _allExpenses
      .where(
        (e) => _isSameDay(
          DateTime.now().subtract(const Duration(days: 1)),
          e.date,
        ),
      )
      .toList();

  List<ExpenseItem> getExpensesForDate(DateTime date) {
    return _allExpenses.where((e) => _isSameDay(date, e.date)).toList();
  }

  void addExpense(ExpenseItem expense) {
    _expensesBox.put(expense.id, expense);
  }

  void updateExpense(ExpenseItem expense) {
    expense.save();
  }

  void deleteExpense(String id) {
    _expensesBox.delete(id);
  }

  double getTotalExpenses() {
    // Return only today's total - combining today + yesterday doesn't make sense semantically
    return todayExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }
  
  // If you need combined total, use this explicit method
  double getTotalExpensesForTodayAndYesterday() {
    return todayExpenses.fold(0.0, (sum, item) => sum + item.amount) +
        yesterdayExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double getTotalExpensesForDate(DateTime date) {
    var list = _allExpenses.where((e) => _isSameDay(date, e.date)).toList();
    return list.fold(0.0, (sum, item) => sum + item.amount);
  }

  List<ExpenseItem> getExpensesForWeek(DateTime date) {
    // Week start logic (Monday to Sunday)
    DateTime startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return _allExpenses.where((e) => 
      e.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) && 
      e.date.isBefore(endOfWeek.add(const Duration(seconds: 1)))
    ).toList();
  }

  double getTotalExpensesForWeek(DateTime date) {
    var list = getExpensesForWeek(date);
    return list.fold(0.0, (sum, item) => sum + item.amount);
  }

  List<ExpenseItem> getExpensesForYear(DateTime date) {
    return _allExpenses.where((e) => e.date.year == date.year).toList();
  }

  double getTotalExpensesForYear(DateTime date) {
    var list = getExpensesForYear(date);
    return list.fold(0.0, (sum, item) => sum + item.amount);
  }

  List<ExpenseItem> getExpensesForMonth(DateTime date) {
    return _allExpenses.where((e) => e.date.month == date.month && e.date.year == date.year).toList();
  }

  double getTotalExpensesForMonth(DateTime date) {
    var list = getExpensesForMonth(date);
    return list.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> clearAllData() async {
    await _expensesBox.clear();
  }
}
