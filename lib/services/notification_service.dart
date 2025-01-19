import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal() : notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> sendEventNotification(String eventTitle) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      channelDescription: 'Notifications for nearby events',
      importance: Importance.high,
      priority: Priority.high
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await notificationsPlugin.show(
      0,
      'You Have an Event Nearby!',
      'Event: $eventTitle',
      notificationDetails,
    );
  }
}
