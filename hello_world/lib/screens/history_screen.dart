import 'package:flutter/material.dart';
import '../data/data_store.dart';
import '../utils/formatting.dart'; // Formatter ke liye agar zaroorat ho

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 1. STATE VARIABLES
  DateTime _selectedDate = DateTime.now(); // By default Aaj ki date
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    DataStore().addListener(_onDataChange);
  }

  @override
  void dispose() {
    DataStore().removeListener(_onDataChange);
    super.dispose();
  }

  void _onDataChange() {
    if (mounted) setState(() {});
  }

  // === FUNCTIONS ===

  // Delete Function
  void _deleteItem(String id) {
    DataStore().deleteHistoryItem(id);
  }

  // Calendar Picker
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Helper to safely get Date Object
  DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    if (dateVal is DateTime) return dateVal;
    return DateTime.tryParse(dateVal.toString()) ?? DateTime.now();
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Edit Dialog
  void _showEditDialog(Map<String, dynamic> item) {
    TextEditingController priceController = TextEditingController(
      text: item['price']?.toString() ?? "0",
    );
    TextEditingController qtyController = TextEditingController(
      text: item['qty']?.toString() ?? "1",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Edit Sale Record",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity (Qty)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Price (Rs)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> updatedItem = Map.from(item);
              updatedItem['price'] = priceController.text;
              updatedItem['qty'] = qtyController.text;
              DataStore().updateHistoryItem(item['id'], updatedItem);

              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Record Updated!")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("UPDATE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // === UI BUILD ===
  @override
  Widget build(BuildContext context) {
    // 1. Logic to Filter List by Date AND Search Query
    final filteredList = DataStore().historyItems.where((item) {
      // Step A: Check Date
      DateTime itemDate = _parseDate(item['date']);
      bool dateMatches = _isSameDay(itemDate, _selectedDate);

      // Step B: Check Search Text
      final name = item['name'] ?? item['item'] ?? "";
      bool searchMatches = name.toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      // Dono conditions true honi chahiye
      return dateMatches && searchMatches;
    }).toList();

    // Formatting date for display
    String displayDate =
        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sales History",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              "Showing: $displayDate", // Batayega ke kis date ki history hai
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.red,
            ), // Red color highlight
            onPressed: _pickDate,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search item name...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List or Empty Message
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Iss date par koi history nahi hai.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedDate = DateTime.now(); // Reset to Today
                            });
                          },
                          child: const Text("Go to Today"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      // Date Header ki zaroorat nahi kyunki hum ek waqt mein ek hi din dikha rahe hain
                      return _buildHistoryCard(item, _selectedDate);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, DateTime dt) {
    bool isRefund = item['status'] == "Refunded";

    // === SAFE DATA EXTRACTION ===
    String itemName = item['name'] ?? item['item'] ?? "Unknown Item";
    String qty = item['qty']?.toString() ?? "1";
    String price = item['price']?.toString() ?? "0";
    String actualPrice = item['actualPrice']?.toString() ?? "0"; // New Logic
    String profit = item['profit']?.toString() ?? "0"; // New Logic

    // Time Formatting
    DateTime itemTime = _parseDate(item['date']);
    String timeStr =
        "${itemTime.hour}:${itemTime.minute.toString().padLeft(2, '0')}";

    return Dismissible(
      key: Key(item['id'] ?? DateTime.now().toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Delete Record?"),
            content: const Text(
              "Kya aap is sale record ko delete karna chahte hain?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  "DELETE",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _deleteItem(item['id']),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isRefund
              ? Border.all(color: Colors.red.withOpacity(0.3))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isRefund ? Colors.red[50] : Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRefund ? Icons.keyboard_return : Icons.check,
                      color: isRefund ? Colors.red : Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$qty x Items   •   $timeStr",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        // Agar profit data hai to wo bhi dikha dein (Optional)
                        if (double.tryParse(profit) != null &&
                            double.parse(profit) != 0)
                          Text(
                            "Profit: Rs $profit",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rs $price",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: isRefund ? Colors.red : Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    title: const Text("Edit Record"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _showEditDialog(item);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.keyboard_return,
                                      color: Colors.orange,
                                    ),
                                    title: const Text("Mark as Refund (Wapis)"),
                                    onTap: () {
                                      Map<String, dynamic> updatedItem =
                                          Map.from(item);
                                      updatedItem['status'] = "Refunded";
                                      DataStore().updateHistoryItem(
                                        item['id'],
                                        updatedItem,
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 8, left: 10, bottom: 5),
                          child: Icon(Icons.more_horiz, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isRefund)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "REFUND",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
