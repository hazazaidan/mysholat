// lib/widgets/share_reminder_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';

class ShareReminderSheet extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final String cityName;
  final String hijriDate;

  const ShareReminderSheet({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    required this.cityName,
    required this.hijriDate,
  });

  static void show(
    BuildContext context, {
    required String prayerName,
    required String prayerTime,
    required String cityName,
    required String hijriDate,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareReminderSheet(
        prayerName: prayerName,
        prayerTime: prayerTime,
        cityName: cityName,
        hijriDate: hijriDate,
      ),
    );
  }

  String get _shareText =>
      'Waktunya Sholat $prayerName 🕌\n'
      '⏰ $prayerTime  ·  📍 $cityName\n'
      '📅 $hijriDate\n\n'
      '"Sesungguhnya sholat adalah tiang agama."\n'
      '— HR. Bukhari & Muslim\n\n'
      '_via MySholat App_';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.bgCardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Bagikan Pengingat Sholat',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajak teman & keluarga untuk sholat tepat waktu',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Preview card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2A1A), Color(0xFF1A3A2A)],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.bgCardBorderActive),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mosque_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 6),
                    Text('MySholat · $cityName',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Waktunya Sholat $prayerName 🕌',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('$prayerTime  ·  $hijriDate',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
                const SizedBox(height: 10),
                Text(
                  '"Sesungguhnya sholat adalah tiang agama."',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tombol share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Tombol WhatsApp — pakai share_plus
                _ShareButton(
                  icon: Icons.message_rounded,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () {
                    Navigator.pop(context);
                    // share_plus akan buka share sheet native Android/iOS
                    // user bisa pilih WA langsung dari sana
                    Share.share(_shareText, subject: 'Pengingat Sholat $prayerName');
                  },
                ),
                const SizedBox(width: 10),
                // Tombol Salin
                _ShareButton(
                  icon: Icons.copy_rounded,
                  label: 'Salin Teks',
                  color: AppColors.primary,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _shareText));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Teks berhasil disalin!'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}