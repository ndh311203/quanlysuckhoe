import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));

    tz.initializeTimeZones();
    // Use UTC as a safe default for scheduling if local timezone detection is unavailable.
    try {
      tz.setLocalLocation(tz.getLocation('UTC'));
    } catch (_) {
      // ignore
    }
  }

  Future<void> showNotification(int id, String title, String body) async {
    const android = AndroidNotificationDetails('health_channel', 'Health reminders',
        channelDescription: 'Reminders for health actions',
        importance: Importance.max,
        priority: Priority.high);
    const ios = DarwinNotificationDetails();
    await _plugin.show(id, title, body, const NotificationDetails(android: android, iOS: ios));
  }

  Future<void> scheduleDaily(int id, String title, String body, int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('health_channel', 'Health reminders',
            channelDescription: 'Reminders for health actions'),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      // payload: null,
    );
  }
}


