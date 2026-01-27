import 'package:hive/hive.dart';
import '../models/inventory_item.dart';

class InventoryStorage {
  static const String boxName = 'inventory_items';

  Future<void> init() async {
    await Hive.openBox(boxName);
  }

  Box get _box => Hive.box(boxName);

  List<InventoryItem> loadItems() {
    final raw = _box.values.toList();
    return raw
        .whereType<Map>()
        .map((m) => _fromMap(Map<String, dynamic>.from(m)))
        .toList()
        .reversed
        .toList();
  }

  Future<void> addItem(InventoryItem item) async {
    await _box.put(item.id, _toMap(item));
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
  }

  Map<String, dynamic> _toMap(InventoryItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'category': item.category,
      'quantity': item.quantity,
      'expiryDate': item.expiryDate.toIso8601String(),
      'photoPath': item.photoPath,
    };
  }

  InventoryItem _fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as String,
      expiryDate: DateTime.parse(map['expiryDate'] as String),
      photoPath: map['photoPath'] as String?,
    );
  }
}
