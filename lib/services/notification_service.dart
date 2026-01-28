import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showItemAdded({
    required int id,
    required String itemName,
    required DateTime expiryDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'inventory_channel',
      'Inventory alerts',
      channelDescription: 'Notifications when items are added',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    final dateText =
        '${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}';

    await _plugin.show(
      id,
      'Item added',
      '$itemName saved (expires: $dateText)',
      details,
    );
  }
}
