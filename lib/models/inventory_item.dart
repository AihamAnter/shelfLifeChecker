class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final DateTime expiryDate;
  final String? photoPath;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.expiryDate,
    this.photoPath,
  });

  int daysLeftFrom(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}
