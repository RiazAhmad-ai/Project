// lib/features/inventory/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/models/inventory_model.dart';
import 'add_item_sheet.dart';
import 'sell_item_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // === 1. ADD ITEM (Open Sheet) ===
  void _addNewItemWithBarcode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => const AddItemSheet(),
    );
  }

  // === 2. BARCODE SEARCH & SELL ===
  Future<void> _scanForSearch() async {
    final String? barcode = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Scan Product Barcode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      Navigator.pop(context, barcodes.first.rawValue);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (barcode == null) return;

    // Search for match in inventory
    final box = Hive.box<InventoryItem>('inventoryBox');
    try {
      final match = box.values.firstWhere((item) => item.barcode == barcode);
      
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) => SellItemSheet(item: match),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Item not found with code: $barcode"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // === 3. DELETE ITEM ===
  void _deleteItem(InventoryItem item) {
    item.delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Deleted")));
  }

  // === 4. EDIT ITEM SHEET ===
  void _showEditSheet(InventoryItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final stockCtrl = TextEditingController(text: item.stock.toString());
    final barcodeCtrl = TextEditingController(text: item.barcode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("EDIT ITEM", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: "Barcode")),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Stock"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (barcodeCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barcode is required!")));
                        return;
                      }
                      item.name = nameCtrl.text;
                      item.price = double.tryParse(priceCtrl.text) ?? item.price;
                      item.stock = int.tryParse(stockCtrl.text) ?? item.stock;
                      item.barcode = barcodeCtrl.text.trim();
                      item.save();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: const Text("UPDATE"),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Item?"),
                        content: const Text("This action cannot be undone."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              _deleteItem(item);
                            },
                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Stock Inventory", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.add, color: Colors.white)),
            onPressed: _addNewItemWithBarcode,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // BARCODE SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search by Name or Code...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _scanForSearch,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ITEM LIST
          Expanded(
            child: ValueListenableBuilder<Box<InventoryItem>>(
              valueListenable: Hive.box<InventoryItem>('inventoryBox').listenable(),
              builder: (context, box, _) {
                final items = box.values.where((item) {
                  final query = _searchQuery.toLowerCase();
                  return item.name.toLowerCase().contains(query) || 
                         item.barcode.toLowerCase().contains(query);
                }).toList();

                if (items.isEmpty) {
                  return const Center(child: Text("No items found. Scan or Add new."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => _showEditSheet(item),
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Rs ${item.price.toStringAsFixed(0)} | Code: ${item.barcode}"),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.stock < 5 ? Colors.red[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${item.stock} Left",
                            style: TextStyle(color: item.stock < 5 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
