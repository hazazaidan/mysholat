// lib/widgets/prayer_card.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class PrayerCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool showStatus;
  final VoidCallback? onTap;

  const PrayerCard({
    super.key,
    required this.prayer,
    this.showStatus = false,
    this.onTap,
  });

  IconData get _icon {
    switch (prayer.name) {
      case 'Subuh':   return Icons.wb_twilight_rounded;
      case 'Dzuhur':  return Icons.wb_sunny_rounded;
      case 'Ashar':   return Icons.wb_cloudy_rounded;
      case 'Maghrib': return Icons.wb_twilight_rounded;
      case 'Isya':    return Icons.nights_stay_rounded;
      default:        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = prayer.isNext;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bg(context, active: true) : AppColors.bg(context, card: true),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isActive ? AppColors.border(context, active: true) : AppColors.border(context),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon,
                  color: isActive ? Colors.white : AppColors.primary,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(prayer.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? AppColors.primary : AppColors.text(context, level: 'secondary'),
                  )),
            ),
            Text(prayer.time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.text(context, level: 'hint'),
                )),
            if (showStatus) ...[
              const SizedBox(width: 10),
              _StatusBadge(isDone: prayer.isDone, isNext: prayer.isNext),
            ] else ...[
              const SizedBox(width: 10),
              _CheckCircle(isDone: prayer.isDone, context: context),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool isDone;
  final BuildContext context;
  const _CheckCircle({required this.isDone, required this.context});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AppDurations.fast,
    width: 22, height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isDone ? AppColors.primary : Colors.transparent,
      border: Border.all(
          color: isDone ? AppColors.primary : AppColors.border(context, active: true),
          width: 1.5),
    ),
    child: isDone
        ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
        : null,
  );
}

class _StatusBadge extends StatelessWidget {
  final bool isDone;
  final bool isNext;
  const _StatusBadge({required this.isDone, required this.isNext});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;
    if (isNext && !isDone) {
      label = 'Sekarang'; bg = AppColors.primary; fg = Colors.white;
    } else if (isDone) {
      label = 'Sudah';
      bg = AppColors.primary.withValues(alpha: 0.15);
      fg = AppColors.primary;
    } else {
      label = 'Belum';
      bg = AppColors.border(context);
      fg = AppColors.text(context, level: 'hint');
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}