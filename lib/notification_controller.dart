import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:test_app/main.dart';
import 'package:test_app/screen/second.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'prayer_time_channel_group',
          channelKey: 'scheduled_channel',
          channelName: 'App notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,

          enableVibration: true,
          vibrationPattern: highVibrationPattern,
          importance: NotificationImportance.Max,

          onlyAlertOnce: true,
          // playSound: true,

          // soundSource: 'resource://raw/notif',
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'prayer_time_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      MainApp.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const SecondScreen(),
        ),
      );
    }
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
      ),
      schedule: NotificationCalendar(
        weekday: scheduledDate.weekday,
        hour: scheduledDate.hour,
        minute: scheduledDate.minute,
        second: scheduledDate.second,
        allowWhileIdle: true,
      ),
    );
  }
}
