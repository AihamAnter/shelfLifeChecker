import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import 'add_edit_item_screen.dart';

class InventoryListScreen extends StatefulWidget {
  static const routeName = '/';

  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final List<InventoryItem> _items = [
    InventoryItem(
      id: '1',
      name: 'Milk 2L',
      category: 'Dairy',
      quantity: '2 pcs',
      expiryDate: DateTime.now().add(const Duration(days: 2)),
    ),
    InventoryItem(
      id: '2',
      name: 'Bread Loaf',
      category: 'Bakery',
      quantity: '5 pcs',
      expiryDate: DateTime.now(),
    ),
    InventoryItem(
      id: '3',
      name: 'Chicken Breast',
      category: 'Meat',
      quantity: '1.5 kg',
      expiryDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<void> _openAddItem() async {
    final result = await Navigator.pushNamed(context, AddEditItemScreen.routeName);
    if (result is InventoryItem) {
      setState(() => _items.insert(0, result));
    }
  }

  void _deleteItem(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
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
      onTap: () {
        // later: details/edit
      },
    );
  }
}
