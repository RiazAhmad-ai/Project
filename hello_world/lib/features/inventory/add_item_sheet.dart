// lib/features/inventory/add_item_sheet.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/models/inventory_model.dart';
import '../../data/repositories/data_store.dart';

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: "1");
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  bool _isSaving = false;

  // === BARCODE SCANNER ===
  Future<void> _scanBarcode() async {
    final String? barcode = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Scan Barcode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

    if (barcode != null) {
      setState(() {
        _barcodeController.text = barcode;
      });
    }
  }

  Future<void> _saveItem() async {
    if (_barcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Barcode/Sticker Number is required!")));
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item Name is required!")));
      return;
    }
    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Price is required!")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final newItem = InventoryItem(
        id: timestamp,
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        description: _descController.text.isEmpty ? null : _descController.text,
        barcode: _barcodeController.text.trim(),
      );

      DataStore().addInventoryItem(newItem);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item Saved Successfully! ✅"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("ADD NEW STOCK", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Barcode Field with Scan Button
            const Text("Barcode / Sticker Number", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      hintText: "Enter Code",
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _scanBarcode,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text("Item Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Item Name",
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Cost Price",
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Stock Qty",
                      prefixIcon: const Icon(Icons.numbers),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: "Description (Optional)",
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SAVE ITEM",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
