import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  static final Notifications _instance = Notifications._internal();
  factory Notifications() => _instance;
  Notifications._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> showNoti({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await _init();
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'WalletFlow notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher', // IMPORTANT: avoids the null icon crash
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _plugin.show(
        0,
        title,
        body,
        details,
      );
    } catch (e, st) {
      debugPrint('Notification error: $e\n$st');
    }
  }
}
