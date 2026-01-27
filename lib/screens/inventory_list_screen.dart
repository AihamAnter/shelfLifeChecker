import 'dart:io';
import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_storage.dart';
import 'add_edit_item_screen.dart';


enum InventoryFilter { all, expiringSoon, expired }

class InventoryListScreen extends StatefulWidget {
  static const routeName = '/';

  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final _storage = InventoryStorage();
  late List<InventoryItem> _items;

  InventoryFilter _filter = InventoryFilter.all;
  String _query = '';

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
      InventoryItem(
        id: (DateTime.now().microsecondsSinceEpoch + 3).toString(),
        name: 'Tomatoes',
        category: 'Vegetables',
        quantity: '3 kg',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ];

    for (final item in demo) {
      await _storage.addItem(item);
    }

    setState(() => _items = _storage.loadItems());
  }

  Future<void> _reload() async {
    setState(() => _items = _storage.loadItems());
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.pushNamed(context, AddEditItemScreen.routeName);
    if (result is InventoryItem) {
      await _storage.addItem(result);
      await _reload();
    }
  }

  Future<void> _deleteItem(String id) async {
    await _storage.deleteItem(id);
    await _reload();
  }

  List<InventoryItem> _applyFilter(List<InventoryItem> items, DateTime now) {
    final q = _query.trim().toLowerCase();

    bool matchesQuery(InventoryItem item) {
      if (q.isEmpty) return true;
      return item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.quantity.toLowerCase().contains(q);
    }

    bool matchesFilter(InventoryItem item) {
      final daysLeft = item.daysLeftFrom(now);
      switch (_filter) {
        case InventoryFilter.all:
          return true;
        case InventoryFilter.expiringSoon:
          return daysLeft >= 0 && daysLeft <= 3;
        case InventoryFilter.expired:
          return daysLeft < 0;
      }
    }

    return items.where((e) => matchesQuery(e) && matchesFilter(e)).toList();
  }

  String _filterLabel(InventoryFilter f) {
    switch (f) {
      case InventoryFilter.all:
        return 'All';
      case InventoryFilter.expiringSoon:
        return 'Expiring (≤3d)';
      case InventoryFilter.expired:
        return 'Expired';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final visible = _applyFilter(_items, now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          PopupMenuButton<InventoryFilter>(
            tooltip: 'Filter',
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (context) => [
              for (final f in InventoryFilter.values)
                PopupMenuItem(
                  value: f,
                  child: Text(_filterLabel(f)),
                ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search (name, category, quantity)',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Chip(label: Text(_filterLabel(_filter))),
                const SizedBox(width: 8),
                Text('${visible.length} items'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visible.isEmpty
                ? const Center(child: Text('No items match your filter/search.'))
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final item = visible[index];
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
          ),
        ],
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
      leading: item.photoPath != null
    ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(item.photoPath!),
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      )
    : Icon(icon),
      title: Text(item.name),
      subtitle: Text('${item.category} • ${item.quantity} • $statusText'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
