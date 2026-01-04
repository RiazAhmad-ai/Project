// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 0;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    // Safely handle barcode: Try index 6, then index 5 if it's a string, then "N/A"
    String barcodeValue = "N/A";
    if (fields[6] is String) {
      barcodeValue = fields[6];
    } else if (fields[5] is String) {
      barcodeValue = fields[5];
    }

    return InventoryItem(
      id: fields[0] as String,
      name: fields[1] as String,
      price: fields[2] as double,
      stock: fields[3] as int,
      description: fields[4] as String?,
      barcode: barcodeValue,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.price)
      ..writeByte(3)
      ..write(obj.stock)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(6) // Use 6 here to match model
      ..write(obj.barcode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
