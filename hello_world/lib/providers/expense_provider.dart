import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:rsellx/data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  // Stream subscription for proper cleanup
  StreamSubscription? _expensesBoxSubscription;
  
  ExpenseProvider() {
    _expensesBoxSubscription = _expensesBox.watch().listen((_) => notifyListeners());
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
    return todayExpenses.fold(0.0, (sum, item) => sum + item.amount) +
        yesterdayExpenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double getTotalExpensesForDate(DateTime date) {
    var list = _allExpenses.where((e) => _isSameDay(date, e.date)).toList();
    return list.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> clearAllData() async {
    await _expensesBox.clear();
  }
}
