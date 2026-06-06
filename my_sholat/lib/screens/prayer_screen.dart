// lib/screens/prayer_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/widgets.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerProvider>().loadPrayers();
    });
  }

  void _prevDay() => setState(() =>
      _selectedDate = _selectedDate.subtract(const Duration(days: 1)));

  void _nextDay() => setState(() =>
      _selectedDate = _selectedDate.add(const Duration(days: 1)));

  String _formatDate(DateTime d) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _hijriDate(DateTime d) {
    const hijriMonths = [
      'Muharram', 'Safar', 'Rabi\'ul Awal', 'Rabi\'ul Akhir',
      'Jumadil Awal', 'Jumadil Akhir', 'Rajab', 'Sya\'ban',
      'Ramadhan', 'Syawal', 'Dzulqa\'dah', 'Dzulhijjah',
    ];
    final diff = d.difference(DateTime(2000, 1, 6)).inDays;
    final hijriDays = (diff * 29.53059 / 30).floor();
    final hijriYear = 1421 + (hijriDays ~/ 354);
    final monthIndex = (hijriDays % 12);
    final hijriDay = (diff % 30) + 1;
    return '$hijriDay ${hijriMonths[monthIndex]} $hijriYear H';
  }

  // ← BARU: show popup waktu sholat saat card diklik
  void _showPrayerPopup(BuildContext context, prayer) {
    final settingsProv = context.read<SettingsProvider>();
    final prayerProv   = context.read<PrayerProvider>();

    PrayerTimePopup.show(
      context,
      prayerName: prayer.name,
      prayerTime: prayer.time,
      cityName: settingsProv.city,
      onMarkDone: () {
        prayerProv.markPrayerDone(prayer.name);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        automaticallyImplyLeading: false,
        title: const Text('Jadwal Sholat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textHint),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (_, prov, __) => Column(
          children: [
            // Date navigator
            _buildDateNav(),

            // Location card
            _buildLocationCard(prov),

            // Column headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                children: [
                  const Text('Waktu Sholat',
                      style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
                  const Spacer(),
                  const Text('Status',
                      style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
                ],
              ),
            ),

            // Prayer list
            Expanded(
              child: prov.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _buildPrayerList(prov),
            ),

            // Note
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bgCardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: AppColors.textFaint),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Waktu sholat disesuaikan otomatis berdasarkan lokasi Anda.',
                      style: TextStyle(fontSize: 11, color: AppColors.textFaint),
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

  Widget _buildDateNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _prevDay,
            child: const Icon(Icons.chevron_left_rounded,
                color: AppColors.primary, size: 22),
          ),
          Expanded(
            child: Column(
              children: [
                Text(_formatDate(_selectedDate),
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(_hijriDate(_selectedDate),
                    style: TextStyle(fontSize: 11, color: AppColors.textFaint)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _nextDay,
            child: const Icon(Icons.chevron_right_rounded,
                color: AppColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(PrayerProvider prov) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCardActive,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorderActive),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prov.cityName,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
                const Text('GMT+7',
                    style: TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showCityPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Ubah Lokasi',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerList(PrayerProvider prov) {
    final prayers = prov.todayPrayers?.prayers ?? [];
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: prayers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => PrayerCard(
        prayer: prayers[i],
        showStatus: true,
        // ← PERUBAHAN: onTap sekarang membuka popup waktu sholat
        onTap: () => _showPrayerPopup(context, prayers[i]),
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMain,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pilih Kota',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: IndonesianCities.cities.length,
              itemBuilder: (_, i) {
                final city = IndonesianCities.cities[i];
                return ListTile(
                  title: Text(city,
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textFaint, size: 18),
                  onTap: () {
                    context.read<SettingsProvider>().updateCity(city);
                    context.read<PrayerProvider>().loadPrayers(city: city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}