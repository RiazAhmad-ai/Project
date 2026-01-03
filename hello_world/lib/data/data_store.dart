import 'package:flutter/foundation.dart';
import '../utils/formatting.dart';

class DataStore extends ChangeNotifier {
  // Singleton
  static final DataStore _instance = DataStore._internal();
  factory DataStore() => _instance;
  DataStore._internal();

  // === INVENTORY DATA ===
  final List<Map<String, dynamic>> _inventory = [
    {"id": "1", "name": "Bone China Cup", "price": "450", "stock": "12"},
    {"id": "2", "name": "Water Glass Set", "price": "1,200", "stock": "5"},
    {"id": "3", "name": "Dinner Plate (L)", "price": "850", "stock": "24"},
    {"id": "4", "name": "Tea Spoon Set", "price": "350", "stock": "0"},
  ];

  List<Map<String, dynamic>> get inventory => List.unmodifiable(_inventory);

  void addInventoryItem(Map<String, dynamic> item) {
    _inventory.add(item);
    notifyListeners();
  }

  void updateInventoryItem(String id, Map<String, dynamic> newItem) {
    int index = _inventory.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      _inventory[index] = newItem;
      notifyListeners();
    }
  }

  void deleteInventoryItem(String id) {
    _inventory.removeWhere((element) => element['id'] == id);
    notifyListeners();
  }

  double getTotalStockValue() {
    double total = 0.0;
    for (var item in _inventory) {
      double price = Formatter.parseDouble(item['price'].toString());
      int stock = Formatter.parseInt(item['stock'].toString());
      total += (price * stock);
    }
    return total;
  }

  int getLowStockCount() {
    return _inventory.where((item) => Formatter.parseInt(item['stock'].toString()) < 5).length;
  }

  // === EXPENSE DATA ===
  final List<Map<String, String>> _todayExpenses = [
    {"id": "1", "title": "Staff Lunch", "category": "Food", "amount": "850"},
    {"id": "2", "title": "Rickshaw Fare", "category": "Travel", "amount": "200"},
    {"id": "5", "title": "Chai Pani", "category": "Food", "amount": "150"},
  ];

  final List<Map<String, String>> _yesterdayExpenses = [
    {"id": "3", "title": "Electricity Bill", "category": "Bills", "amount": "4,500"},
    {"id": "4", "title": "Shop Rent", "category": "Rent", "amount": "35,000"},
  ];

  List<Map<String, String>> get todayExpenses => List.unmodifiable(_todayExpenses);
  List<Map<String, String>> get yesterdayExpenses => List.unmodifiable(_yesterdayExpenses);

  void addExpense(Map<String, String> expense, {bool isToday = true}) {
    if (isToday) {
      _todayExpenses.add(expense);
    } else {
      _yesterdayExpenses.add(expense);
    }
    notifyListeners();
  }

  void updateExpense(String id, Map<String, String> newExpense, {bool isToday = true}) {
    var list = isToday ? _todayExpenses : _yesterdayExpenses;
    int index = list.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      list[index] = newExpense;
      notifyListeners();
    }
  }

  void deleteExpense(String id, {bool isToday = true}) {
    var list = isToday ? _todayExpenses : _yesterdayExpenses;
    list.removeWhere((element) => element['id'] == id);
    notifyListeners();
  }

  double getTotalExpenses() {
    double total = 0.0;
    for (var item in _todayExpenses) {
      total += Formatter.parseDouble(item['amount']!);
    }
    for (var item in _yesterdayExpenses) {
      total += Formatter.parseDouble(item['amount']!);
    }
    return total;
  }

  // === HISTORY DATA ===
  final List<Map<String, dynamic>> _historyItems = [
    {
      "id": "101",
      "item": "Bone China Cup Set",
      "qty": "2",
      "price": "4,500",
      "time": "10:30 AM",
      "date": "Today",
      "status": "Completed",
    },
    {
      "id": "102",
      "item": "Water Glass (6 Pcs)",
      "qty": "1",
      "price": "1,200",
      "time": "11:15 AM",
      "date": "Today",
      "status": "Completed",
    },
    {
      "id": "103",
      "item": "Tea Spoon Set",
      "qty": "3",
      "price": "850",
      "time": "04:45 PM",
      "date": "Yesterday",
      "status": "Refunded",
    },
    {
      "id": "104",
      "item": "Dinner Set (Large)",
      "qty": "1",
      "price": "12,000",
      "time": "06:00 PM",
      "date": "Yesterday",
      "status": "Completed",
    },
  ];

  List<Map<String, dynamic>> get historyItems => List.unmodifiable(_historyItems);

  void addHistoryItem(Map<String, dynamic> item) {
    _historyItems.insert(0, item); // Add to top
    notifyListeners();
  }

  void updateHistoryItem(String id, Map<String, dynamic> item) {
    int index = _historyItems.indexWhere((element) => element['id'] == id);
    if (index != -1) {
      _historyItems[index] = item;
      notifyListeners();
    }
  }

  void deleteHistoryItem(String id) {
    _historyItems.removeWhere((element) => element['id'] == id);
    notifyListeners();
  }

  double getTotalSales() {
    double total = 0.0;
     for (var item in _historyItems) {
      if (item['status'] != "Refunded") {
         total += Formatter.parseDouble(item['price'].toString());
      }
    }
    return total;
  }
}
