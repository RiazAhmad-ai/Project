// lib/features/inventory/cart_sheet.dart
import 'package:flutter/material.dart';
import '../../data/repositories/data_store.dart';
import '../../shared/utils/formatting.dart';

class CartSheet extends StatefulWidget {
  const CartSheet({super.key});

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DataStore(),
      builder: (context, _) {
        final cartItems = DataStore().cart;
        double total = cartItems.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Shopping Cart",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.red),
                    onPressed: () => DataStore().clearCart(),
                  ),
                ],
              ),
              const Divider(),
              
              if (cartItems.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else ...[
                // Cart Items List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Rs ${Formatter.formatCurrency(item['price'])} / unit"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => DataStore().updateCartQty(item['itemId'], item['qty'] - 1),
                              ),
                              Text("${item['qty']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () => DataStore().updateCartQty(item['itemId'], item['qty'] + 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                
                // Total & Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Bill", style: TextStyle(fontSize: 18, color: Colors.grey)),
                          Text(
                            "Rs ${Formatter.formatCurrency(total)}",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            await DataStore().checkoutCart();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Sale Completed Successfully! ✅"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("FINALIZE SALE", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
