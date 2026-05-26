// lib/screens/ai_advice_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/ai_recommendation_service.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class AiAdviceScreen extends StatefulWidget {
  const AiAdviceScreen({super.key});

  @override
  State<AiAdviceScreen> createState() => _AiAdviceScreenState();
}

class _AiAdviceScreenState extends State<AiAdviceScreen> {
  final _aiService = AiRecommendationService();
  List<AiAdvice> _advices = [];
  List<DayStats> _weekStats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prov = context.read<ChecklistProvider>();
    await prov.loadToday();
    await prov.loadWeeklyStats();
    final history = await prov.getLast30DaysHistory();
    final advices = _aiService.generateAdvice(history);
    if (mounted) {
      setState(() {
        _advices = advices;
        _weekStats = prov.weeklyStats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
            children: [
              TextSpan(text: 'Saran ', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Cerdas', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWeeklyChart(),
                  const SizedBox(height: 12),
                  ..._buildAdviceCards(),
                  const SizedBox(height: 12),
                  _buildAmalanSection(),
                  const SizedBox(height: 12),
                  _buildTipsSection(),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildAdviceCards() {
    return _advices
        .where((a) => a.type != AdviceType.tips)
        .map((advice) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AdviceCard(advice: advice),
            ))
        .toList();
  }

  // ── FIX: bar chart sekarang pakai tinggi yang benar (bukan semua 0)
  Widget _buildWeeklyChart() {
    // fallback jika weekStats kosong
    final stats = _weekStats.isEmpty
        ? List.generate(
            7,
            (i) => DayStats(
              date: DateTime.now().subtract(Duration(days: 6 - i)),
              completed: 0,
              total: 0,
            ),
          )
        : _weekStats;

    // cari nilai max untuk normalisasi
    final maxRate = stats.fold<double>(
        0, (prev, s) => s.completionRate > prev ? s.completionRate : prev);
    final safeMax = maxRate == 0 ? 1.0 : maxRate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              const Text('Statistik Mingguan',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const Spacer(),
              // rata-rata mingguan
              Text(
                '${(stats.fold<double>(0, (p, s) => p + s.completionRate) / stats.length * 100).toStringAsFixed(0)}% rata-rata',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: stats.map((s) {
              // normalisasi ke 60px max, min 4px kalau ada data
              final normalized = s.completionRate / safeMax;
              final height = s.completionRate > 0
                  ? (normalized * 60).clamp(8.0, 60.0)
                  : 4.0;
              final isToday = s.date.day == DateTime.now().day &&
                  s.date.month == DateTime.now().month;
              final pct = (s.completionRate * 100).toInt();

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      // persentase di atas bar
                      Text(
                        pct > 0 ? '$pct%' : '',
                        style: TextStyle(
                            fontSize: 8,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textFaint),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: 60,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: AppDurations.slow,
                          width: double.infinity,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isToday
                                  ? [AppColors.primaryLight, AppColors.primary]
                                  : s.completionRate > 0
                                      ? [AppColors.primaryDark, AppColors.bgCardBorderActive]
                                      : [AppColors.bgCardBorder, AppColors.bgCardBorder],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.dayLabel,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isToday
                                ? AppColors.primary
                                : AppColors.textFaint),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── BARU: Amalan setelah sholat
  Widget _buildAmalanSection() {
    const amalan = [
      _AmalanItem(
        icon: Icons.volume_up_rounded,
        title: 'Dzikir Setelah Sholat',
        subtitle: 'Subhanallah 33×, Alhamdulillah 33×, Allahu Akbar 33×',
        badge: 'Wajib',
        badgeColor: Color(0xFF4CAF50),
      ),
      _AmalanItem(
        icon: Icons.self_improvement_rounded,
        title: 'Doa Setelah Sholat',
        subtitle: 'Baca doa memohon kebaikan dunia akhirat setelah salam',
        badge: 'Sunnah',
        badgeColor: AppColors.primary,
      ),
      _AmalanItem(
        icon: Icons.menu_book_rounded,
        title: 'Baca Ayat Kursi',
        subtitle: 'Dibaca setelah sholat fardhu, menjaga dari gangguan',
        badge: 'Dianjurkan',
        badgeColor: Color(0xFF2196F3),
      ),
      _AmalanItem(
        icon: Icons.nights_stay_rounded,
        title: 'Sholat Sunnah Rawatib',
        subtitle:
            '2 rakaat Qobliyah Subuh, 4 rakaat Qobliyah Dzuhur, 2 rakaat Ba\'diyah Dzuhur, 2 rakaat Ba\'diyah Maghrib, 2 rakaat Ba\'diyah Isya',
        badge: 'Sunnah Muakkad',
        badgeColor: AppColors.warning,
      ),
      _AmalanItem(
        icon: Icons.bookmark_rounded,
        title: 'Baca Surah Al-Ikhlas, Al-Falaq, An-Nas',
        subtitle: 'Dibaca 3× setelah sholat Maghrib & Subuh sebagai pelindung',
        badge: 'Dianjurkan',
        badgeColor: Color(0xFF2196F3),
      ),
      _AmalanItem(
        icon: Icons.star_rounded,
        title: 'Istighfar 3×',
        subtitle: 'Astaghfirullah — dibaca segera setelah salam',
        badge: 'Sunnah',
        badgeColor: AppColors.primary,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mosque_rounded,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Amalan Setelah Sholat',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          ...amalan.map((item) => _buildAmalanTile(item)),
        ],
      ),
    );
  }

  Widget _buildAmalanTile(_AmalanItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bgDeep,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgCardBorder),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.badge,
                        style: TextStyle(
                            fontSize: 9,
                            color: item.badgeColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = _advices.where((a) => a.type == AdviceType.tips).toList();
    if (tips.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              const Text('Tips Ibadah',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(top: 5, right: 10),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary),
                    ),
                    Expanded(
                      child: Text(t.description,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.6)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Data class untuk tile amalan
class _AmalanItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  const _AmalanItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });
}

class _AdviceCard extends StatelessWidget {
  final AiAdvice advice;
  const _AdviceCard({required this.advice});

  Color get _accentColor {
    switch (advice.type) {
      case AdviceType.achievement: return AppColors.primary;
      case AdviceType.reminder:    return AppColors.primary;
      case AdviceType.consistency: return AppColors.warning;
      default:                     return AppColors.info;
    }
  }

  IconData get _icon {
    switch (advice.type) {
      case AdviceType.achievement: return Icons.emoji_events_rounded;
      case AdviceType.reminder:    return Icons.notifications_active_rounded;
      case AdviceType.consistency: return Icons.trending_up_rounded;
      default:                     return Icons.lightbulb_rounded;
    }
  }

  String get _tagLabel {
    switch (advice.type) {
      case AdviceType.achievement: return 'Pencapaian';
      case AdviceType.reminder:    return 'AI Insight';
      case AdviceType.consistency: return 'Konsistensi';
      default:                     return 'Tips';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: advice.type == AdviceType.achievement
            ? AppColors.bgCardActive
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
            color: advice.type == AdviceType.achievement
                ? AppColors.bgCardBorderActive
                : AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon, color: _accentColor, size: 11),
                const SizedBox(width: 4),
                Text(_tagLabel,
                    style: TextStyle(
                        fontSize: 10,
                        color: _accentColor,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(advice.title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(advice.description,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted, height: 1.6)),
          if (advice.actionLabel != null) ...[
            const SizedBox(height: 12),
            PrimaryButton(label: advice.actionLabel!, onTap: () {}),
          ],
        ],
      ),
    );
  }
}