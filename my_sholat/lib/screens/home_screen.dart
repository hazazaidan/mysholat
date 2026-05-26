// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';
import '../widgets/share_reminder_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadPrayers();
      context.read<ChecklistProvider>().loadToday();
      _updateReminderNotif();
    });
  }

  void _updateReminderNotif() {
    final prov = context.read<PrayerProvider>();
    final next = prov.nextPrayer;
    if (next == null) return;

    // FIX: pakai ?? Duration.zero agar tidak nullable error
    final countdown = prov.countdownToNext ?? Duration.zero;
    final h = countdown.inHours;
    final m = (countdown.inMinutes % 60).toString().padLeft(2, '0');
    final s = (countdown.inSeconds % 60).toString().padLeft(2, '0');
    final countdownStr = '$h:$m:$s';

    NotificationService().showReminderNotification(
      prayerName: next.name,
      prayerTime: next.time,
      countdown: countdownStr,
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Assalamu\'alaikum 🌙';
    if (hour < 12) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  static const _quotes = [
    '"Sesungguhnya sholat adalah tiang agama."\n— HR. Bukhari & Muslim',
    '"Barangsiapa menjaga sholat, maka sholatnya akan menjadi cahaya baginya."\n— HR. Ahmad',
    '"Sholat adalah kunci surga."\n— HR. Ahmad',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.bgCard,
          onRefresh: () async {
            await context.read<PrayerProvider>().loadPrayers();
            _updateReminderNotif();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildNextPrayerCard(),
                _buildProgressSection(),
                _buildSectionTitle('Jadwal Sholat Hari Ini'),
                _buildPrayerList(),
                _buildQuoteCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                const SizedBox(height: 2),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    children: [
                      TextSpan(text: 'My', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'Sholat', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Consumer<PrayerProvider>(
            builder: (_, prov, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgCardActive,
                border: Border.all(color: AppColors.bgCardBorder),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 13),
                  const SizedBox(width: 4),
                  Text(prov.cityName,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    return Consumer<PrayerProvider>(
      builder: (_, prov, __) {
        final next = prov.nextPrayer;
        // FIX: ?? Duration.zero agar tidak nullable error
        final countdown = prov.countdownToNext ?? Duration.zero;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2A1A), Color(0xFF1A3A2A)],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            border: Border.all(color: AppColors.bgCardBorderActive),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20, top: -20,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1.5),
                  ),
                ),
              ),
              Positioned(
                right: -35, top: -35,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        width: 1),
                  ),
                ),
              ),
              Positioned(
                right: 14, bottom: 10,
                child: Icon(Icons.mosque_rounded,
                    size: 38,
                    color: AppColors.primary.withValues(alpha: 0.18)),
              ),

              if (next != null)
                Positioned(
                  top: 0, right: 0,
                  child: GestureDetector(
                    onTap: () => _showShare(context, prov),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.ios_share_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ),

              if (prov.isLoading)
                const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2),
                  ),
                )
              else if (next != null)
                CountdownWidget(
                  duration: countdown,
                  prayerName: next.name,
                  prayerTime: '${next.time} · ${_formatDate(DateTime.now())}',
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Semua Sholat Hari Ini',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                            letterSpacing: 1)),
                    const SizedBox(height: 6),
                    const Text('Sudah Selesai ✅',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('MasyaAllah, semangat terus!',
                        style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showShare(BuildContext context, PrayerProvider prov) {
    final next = prov.nextPrayer;
    if (next == null) return;
    ShareReminderSheet.show(
      context,
      prayerName: next.name,
      prayerTime: next.time,
      cityName: prov.cityName,
      hijriDate: _getHijriLabel(),
    );
  }

  String _getHijriLabel() {
    final now = DateTime.now();
    return '${now.day} ${_monthName(now.month)} ${now.year} M';
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[m];
  }

  Widget _buildProgressSection() {
    return Consumer<ChecklistProvider>(
      builder: (_, prov, __) {
        final completed = prov.completedToday;
        final rate = prov.completionRateToday;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            border: Border.all(color: AppColors.bgCardBorder),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Progress Ibadah Hari Ini',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint)),
                  Text('$completed/5',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: rate,
                  minHeight: 6,
                  backgroundColor: AppColors.bgCardBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final names = ['S', 'D', 'A', 'M', 'I'];
                  final done = i < completed;
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.primary : AppColors.bgCardBorder,
                      border: Border.all(
                        color: done ? AppColors.primary : AppColors.bgCardBorderActive,
                      ),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : Text(names[i],
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textFaint,
                                  fontWeight: FontWeight.w600)),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 0.5)),
      );

  Widget _buildPrayerList() {
    return Consumer<PrayerProvider>(
      builder: (_, prov, __) {
        if (prov.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        final prayers = prov.todayPrayers?.prayers ?? [];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: prayers
                .map((p) => PrayerCard(prayer: p, showStatus: false))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildQuoteCard() {
    final idx = DateTime.now().day % _quotes.length;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorder),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          colors: [AppColors.bgCardActive, AppColors.bgCard],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_quotes[idx],
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.6,
                    fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}