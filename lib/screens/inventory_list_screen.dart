import 'package:flutter/material.dart';
import 'add_edit_item_screen.dart';

class InventoryListScreen extends StatelessWidget {
  static const routeName = '/';

  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
      ),
      body: ListView(
        children: const [
          _InventoryRow(
            name: 'Milk 2L',
            category: 'Dairy',
            qty: '2 pcs',
            daysLeft: 2,
          ),
          _InventoryRow(
            name: 'Bread Loaf',
            category: 'Bakery',
            qty: '5 pcs',
            daysLeft: 0,
          ),
          _InventoryRow(
            name: 'Chicken Breast',
            category: 'Meat',
            qty: '1.5 kg',
            daysLeft: -1,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddEditItemScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final String name;
  final String category;
  final String qty;
  final int daysLeft;

  const _InventoryRow({
    required this.name,
    required this.category,
    required this.qty,
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
      title: Text(name),
      subtitle: Text('$category • $qty • $statusText'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // later: open details screen
      },
    );
  }
}
