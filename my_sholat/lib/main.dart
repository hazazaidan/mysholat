// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/providers.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/prayer_time_popup.dart'; 

// ← BARU: navigatorKey global untuk show dialog dari luar widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D1A0F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await NotificationService().init();
  await NotificationService().requestPermission();

  // ← BARU: handle tap notifikasi → tampilkan popup waktu sholat
  NotificationService.onNotificationTap = (prayerName, prayerTime) async {
    // Delay kecil agar navigator sudah siap
    await Future.delayed(const Duration(milliseconds: 500));
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return;

    final settingsProv = context.read<SettingsProvider>();
    final prayerProv   = context.read<PrayerProvider>();

    PrayerTimePopup.show(
      context,
      prayerName: prayerName,
      prayerTime: prayerTime,
      cityName: settingsProv.city,
      onMarkDone: () {
        prayerProv.markPrayerDone(prayerName);
      },
    );
  };

  final prefs = await SharedPreferences.getInstance();
  final bool permissionDone = prefs.getBool('permission_done') ?? false;

  runApp(MySholatApp(permissionDone: permissionDone));
}

class MySholatApp extends StatelessWidget {
  final bool permissionDone;
  const MySholatApp({super.key, required this.permissionDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
      ],
      child: Consumer2<SettingsProvider, PrayerProvider>(
        builder: (_, settings, prayer, __) {
          settings.onGetPrayers ??= () async =>
              prayer.todayPrayers?.prayers ?? [];

          return MaterialApp(
            navigatorKey: navigatorKey, // ← BARU
            title: 'MySholat',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(settings.themeColor),
            darkTheme: AppTheme.dark(settings.themeColor),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(permissionDone: permissionDone),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}