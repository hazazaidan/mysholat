// lib/widgets/prayer_time_popup.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'mosque_painter.dart';

class PrayerTimePopup extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String cityName;
  final VoidCallback? onMarkDone;
  final VoidCallback? onClose;

  const PrayerTimePopup({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.cityName,
    this.onMarkDone,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required String prayerName,
    required String prayerTime,
    required String cityName,
    VoidCallback? onMarkDone,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => PrayerTimePopup(
        prayerName: prayerName,
        prayerTime: prayerTime,
        cityName: cityName,
        onMarkDone: onMarkDone,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgCard : const Color(0xFF0A2218),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header chip
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                '🌙 Waktu Sholat',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Prayer name
            Text(
              prayerName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 4),

            // Prayer time
            Text(
              prayerTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 4),

            // Hijri / location
            Text(
              '📍 $cityName, Indonesia',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 8),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              color: AppColors.primary.withValues(alpha: 0.2),
            ),

            const SizedBox(height: 24),

            // Mosque illustration
            SizedBox(
              width: 180,
              height: 130,
              child: CustomPaint(
                painter: MosquePainter(),
              ),
            ),

            const SizedBox(height: 8),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  // Tandai Sudah Sholat button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onMarkDone?.call();
                      },
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text(
                        'Tandai Sudah Sholat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tutup button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}