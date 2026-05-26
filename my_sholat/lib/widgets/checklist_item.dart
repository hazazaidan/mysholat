// lib/widgets/checklist_item.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/checklist_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class ChecklistItemWidget extends StatefulWidget {
  final ChecklistEntry entry;
  final String prayerTime;
  final VoidCallback onToggle;

  const ChecklistItemWidget({
    super.key,
    required this.entry,
    required this.prayerTime,
    required this.onToggle,
  });

  @override
  State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<ChecklistItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.2, end: 0.9)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
    ]).animate(_bounceCtrl);
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    _bounceCtrl.forward(from: 0);
    widget.onToggle();
  }

  IconData get _prayerIcon {
    switch (widget.entry.prayerName) {
      case 'Subuh':
        return Icons.wb_twilight_rounded;
      case 'Dzuhur':
        return Icons.wb_sunny_rounded;
      case 'Ashar':
        return Icons.wb_cloudy_rounded;
      case 'Maghrib':
        return Icons.wb_sunny_outlined;
      case 'Isya':
        return Icons.nights_stay_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.entry.isDone;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone ? AppColors.bgCardActive : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isDone
                ? AppColors.bgCardBorderActive
                : AppColors.bgCardBorder,
            width: isDone ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ─── Checkbox dengan bounce animation ──────────────────────────
            ScaleTransition(
              scale: _bounceAnim,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isDone
                        ? AppColors.primary
                        : AppColors.bgCardBorderActive,
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 12),

            // ─── Prayer icon ───────────────────────────────────────────────
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _prayerIcon,
                color: isDone ? AppColors.primary : AppColors.textHint,
                size: 16,
              ),
            ),

            const SizedBox(width: 12),

            // ─── Prayer info ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.prayerName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? AppColors.textSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _buildSubtitle(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Status badge ──────────────────────────────────────────────
            _buildStatusBadge(isDone),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle() {
    if (widget.entry.isDone && widget.entry.completedAt != null) {
      return '${widget.prayerTime} · selesai ${DateFormatter.formatTime(widget.entry.completedAt!)}';
    }
    return '${widget.prayerTime} · belum';
  }

  Widget _buildStatusBadge(bool isDone) {
    if (!isDone) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgCardBorder,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Belum',
          style: TextStyle(fontSize: 10, color: AppColors.textHint),
        ),
      );
    }

    final isLate = widget.entry.isLate;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isLate
            ? AppColors.warning.withOpacity(0.12)
            : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLate ? 'Terlambat' : 'Tepat Waktu',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isLate ? AppColors.warning : AppColors.primary,
        ),
      ),
    );
  }
}