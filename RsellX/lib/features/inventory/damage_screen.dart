import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/inventory_provider.dart';
import '../../data/models/damage_model.dart';
import '../../data/models/inventory_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/full_scanner_screen.dart';
import '../../core/utils/id_generator.dart';
import '../../core/utils/image_path_helper.dart';
import '../../core/utils/fuzzy_search.dart';
import '../../shared/utils/formatting.dart';

class DamageScreen extends StatelessWidget {
  const DamageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final history = provider.damageHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Damage Tracking", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Total Loss Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0x4DF44336), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              children: [
                const Icon(Icons.broken_image_outlined, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total Damage Loss", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      "Rs ${provider.getTotalDamageLoss().toInt()}",
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent Damage Records", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_shopping_cart_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("No damage records found", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      // Find item image from inventory if possible
                      String? imagePath;
                      try {
                        final item = provider.inventory.firstWhere((e) => e.id == record.itemId);
                        imagePath = item.imagePath;
                      } catch (_) {}
                      
                      return _buildHistoryCard(context, record, imagePath);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDamageSheet(context),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("RECORD DAMAGE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, DamageRecord record, String? imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showEditDamageSheet(context, record),
        onLongPress: () => _showEditDamageSheet(context, record),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image / Icon
              GestureDetector(
                onTap: imagePath != null && ImagePathHelper.exists(imagePath)
                    ? () => _showImagePreview(context, imagePath, record.itemName)
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 55,
                    height: 55,
                    color: Colors.red.withOpacity(0.05),
                    child: imagePath != null && ImagePathHelper.exists(imagePath)
                        ? Image.file(ImagePathHelper.getFile(imagePath), fit: BoxFit.cover)
                        : const Icon(Icons.broken_image_outlined, color: Colors.redAccent, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Record Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              record.reason,
                              style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM hh:mm a').format(record.date),
                          style: TextStyle(color: Colors.grey[400], fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Loss / Quantity
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "-${record.qty} Pcs",
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    "Rs ${Formatter.formatCurrency(record.lossAmount)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDamageSheet(BuildContext context) {
    _showDamageForm(context, null);
  }

  void _showEditDamageSheet(BuildContext context, DamageRecord record) {
    _showDamageForm(context, record);
  }

  void _showDamageForm(BuildContext context, DamageRecord? editRecord) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DamageFormSheet(editRecord: editRecord),
    );
  }

  void _showImagePreview(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.file(
                    ImagePathHelper.getFile(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class DamageFormSheet extends StatefulWidget {
  final DamageRecord? editRecord;
  const DamageFormSheet({super.key, this.editRecord});

  @override
  State<DamageFormSheet> createState() => _DamageFormSheetState();
}

class _DamageFormSheetState extends State<DamageFormSheet> {
  InventoryItem? selectedItem;
  final TextEditingController qtyCtrl = TextEditingController();
  final TextEditingController reasonCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();
  List<InventoryItem> filteredItems = [];
  String? _selectedCategory;
  String? _selectedSubCategory;

  void _applyFilter(String val) {
    setState(() {
      final query = val.toLowerCase().trim();
      final provider = context.read<InventoryProvider>();
      final allItems = provider.inventory;

      if (query.isEmpty && _selectedCategory == null && _selectedSubCategory == null) {
        filteredItems = [];
        return;
      }

      // HYPER-SMART SEARCH SCORING + Manual Filters
      final scored = allItems.map((item) {
        int score = 0;
        final name = item.name.toLowerCase();
        final barcode = item.barcode.toLowerCase();
        final category = item.category.toLowerCase();
        final subCategory = item.subCategory.toLowerCase();

        // Check Hard Filters First
        if (_selectedCategory != null && category != _selectedCategory!.toLowerCase()) return {'item': item, 'score': -1};
        if (_selectedSubCategory != null && subCategory != _selectedSubCategory!.toLowerCase()) return {'item': item, 'score': -1};

        if (query.isEmpty) {
          score = 1; // Show all for category filter if search is empty
        } else {
          if (name == query || barcode == query) score += 100;
          else if (name.startsWith(query) || barcode.startsWith(query)) score += 60;
          else if (name.contains(query)) score += 40;
          else if (barcode.contains(query)) score += 35;
          else if (category.contains(query) || subCategory.contains(query)) score += 30;

          if (query.length >= 3 && score < 40) {
            double nameSim = FuzzySearch.similarity(name, query);
            if (nameSim > 0.6) score += (nameSim * 45).toInt();
          }
        }
        return {'item': item, 'score': score};
      }).where((e) => (e['score'] as int) > 0).toList();

      scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
      filteredItems = scored.map((e) => e['item'] as InventoryItem).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    final provider = context.read<InventoryProvider>();
    if (widget.editRecord != null) {
      qtyCtrl.text = widget.editRecord!.qty.toString();
      reasonCtrl.text = widget.editRecord!.reason;
      try {
        selectedItem = provider.inventory.firstWhere((e) => e.id == widget.editRecord!.itemId);
      } catch (_) {}
    }
  }

  void _scanBarcode() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const FullScannerScreen(title: "Scan Product")),
    );

    if (barcode != null) {
      final provider = context.read<InventoryProvider>();
      final item = provider.findItemByBarcode(barcode);
      if (item != null) {
        setState(() {
          selectedItem = item;
          searchCtrl.clear();
          filteredItems.clear();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item not found"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final allItems = provider.inventory;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.editRecord == null ? "Record New Damage" : "Edit Damage Record", style: AppTextStyles.h2),
                if (widget.editRecord != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      provider.deleteDamageRecord(widget.editRecord!);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Selection Section
            const Text("Step 1: Select Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            if (selectedItem != null)
              _buildSelectedProductCard()
            else ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Search product...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchCtrl.text.isNotEmpty || _selectedCategory != null || _selectedSubCategory != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    searchCtrl.clear();
                                    _selectedCategory = null;
                                    _selectedSubCategory = null;
                                    filteredItems = [];
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: _applyFilter,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _scanBarcode,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                    ),
                  ),
                ],
              ),
              // Filter Chips
              if (_selectedCategory != null || _selectedSubCategory != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      if (_selectedCategory != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InputChip(
                            label: Text(_selectedCategory!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)),
                            backgroundColor: Colors.purple,
                            onDeleted: () {
                              setState(() => _selectedCategory = null);
                              _applyFilter(searchCtrl.text);
                            },
                            deleteIcon: const Icon(Icons.close, size: 12, color: Colors.white),
                            avatar: const Icon(Icons.category, size: 12, color: Colors.white),
                          ),
                        ),
                      if (_selectedSubCategory != null)
                        InputChip(
                          label: Text(_selectedSubCategory!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 10)),
                          backgroundColor: Colors.indigo,
                          onDeleted: () {
                            setState(() => _selectedSubCategory = null);
                            _applyFilter(searchCtrl.text);
                          },
                          deleteIcon: const Icon(Icons.close, size: 12, color: Colors.white),
                          avatar: const Icon(Icons.account_tree, size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              if (filteredItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredItems.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return _buildSearchItem(item);
                    },
                  ),
                ),
            ],

            const SizedBox(height: 24),
            const Text("Step 2: Damage Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    decoration: InputDecoration(
                      labelText: "Quantity",
                      prefixIcon: const Icon(Icons.numbers),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: reasonCtrl,
                    decoration: InputDecoration(
                      labelText: "Reason",
                      hintText: "e.g. Broken",
                      prefixIcon: const Icon(Icons.comment_outlined),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (selectedItem == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a product")));
                    return;
                  }
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  if (qty <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid quantity")));
                    return;
                  }

                  if (widget.editRecord == null) {
                    // Create New
                    final record = DamageRecord(
                      id: IdGenerator.generateId("DMG"),
                      itemId: selectedItem!.id,
                      itemName: selectedItem!.name,
                      qty: qty,
                      lossAmount: selectedItem!.price * qty,
                      date: DateTime.now(),
                      reason: reasonCtrl.text.isEmpty ? "Broken" : reasonCtrl.text,
                    );
                    provider.addDamageRecord(record);
                  } else {
                    // Update Existing
                    final newRecord = DamageRecord(
                      id: widget.editRecord!.id,
                      itemId: selectedItem!.id,
                      itemName: selectedItem!.name,
                      qty: qty,
                      lossAmount: selectedItem!.price * qty,
                      date: widget.editRecord!.date,
                      reason: reasonCtrl.text.isEmpty ? "Broken" : reasonCtrl.text,
                    );
                    provider.updateDamageRecord(widget.editRecord!, newRecord);
                  }

                  Navigator.pop(context);
                },
                child: Text(
                  widget.editRecord == null ? "SAVE RECORD" : "UPDATE RECORD",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchItem(InventoryItem item) {
    bool lowStock = item.stock < item.lowStockThreshold;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() {
          selectedItem = item;
          searchCtrl.clear();
          filteredItems = [];
        }),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              GestureDetector(
                onTap: item.imagePath != null && ImagePathHelper.exists(item.imagePath!)
                    ? () => _showImagePreview(item.imagePath!, item.name)
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 55,
                    height: 55,
                    color: Colors.grey[100],
                    child: item.imagePath != null && ImagePathHelper.exists(item.imagePath!)
                        ? Image.file(ImagePathHelper.getFile(item.imagePath!), fit: BoxFit.cover)
                        : const Icon(Icons.inventory_2_rounded, color: Colors.grey, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Rs ${Formatter.formatCurrency(item.price)}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        if (item.barcode != "N/A") ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "• ${item.barcode}",
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (item.category != "General") _Tag(label: item.category, color: Colors.purple, icon: Icons.category, onTap: () {
                          setState(() => _selectedCategory = item.category);
                          _applyFilter(searchCtrl.text);
                        }),
                        if (item.subCategory != "N/A") _Tag(label: item.subCategory, color: Colors.indigo, icon: Icons.account_tree, onTap: () {
                          setState(() => _selectedSubCategory = item.subCategory);
                          _applyFilter(searchCtrl.text);
                        }),
                        if (item.size != "N/A") _Tag(label: item.size, color: Colors.orange, icon: Icons.straighten),
                        if (item.weight != "N/A") _Tag(label: item.weight, color: Colors.teal, icon: Icons.scale),
                        if (item.color != "N/A") _Tag(label: item.color, color: Colors.pink, icon: Icons.color_lens_outlined),
                        if (item.brand != "N/A") _Tag(label: item.brand, color: Colors.deepPurple, icon: Icons.branding_watermark_outlined),
                        if (item.itemType != "N/A") _Tag(label: item.itemType, color: Colors.brown, icon: Icons.style_outlined),
                        if (item.unit != "Piece") _Tag(label: item.unit, color: Colors.cyan, icon: Icons.straighten),
                      ],
                    ),
                  ],
                ),
              ),
              // Stock Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: lowStock ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${item.stock}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: lowStock ? Colors.red : Colors.green,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Stock",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: lowStock ? Colors.red : Colors.green,
                      ),
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

  Widget _buildSelectedProductCard() {
    if (selectedItem == null) return const SizedBox.shrink();
    final item = selectedItem!;
    bool lowStock = item.stock < item.lowStockThreshold;

    return Card(
      elevation: 2,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            GestureDetector(
              onTap: item.imagePath != null && ImagePathHelper.exists(item.imagePath!)
                  ? () => _showImagePreview(item.imagePath!, item.name)
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[100],
                  child: item.imagePath != null && ImagePathHelper.exists(item.imagePath!)
                      ? Image.file(ImagePathHelper.getFile(item.imagePath!), fit: BoxFit.cover)
                      : const Icon(Icons.inventory_2_rounded, color: Colors.grey, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Rs ${Formatter.formatCurrency(item.price)}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (item.barcode != "N/A") ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "• ${item.barcode}",
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (item.category != "General") _Tag(label: item.category, color: Colors.purple, icon: Icons.category),
                      if (item.subCategory != "N/A") _Tag(label: item.subCategory, color: Colors.indigo, icon: Icons.account_tree),
                      if (item.size != "N/A") _Tag(label: item.size, color: Colors.orange, icon: Icons.straighten),
                      if (item.weight != "N/A") _Tag(label: item.weight, color: Colors.teal, icon: Icons.scale),
                      if (item.color != "N/A") _Tag(label: item.color, color: Colors.pink, icon: Icons.color_lens_outlined),
                      if (item.brand != "N/A") _Tag(label: item.brand, color: Colors.deepPurple, icon: Icons.branding_watermark_outlined),
                      if (item.itemType != "N/A") _Tag(label: item.itemType, color: Colors.brown, icon: Icons.style_outlined),
                      if (item.unit != "Piece") _Tag(label: item.unit, color: Colors.cyan, icon: Icons.straighten),
                    ],
                  ),
                ],
              ),
            ),
            // STOCK + REMOVE Button
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: lowStock ? Colors.red.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${item.stock}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: lowStock ? Colors.red : Colors.green, fontSize: 16),
                      ),
                      Text("Stock", style: TextStyle(fontSize: 8, color: lowStock ? Colors.red : Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => selectedItem = null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String imagePath, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.file(
                    ImagePathHelper.getFile(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const _Tag({required this.label, required this.color, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
