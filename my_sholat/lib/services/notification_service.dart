// lib/services/notification_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import '../models/prayer_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzData.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  // Auto-detect WIB / WITA / WIT dari longitude
  void setTimezoneByLongitude(double longitude) {
    final String tzName;
    if (longitude < 115.0) {
      tzName = 'Asia/Jakarta';   // WIB
    } else if (longitude < 128.0) {
      tzName = 'Asia/Makassar';  // WITA
    } else {
      tzName = 'Asia/Jayapura';  // WIT
    }
    tz.setLocalLocation(tz.getLocation(tzName));
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> schedulePrayerNotification({
    required PrayerTime prayer,
    required int reminderMinutes,
  }) async {
    await init();
    final scheduledTime =
        prayer.dateTime.subtract(Duration(minutes: reminderMinutes));
    if (scheduledTime.isBefore(DateTime.now())) return;

    final id    = _notifId(prayer.name);
    final title = reminderMinutes > 0
        ? '⏰ ${prayer.name} $reminderMinutes menit lagi'
        : '🕌 Waktu ${prayer.name} tiba';
    final body  = reminderMinutes > 0
        ? 'Bersiaplah, waktu ${prayer.name} pukul ${prayer.time}'
        : 'Assalamu\'alaikum, waktu sholat ${prayer.name}';

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Pengingat Sholat',
          channelDescription: 'Notifikasi waktu sholat MySholat',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          playSound: true,
          color: const Color(0xFF10B981),
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleAllPrayers(
    List<PrayerTime> prayers, {
    int reminderMinutes = 10,
  }) async {
    await cancelAll();
    for (final prayer in prayers) {
      await schedulePrayerNotification(
        prayer: prayer,
        reminderMinutes: reminderMinutes,
      );
    }
  }

  Future<void> cancelAll() async => _plugin.cancelAll();

  Future<void> cancel(String prayerName) async =>
      _plugin.cancel(_notifId(prayerName));

  Future<void> showReminderNotification({
    required String prayerName,
    required String prayerTime,
    required String countdown,
  }) async {
    await init();
    await _plugin.show(
      99,
      'Berikutnya $prayerName',
      '$prayerTime · $countdown',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminder_channel',
          'Pengingat Sholat Berikutnya',
          channelDescription: 'Notifikasi countdown sholat berikutnya',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          playSound: false,
          enableVibration: false,
          color: const Color(0xFF10B981),
          icon: '@mipmap/ic_launcher',
          largeIcon:
              const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          actions: [
            const AndroidNotificationAction(
                'pelacak', 'Pelacak', showsUserInterface: true),
            const AndroidNotificationAction(
                'azkar', 'Azkar', showsUserInterface: true),
            const AndroidNotificationAction(
                'qibla', 'Qibla', showsUserInterface: true),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: false,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  Future<void> dismissReminderNotification() async => _plugin.cancel(99);

  String getShareReminderText({
    required String prayerName,
    required String prayerTime,
    required String cityName,
    required String hijriDate,
  }) {
    return '🕌 *Pengingat Sholat MySholat*\n\n'
        '$prayerName  $prayerTime\n\n'
        '📍 $cityName, Indonesia\n'
        '📅 $hijriDate\n\n'
        'Semoga Allah memberkati ibadah kita. 🤲\n'
        '#MySholat #PengingatSholat';
  }

  int _notifId(String name) {
    const map = {
      'Subuh': 1, 'Dzuhur': 2, 'Ashar': 3, 'Maghrib': 4, 'Isya': 5,
    };
    return map[name] ?? 0;
  }
}