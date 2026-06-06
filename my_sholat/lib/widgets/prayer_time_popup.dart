// lib/widgets/prayer_time_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'mosque_painter.dart';

class PrayerTimePopup extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String cityName;
  final VoidCallback? onMarkDone;

  const PrayerTimePopup({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.cityName,
    this.onMarkDone,
  });

  static Future<void> show(
    BuildContext context, {
    required String prayerName,
    required String prayerTime,
    required String cityName,
    VoidCallback? onMarkDone,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        pageBuilder: (_, __, ___) => PrayerTimePopup(
          prayerName: prayerName,
          prayerTime: prayerTime,
          cityName: cityName,
          onMarkDone: onMarkDone,
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Status bar transparan saat popup muncul
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF052E16), // hijau sangat gelap
              Color(0xFF061A0C),
              Color(0xFF030D06),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 1),

              // ── Chip header ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  '🌙 Waktu Sholat',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Nama sholat ──
              Text(
                prayerName,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              // ── Jam sholat ──
              Text(
                prayerTime,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 10),

              // ── Kota ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '$cityName, Indonesia',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Divider gradient ──
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Gambar masjid ──
              MosqueWidget(
                width: size.width * 0.65,
                height: size.width * 0.65 * 0.7,
              ),

              const Spacer(flex: 2),

              // ── Tombol ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    // Tandai Sudah Sholat
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onMarkDone?.call();
                        },
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text(
                          'Tandai Sudah Sholat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tutup
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}