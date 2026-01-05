import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/full_scanner_screen.dart';
import '../../data/models/inventory_model.dart';
import '../../data/repositories/data_store.dart';
import '../../core/services/reporting_service.dart';
import 'add_item_sheet.dart';
import 'sell_item_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = "";
  
  int _currentPage = 1;
  static const int _pageSize = 20;
  bool _isLoadingMore = false;
  List<InventoryItem> _displayedItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
    // Listen to Hive box changes to refresh UI automatically
    Hive.box<InventoryItem>('inventoryBox').listenable().addListener(_onHiveBoxChanged);
  }

  void _onHiveBoxChanged() {
    if (mounted) {
      _loadInitialData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _loadInitialData() {
    final store = context.read<DataStore>();
    final allItems = store.inventory.where((item) {
      final query = _searchQuery.toLowerCase();
      // Simple fuzzy search (can be improved further)
      return item.name.toLowerCase().contains(query) || 
             item.barcode.toLowerCase().contains(query);
    }).toList();
    
    // Sort by name by default
    allItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _currentPage = 1;
      _displayedItems = allItems.take(_pageSize).toList();
    });
  }

  void _loadMoreData() {
    if (_isLoadingMore) return;
    
    final store = context.read<DataStore>();
    final allItems = store.inventory.where((item) {
      final query = _searchQuery.toLowerCase();
      return item.name.toLowerCase().contains(query) || 
             item.barcode.toLowerCase().contains(query);
    }).toList();
    
    allItems.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (_displayedItems.length >= allItems.length) return;

    setState(() => _isLoadingMore = true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      final nextItems = allItems.skip(_currentPage * _pageSize).take(_pageSize).toList();
      setState(() {
        _displayedItems.addAll(nextItems);
        _currentPage++;
        _isLoadingMore = false;
      });
    });
  }

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
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const FullScannerScreen(title: "Inventory Search"),
      ),
    );

    if (barcode == null) return;

    final store = context.read<DataStore>();
    try {
      final match = store.inventory.firstWhere((item) => item.barcode == barcode);
      
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item Deleted"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // === 4. EDIT ITEM SHEET ===
  void _showEditSheet(InventoryItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final stockCtrl = TextEditingController(text: item.stock.toString());
    final barcodeCtrl = TextEditingController(text: item.barcode);
    final thresholdCtrl = TextEditingController(text: item.lowStockThreshold.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("EDIT ITEM", style: AppTextStyles.h2),
            const SizedBox(height: 16),
            TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: "Barcode")),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            Row(
              children: [
                Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Stock"), keyboardType: TextInputType.number)),
              ],
            ),
            TextField(controller: thresholdCtrl, decoration: const InputDecoration(labelText: "Low Stock Alert Level"), keyboardType: TextInputType.number),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (barcodeCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Barcode is required!"), behavior: SnackBarBehavior.floating),
                        );
                        return;
                      }
                      item.name = nameCtrl.text;
                      item.price = double.tryParse(priceCtrl.text) ?? item.price;
                      item.stock = int.tryParse(stockCtrl.text) ?? item.stock;
                      item.barcode = barcodeCtrl.text.trim();
                      item.lowStockThreshold = int.tryParse(thresholdCtrl.text) ?? item.lowStockThreshold;
                      item.save();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("UPDATE", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text("Delete Item?", style: AppTextStyles.h3),
                        content: const Text("This action cannot be undone."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              _deleteItem(item);
                            },
                            child: const Text("Delete", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<DataStore>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text("Stock Inventory", style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.table_view_rounded, color: AppColors.success),
            onPressed: () {
              ReportingService.generateInventoryExcel(
                shopName: store.shopName,
                items: store.inventory,
              );
            },
          ),
          IconButton(
            icon: const CircleAvatar(backgroundColor: AppColors.accent, child: Icon(Icons.add, color: Colors.white)),
            onPressed: _addNewItemWithBarcode,
          ),
          const SizedBox(width: 16),
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
                    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ITEM LIST
          Expanded(
            child: _buildItemList(),
          ),


        ],
      ),
    );
  }

  Widget _buildItemList() {
    if (_displayedItems.isEmpty && _searchQuery.isEmpty) {
      return const Center(child: Text("No items found. Scan or Add new."));
    }
    
    if (_displayedItems.isEmpty && _searchQuery.isNotEmpty) {
      return const Center(child: Text("No items match your search."));
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _displayedItems.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _displayedItems.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          
          final item = _displayedItems[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _deleteItem(item),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete?"),
                        content: const Text("Are you sure you want to delete this item?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Keep")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => _showEditSheet(item),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: AppColors.accent),
                      ),
                      title: Text(item.name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                      subtitle: Text("Rs ${item.price.toStringAsFixed(0)} | Code: ${item.barcode}", style: AppTextStyles.bodySmall),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.stock < item.lowStockThreshold ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${item.stock} Left",
                          style: AppTextStyles.label.copyWith(
                            color: item.stock < item.lowStockThreshold ? AppColors.error : AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
