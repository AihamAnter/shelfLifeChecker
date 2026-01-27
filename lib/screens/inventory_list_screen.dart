import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_storage.dart';
import 'add_edit_item_screen.dart';

class InventoryListScreen extends StatefulWidget {
  static const routeName = '/';

  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final _storage = InventoryStorage();
  late List<InventoryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = _storage.loadItems();
    if (_items.isEmpty) {
      _seedDemoData();
    }
  }

  Future<void> _seedDemoData() async {
    final demo = [
      InventoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: 'Milk 2L',
        category: 'Dairy',
        quantity: '2 pcs',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      ),
      InventoryItem(
        id: (DateTime.now().microsecondsSinceEpoch + 1).toString(),
        name: 'Bread Loaf',
        category: 'Bakery',
        quantity: '5 pcs',
        expiryDate: DateTime.now(),
      ),
      InventoryItem(
        id: (DateTime.now().microsecondsSinceEpoch + 2).toString(),
        name: 'Chicken Breast',
        category: 'Meat',
        quantity: '1.5 kg',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    for (final item in demo) {
      await _storage.addItem(item);
    }

    setState(() => _items = _storage.loadItems());
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.pushNamed(context, AddEditItemScreen.routeName);
    if (result is InventoryItem) {
      await _storage.addItem(result);
      setState(() => _items = _storage.loadItems());
    }
  }

  Future<void> _deleteItem(String id) async {
    await _storage.deleteItem(id);
    setState(() => _items = _storage.loadItems());
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: _items.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                final daysLeft = item.daysLeftFrom(now);

                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) => _deleteItem(item.id),
                  child: _InventoryRow(item: item, daysLeft: daysLeft),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;
  final int daysLeft;

  const _InventoryRow({
    required this.item,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    final String statusText =
        daysLeft < 0 ? 'Expired' : (daysLeft == 0 ? 'Expires today' : '$daysLeft days left');

    final IconData icon =
        daysLeft < 0 ? Icons.error_outline : (daysLeft == 0 ? Icons.warning_amber : Icons.check_circle_outline);

    return ListTile(
      leading: Icon(icon),
      title: Text(item.name),
      subtitle: Text('${item.category} • ${item.quantity} • $statusText'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
