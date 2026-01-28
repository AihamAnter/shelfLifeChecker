import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  Future<void> logAddItem({required String category, required bool hasPhoto}) {
    return analytics.logEvent(
      name: 'add_item',
      parameters: {
        'category': category,
        'has_photo': hasPhoto,
      },
    );
  }

  Future<void> logDeleteItem({required String category}) {
    return analytics.logEvent(
      name: 'delete_item',
      parameters: {'category': category},
    );
  }

  Future<void> logFilterUsed({required String filter}) {
    return analytics.logEvent(
      name: 'filter_used',
      parameters: {'filter': filter},
    );
  }
}
