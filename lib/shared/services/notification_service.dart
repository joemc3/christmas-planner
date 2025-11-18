import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/logger.dart';

class NotificationService {
  static const String channelId = 'christmas_planner_channel';
  static const String channelName = 'Christmas Planner';
  static const String channelDescription = 'Notifications for Christmas planning reminders and updates';

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      await _createNotificationChannel(flutterLocalNotificationsPlugin);
      AppLogger.info('Notification service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize notification service', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> _createNotificationChannel(FlutterLocalNotificationsPlugin plugin) async {
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to specific screen based on payload
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    final notificationPlugin = plugin ?? FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await notificationPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      AppLogger.info('Notification shown: $title');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to show notification', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    final notificationPlugin = plugin ?? FlutterLocalNotificationsPlugin();

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await notificationPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      AppLogger.info('Notification scheduled: $title for $scheduledDate');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to schedule notification', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> cancelNotification(int id, {FlutterLocalNotificationsPlugin? plugin}) async {
    final notificationPlugin = plugin ?? FlutterLocalNotificationsPlugin();
    try {
      await notificationPlugin.cancel(id);
      AppLogger.info('Notification cancelled: $id');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel notification', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> cancelAllNotifications({FlutterLocalNotificationsPlugin? plugin}) async {
    final notificationPlugin = plugin ?? FlutterLocalNotificationsPlugin();
    try {
      await notificationPlugin.cancelAll();
      AppLogger.info('All notifications cancelled');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel all notifications', error: e, stackTrace: stackTrace);
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications({
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    final notificationPlugin = plugin ?? FlutterLocalNotificationsPlugin();
    try {
      return await notificationPlugin.pendingNotificationRequests();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get pending notifications', error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
