// lib/features/history/history_screen.dart
import 'package:flutter/material.dart';
import '../../data/repositories/data_store.dart';
import '../../shared/utils/formatting.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DataStore().addListener(_onDataChange);
  }

  @override
  void dispose() {
    DataStore().removeListener(_onDataChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onDataChange() {
    if (mounted) setState(() {});
  }

  String _formatDateManual(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}";
  }

  // === HELPERS ===
  DateTime _parseDate(dynamic dateVal) {
    if (dateVal == null) return DateTime.now();
    if (dateVal is DateTime) return dateVal;
    return DateTime.tryParse(dateVal.toString()) ?? DateTime.now();
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // === ACTIONS ===
  void _handleRefund(Map<String, dynamic> item) {
    int totalQty = int.tryParse(item['qty']?.toString() ?? "1") ?? 1;
    int refundQty = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Process Refund"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How many items do you want to refund?"),
              const SizedBox(height: 20),
              if (totalQty > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: refundQty > 1 ? () => setDialogState(() => refundQty--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("$refundQty", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: refundQty < totalQty ? () => setDialogState(() => refundQty++) : null,
                    ),
                  ],
                )
              else
                const Text("1 Item (Full Refund)", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                DataStore().refundSale(item, refundQty: refundQty);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Refund of $refundQty item(s) processed! ✅")),
                );
              },
              child: const Text("CONFIRM REFUND"),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record?"),
        content: const Text("Are you sure? This will remove the record permanently but will NOT restore stock."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Keep")),
          TextButton(
            onPressed: () {
              DataStore().deleteHistoryItem(id);
              Navigator.pop(ctx);
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleEdit(Map<String, dynamic> item) {
    final nameCtrl = TextEditingController(text: item['name'] ?? item['item'] ?? "");
    final priceCtrl = TextEditingController(text: item['price']?.toString() ?? "0");
    final qtyCtrl = TextEditingController(text: (item['qty'] ?? 1).toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Sale Record"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Item Name")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Sale Price"), keyboardType: TextInputType.number),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              DataStore().updateHistoryItem(item, {
                'name': nameCtrl.text,
                'price': priceCtrl.text,
                'qty': qtyCtrl.text,
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = DataStore().historyItems;
    
    // Filter logic
    final filteredHistory = allHistory.where((item) {
      final itemDate = _parseDate(item['date']);
      final matchesDate = _isSameDay(itemDate, _selectedDate);
      
      final name = (item['name'] ?? item['item'] ?? "").toString().toLowerCase();
      final status = (item['status'] ?? "").toString().toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || 
                            status.contains(_searchQuery.toLowerCase());
      
      return matchesDate && matchesSearch;
    }).toList();

    // Summary calculations
    double dayTotal = 0;
    double dayProfit = 0;
    for (var item in filteredHistory) {
      if (item['status'] != "Refunded") {
        double p = Formatter.parseDouble(item['price'].toString());
        int q = int.tryParse(item['qty']?.toString() ?? "1") ?? 1;
        dayTotal += (p * q);
        dayProfit += Formatter.parseDouble(item['profit']?.toString() ?? "0");
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // 1. Sleek App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.red[700],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[800]!, Colors.red[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sales History",
                        style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Rs ${Formatter.formatCurrency(dayTotal)}",
                                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                "Profit: Rs ${Formatter.formatCurrency(dayProfit)}",
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2022),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.calendar_month, color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                _formatDateManual(_selectedDate),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              centerTitle: false,
            ),
          ),

          // 2. Search & Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Search items or status...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),

          // 3. History List
          filteredHistory.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("No sales records found", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredHistory[index];
                        return _HistoryItemCard(
                          item: item,
                          onRefund: () => _handleRefund(item),
                          onDelete: () => _handleDelete(item['id']),
                          onEdit: () => _handleEdit(item),
                        );
                      },
                      childCount: filteredHistory.length,
                    ),
                  ),
                ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRefund;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _HistoryItemCard({
    required this.item,
    required this.onRefund,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    bool isRefunded = item['status'] == "Refunded";
    double price = Formatter.parseDouble(item['price'].toString());
    int qty = int.tryParse(item['qty']?.toString() ?? "1") ?? 1;
    double total = price * qty;
    double profit = Formatter.parseDouble(item['profit']?.toString() ?? "0");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRefunded ? Colors.red[50] : Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRefunded ? Icons.keyboard_return : Icons.shopping_bag_outlined,
                color: isRefunded ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    item['name'] ?? item['item'] ?? "Unknown",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: isRefunded ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (isRefunded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                    child: const Text("REFUNDED", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            subtitle: Text(
              "$qty x Rs ${Formatter.formatCurrency(price)}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rs ${Formatter.formatCurrency(total)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isRefunded ? Colors.red : Colors.black,
                  ),
                ),
                if (!isRefunded)
                  Text(
                    profit >= 0 ? "+Rs ${Formatter.formatCurrency(profit)}" : "-Rs ${Formatter.formatCurrency(profit.abs())}",
                    style: TextStyle(color: profit >= 0 ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            children: [
              const Divider(height: 1, indent: 20, endIndent: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (!isRefunded)
                      _ActionButton(
                        icon: Icons.settings_backup_restore,
                        label: "REFUND",
                        color: Colors.orange,
                        onTap: onRefund,
                      ),
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      label: "EDIT",
                      color: Colors.blue,
                      onTap: onEdit,
                    ),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: "DELETE",
                      color: Colors.red,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
