/**
 * Permission Handler
 * 
 * Handles notification permissions for Android 13+.
 */

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionHandler {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /**
   * Request notification permissions
   * 
   * Required for Android 13+ devices.
   * Returns true if permissions are granted, false otherwise.
   */
  static Future<bool> requestNotificationPermission() async {
    // Request notification permissions
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (result == true) {
      print('[PERMISSIONS] Notification permissions granted');
    } else {
      print('[PERMISSIONS] Notification permissions denied');
    }

    return result ?? false;
  }

  /**
   * Check if notification permissions are granted
   */
  static Future<bool> areNotificationsEnabled() async {
    final bool? result = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();

    return result ?? false;
  }
}

