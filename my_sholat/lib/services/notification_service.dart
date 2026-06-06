// lib/services/notification_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/prayer_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Pola getar: 0ms jeda → getar 800ms → jeda 300ms → getar 800ms → jeda 300ms → getar 800ms
  static final Int64List _vibrationPattern =
      Int64List.fromList([0, 800, 300, 800, 300, 800]);


  static const String _prayerChannelId   = 'prayer_channel_v3';
  static const String _reminderChannelId = 'prayer_reminder_channel_v3';

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _createNotificationChannel();
    _initialized = true;
  }

  Future<void> _createNotificationChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Hapus semua channel lama (v1, v2, v3) agar tidak ada konflik
    await androidPlugin.deleteNotificationChannel('prayer_channel');
    await androidPlugin.deleteNotificationChannel('prayer_reminder_channel');
    await androidPlugin.deleteNotificationChannel('prayer_channel_v2');
    await androidPlugin.deleteNotificationChannel('prayer_reminder_channel_v2');

    final prayerChannel = AndroidNotificationChannel(
      _prayerChannelId,
      'Pengingat Sholat',
      description: 'Notifikasi waktu sholat MySholat (getar saja)',
      importance: Importance.max,          // ← was: high. max = guaranteed vibration
      playSound: false,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
      enableLights: true,
      ledColor: const Color(0xFF10B981),
    );

    const reminderChannel = AndroidNotificationChannel(
      _reminderChannelId,
      'Pengingat Sholat Berikutnya',
      description: 'Notifikasi countdown sholat berikutnya',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await androidPlugin.createNotificationChannel(prayerChannel);
    await androidPlugin.createNotificationChannel(reminderChannel);
  }

  void setTimezoneByLongitude(double longitude) {
    final String tzName;
    if (longitude < 115.0) {
      tzName = 'Asia/Jakarta';
    } else if (longitude < 128.0) {
      tzName = 'Asia/Makassar';
    } else {
      tzName = 'Asia/Jayapura';
    }
    tz.setLocalLocation(tz.getLocation(tzName));
  }

  Future<void> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();


    await androidPlugin?.requestExactAlarmsPermission();
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
          _prayerChannelId,
          'Pengingat Sholat',
          channelDescription: 'Notifikasi waktu sholat MySholat (getar saja)',
          importance: Importance.max,      // ← sync dengan channel
          priority: Priority.max,          // ← was: high. max = system prioritizes delivery
          playSound: false,
          sound: null,
          enableVibration: true,
          vibrationPattern: _vibrationPattern,
          channelAction: AndroidNotificationChannelAction.update,
          color: const Color(0xFF10B981),
          enableLights: true,
          ledColor: const Color(0xFF10B981),
          ledOnMs: 500,
          ledOffMs: 500,
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          fullScreenIntent: false,
          ticker: title,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: false,
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
          _reminderChannelId,
          'Pengingat Sholat Berikutnya',
          channelDescription: 'Notifikasi countdown sholat berikutnya',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          playSound: false,
          enableVibration: false,
          color: const Color(0xFF10B981),
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          actions: const [
            AndroidNotificationAction(
                'pelacak', 'Pelacak', showsUserInterface: true),
            AndroidNotificationAction(
                'azkar', 'Azkar', showsUserInterface: true),
            AndroidNotificationAction(
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
      'Subuh': 1,
      'Dzuhur': 2,
      'Ashar': 3,
      'Maghrib': 4,
      'Isya': 5,
    };
    return map[name] ?? 0;
  }
}