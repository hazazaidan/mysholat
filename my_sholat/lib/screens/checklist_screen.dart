import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<ChecklistProvider>();
      await prov.loadToday();
      await prov.loadWeeklyStats();
      final s = await prov.getStreak();
      if (mounted) setState(() => _streak = s);
    });
  }

  static const _prayerTimes = {
    'Subuh': '04:15',
    'Dzuhur': '12:00',
    'Ashar': '15:18',
    'Maghrib': '17:42',
    'Isya': '18:56',
  };

  // ── TAMBAH: Dialog konfirmasi batalkan catatan sholat (gambar 4)
  Future<bool> _showCancelConfirmDialog(String prayerName) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // harus pilih salah satu
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.bgCardBorder),
        ),
        title: const Text(
          'Batalkan Catatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan catatan sholat ini?',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textHint,
            height: 1.5,
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          // Batalkan — kembali tanpa uncheck
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batalkan',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
          // OK — lanjut uncheck
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'OK',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        automaticallyImplyLeading: false,
        title: const Text('Checklist Ibadah'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(_todayLabel(),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint)),
            ),
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (_, prov, __) => SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              _buildProgressCard(prov),
              _buildWeekRow(prov),
              _buildSectionLabel('Sholat Hari Ini'),
              _buildChecklistItems(prov),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(ChecklistProvider prov) {
    final completed = prov.completedToday;
    final rate = prov.completionRateToday;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: rate,
            size: 80,
            centerLabel: '${(rate * 100).toInt()}%',
            centerSub: 'hari ini',
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed >= 5
                      ? 'MasyaAllah! Lengkap!'
                      : completed >= 3
                          ? 'Konsistensi Baik!'
                          : 'Yuk Semangat!',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text('$completed dari 5 sholat selesai hari ini',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint)),
                if (_streak >= 2) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.primary, size: 13),
                        const SizedBox(width: 4),
                        Text('$_streak hari berturut',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekRow(ChecklistProvider prov) {
    final stats = prov.weeklyStats;
    final today = DateTime.now();
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: stats.map((s) {
          final isToday = s.date.day == today.day &&
              s.date.month == today.month &&
              s.date.year == today.year;
          final isPast = s.date.isBefore(today);
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isToday
                        ? AppColors.primary
                        : AppColors.bgCardBorder),
              ),
              child: Column(
                children: [
                  Text(s.dayLabel,
                      style: TextStyle(
                          fontSize: 9,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textFaint)),
                  const SizedBox(height: 4),
                  Text(
                    isPast || isToday ? '${s.completed}' : '-',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isPast || isToday
                            ? AppColors.primary
                            : AppColors.textFaint),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5)),
        ),
      );

  Widget _buildChecklistItems(ChecklistProvider prov) {
    if (prov.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: prov.todayEntries.map((entry) {
          final time = _prayerTimes[entry.prayerName] ?? '--:--';

          return ChecklistItemWidget(
            entry: entry,
            prayerTime: time,
            // REVISI: onToggle sekarang cek apakah entry sudah done
            // Jika sudah done → tampil dialog konfirmasi sebelum uncheck
            // Jika belum done → langsung toggle (tidak perlu konfirmasi)
            onToggle: () async {
              if (entry.isDone) {
                // Sudah dicentang → tanya konfirmasi dulu
                final confirm = await _showCancelConfirmDialog(entry.prayerName);
                if (!confirm) return; // user pilih Batalkan → tidak jadi uncheck
              }
              prov.togglePrayer(entry.prayerName, prayerTime: time);
            },
          );
        }).toList(),
      ),
    );
  }

  String _todayLabel() {
    final d = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month]}';
  }
}