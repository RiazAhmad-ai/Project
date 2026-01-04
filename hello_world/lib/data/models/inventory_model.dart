import 'package:hive/hive.dart';

part 'inventory_model.g.dart';

@HiveType(typeId: 0)
class InventoryItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double price;

  @HiveField(3)
  late int stock;

  @HiveField(4)
  late String? description;

  @HiveField(6)
  late String barcode;

  InventoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.description,
    this.barcode = "N/A",
  });
}
