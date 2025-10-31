/**
 * Notification Service
 * 
 * Handles local notifications for task deadlines.
 * Provides scheduling, cancellation, and initialization functionality.
 */

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /**
   * Initialize the notification service
   */
  static Future<void> init() async {
    // ✅ Initialize timezone data
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    print('[NOTIFICATION INIT] ✅ Timezone set to: ${tz.local.name}');

    // Android initialization
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('[NOTIFICATION] 🔔 Tapped notification ID: ${response.id}');
      },
    );
  }

  /**
   * Schedule a notification at a specific time
   */
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = DateTime.now();

    if (scheduledTime.isBefore(now)) {
      print('[NOTIFICATION] ⏭️ Skipping $id — time already passed');
      return;
    }

    final tzTime = tz.TZDateTime.from(scheduledTime.toLocal(), tz.local);
    print('[NOTIFICATION] 🕒 Scheduling $id at $tzTime (${tz.local.name})');

    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Reminds you of upcoming task deadlines',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
      print('[NOTIFICATION] ✅ Scheduled $id successfully');
    } catch (e) {
      print('[NOTIFICATION] ❌ Error scheduling $id: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print('[NOTIFICATION] ❎ Cancelled notification $id');
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    print('[NOTIFICATION] 🧹 Cancelled all notifications');
  }

  static Future<void> scheduleTaskNotifications({
    required String taskId,
    required String taskTitle,
    required DateTime deadline,
    required bool isCompleted,
  }) async {
    if (isCompleted) {
      print('[NOTIFICATION] 🚫 Task already completed: $taskId');
      return;
    }

    final now = DateTime.now();
    final baseId = taskId.hashCode;
    final reminders = [60, 30, 15, 10, 5, 2];
    int count = 0;

    for (final mins in reminders) {
      final time = deadline.subtract(Duration(minutes: mins));
      if (time.isAfter(now)) {
        await scheduleNotification(
          id: baseId + mins,
          title: 'Reminder: $taskTitle',
          body: mins == 60
              ? 'Deadline in 1 hour!'
              : mins == 30
              ? 'Only 30 minutes left!'
              : 'Only $mins minute${mins > 1 ? 's' : ''} left!',
          scheduledTime: time,
        );
        count++;
      }
    }

    // Overdue reminder
    final overdue = deadline.add(const Duration(minutes: 1));
    if (overdue.isAfter(now)) {
      await scheduleNotification(
        id: baseId + 9999,
        title: 'Overdue: $taskTitle',
        body: 'This task is now overdue!',
        scheduledTime: overdue,
      );
      count++;
    }

    print('[NOTIFICATION] ✅ Scheduled $count reminders for task: $taskId');
  }

  static Future<void> cancelTaskNotifications(String taskId) async {
    final baseId = taskId.hashCode;
    final reminders = [60, 30, 15, 10, 5, 2];

    for (final mins in reminders) {
      await cancelNotification(baseId + mins);
    }

    await cancelNotification(baseId + 9999);
    print('[NOTIFICATION] 🧹 Cleared notifications for $taskId');
  }
}
