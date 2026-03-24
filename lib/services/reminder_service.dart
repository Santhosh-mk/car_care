import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class ReminderService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ✅ Keep ONE stable channel
  static const String _channelId = 'service_reminders';
  static const String _channelName = 'Service Reminders';
  static const String _channelDesc = 'Reminders for upcoming vehicle services';

  static NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Colombo'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // ✅ Safe month add (no invalid dates)
  static DateTime _addMonths(DateTime dt, int months) {
    final y = dt.year + ((dt.month - 1 + months) ~/ 12);
    final m = ((dt.month - 1 + months) % 12) + 1;
    final lastDay = DateTime(y, m + 1, 0).day;
    final day = dt.day <= lastDay ? dt.day : lastDay;
    return DateTime(y, m, day, 9, 0);
  }

  // ✅ Always schedule at 9:00AM
  static DateTime _atNine(DateTime d) => DateTime(d.year, d.month, d.day, 9, 0);

  // =========================================================
  // 1) SERVICE REMINDERS: 3 days before + on service date
  // =========================================================
  static Future<void> scheduleServiceReminders({
    required int baseId,
    required DateTime serviceDate,
    required String title,
    required String body,
  }) async {
    final onDate = _atNine(serviceDate);
    final threeDaysBefore = onDate.subtract(const Duration(days: 3));

    // 3 days before
    if (threeDaysBefore.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId * 100 + 1, // ✅ unique id space
        "Service Reminder",
        "Your service is in 3 days: $body",
        tz.TZDateTime.from(threeDaysBefore, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    // on date
    if (onDate.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId * 100 + 2,
        title,
        body,
        tz.TZDateTime.from(onDate, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // =========================================================
  // 2) TYRE PRESSURE: 1 month later reminder
  // =========================================================
  static Future<void> scheduleOneMonthCheckReminder({
    required int baseId,
    required DateTime fromDate,
    required String title,
    required String body,
  }) async {
    final oneMonthLater = _addMonths(fromDate, 1);

    if (oneMonthLater.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId * 100 + 3,
        title,
        body,
        tz.TZDateTime.from(oneMonthLater, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // =========================================================
  // 3) BRAKE PADS: 6 months from date reminder
  // =========================================================
  static Future<void> scheduleSixMonthReminder({
    required int baseId,
    required DateTime fromDate,
    required String title,
    required String body,
  }) async {
    final sixMonthsLater = _addMonths(fromDate, 6);

    if (sixMonthsLater.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId * 100 + 6,
        title,
        body,
        tz.TZDateTime.from(sixMonthsLater, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // =========================================================
  // 4) BRAKE OIL: X months before due date + on due date
  // =========================================================
  static Future<void> scheduleTwoDateReminders({
    required int baseId,
    required DateTime dueDate,
    int monthsBefore = 2, // ✅ default 2 months
    required String titleSoon,
    required String bodySoon,
    required String titleDue,
    required String bodyDue,
  }) async {
    final dueDay = _atNine(dueDate);
    final soonDate = _addMonths(dueDate, -monthsBefore);

    if (soonDate.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId * 100 + 21,
        titleSoon,
        bodySoon,
        tz.TZDateTime.from(soonDate, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (dueDay.isAfter(DateTime.now())) {
      await _plugin.zonedSchedule(
        baseId * 100 + 22,
        titleDue,
        bodyDue,
        tz.TZDateTime.from(dueDay, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // =========================================================
  // 5) Instant notification (near-due mileage warning)
  // =========================================================
  static Future<void> showInstant({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _details);
  }

  // =========================================================
  // OPTIONAL: cancel helpers (useful when editing/deleting)
  // =========================================================
  static Future<void> cancelByBaseId(int baseId) async {
    // cancel the ids you used
    await _plugin.cancel(baseId * 100 + 1);
    await _plugin.cancel(baseId * 100 + 2);
    await _plugin.cancel(baseId * 100 + 3);
    await _plugin.cancel(baseId * 100 + 6);
    await _plugin.cancel(baseId * 100 + 21);
    await _plugin.cancel(baseId * 100 + 22);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}