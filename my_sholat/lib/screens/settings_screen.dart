// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        automaticallyImplyLeading: false,
        title: const Text('Pengaturan'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (_, prov, __) => ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            _buildProfileCard(prov),
            _buildSectionLabel('Pengaturan Umum'),
            _buildItem(
              icon: Icons.location_on_rounded,
              label: 'Lokasi',
              value: prov.city,
              onTap: () => _showCityPicker(context, prov),
            ),
            _buildToggleItem(
              icon: Icons.dark_mode_rounded,
              label: 'Mode Gelap',
              value: prov.settings.darkMode,
              onChanged: (_) => prov.toggleDarkMode(),
            ),
            _buildItem(
              icon: Icons.language_rounded,
              label: 'Bahasa',
              value: 'Bahasa Indonesia',
              onTap: () {},
            ),
            _buildSectionLabel('Tema Warna'),
            _buildThemePicker(context, prov),
            _buildSectionLabel('Notifikasi & Adzan'),
            _buildItem(
              icon: Icons.volume_up_rounded,
              label: 'Suara Adzan',
              value: _capitalize(prov.settings.adzanSound),
              onTap: () => _showAdzanPicker(context, prov),
            ),
            _buildItem(
              icon: Icons.notifications_rounded,
              label: 'Pengingat Sebelum Sholat',
              value: '${prov.settings.reminderMinutes} menit',
              onTap: () => _showReminderPicker(context, prov),
            ),
            _buildToggleItem(
              icon: Icons.vibration_rounded,
              label: 'Getar Saat Adzan',
              value: prov.settings.vibration,
              onChanged: (_) => prov.toggleVibration(),
            ),
            _buildSectionLabel('Tentang Aplikasi'),
            _buildItem(
              icon: Icons.info_outline_rounded,
              label: 'Tentang MySholat',
              value: 'v1.0.0',
              onTap: () => _showAbout(context),
            ),
            _buildItem(
              icon: Icons.shield_outlined,
              label: 'Kebijakan Privasi',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(SettingsProvider prov) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCardActive,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.bgCardBorderActive),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pengguna MySholat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.textHint, size: 12),
                  const SizedBox(width: 3),
                  Text('${prov.city}, Indonesia',
                      style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tema Warna Picker ──────────────────────────────────────────────────────
  Widget _buildThemePicker(BuildContext context, SettingsProvider prov) {
    final themes = [
      {'label': 'Hijau', 'color': const Color(0xFF10B981)},
      {'label': 'Navy Gold', 'color': const Color(0xFFC9A84C)},
      {'label': 'Teal', 'color': const Color(0xFF00BFA5)},
      {'label': 'Ungu', 'color': const Color(0xFF9B59B6)},
      {'label': 'Amber', 'color': const Color(0xFFF59E0B)},
      {'label': 'Biru', 'color': const Color(0xFF3B82F6)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Warna Tema',
              style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: themes.map((t) {
              final color = t['color'] as Color;
              final label = t['label'] as String;
              final isSelected = prov.themeColor == color;
              return GestureDetector(
                onTap: () => prov.setThemeColor(color),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? color : AppColors.textFaint,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: AppColors.textFaint,
                fontWeight: FontWeight.w500,
                letterSpacing: 1)),
      );

  Widget _buildItem({
    required IconData icon,
    required String label,
    String? value,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.bgCardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.bgCardBorder,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ),
              if (value != null) ...[
                Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint, size: 18),
            ],
          ),
        ),
      );

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.bgCardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      );

  void _showCityPicker(BuildContext context, SettingsProvider prov) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMain,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.bgCardBorder, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pilih Kota',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: IndonesianCities.cities.length,
              itemBuilder: (_, i) {
                final city = IndonesianCities.cities[i];
                return ListTile(
                  title: Text(city, style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: prov.city == city
                      ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                      : null,
                  onTap: () {
                    prov.updateCity(city);
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

  void _showReminderPicker(BuildContext context, SettingsProvider prov) {
    const options = [5, 10, 15, 20, 30];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMain,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.bgCardBorder, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pengingat Sebelum Adzan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...options.map((min) => ListTile(
            title: Text('$min menit sebelumnya',
                style: const TextStyle(color: AppColors.textSecondary)),
            trailing: prov.settings.reminderMinutes == min
                ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                : null,
            onTap: () { prov.setReminderMinutes(min); Navigator.pop(context); },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAdzanPicker(BuildContext context, SettingsProvider prov) {
    const options = ['mekah', 'madinah', 'lokal'];
    const labels = {'mekah': 'Mekah', 'madinah': 'Madinah', 'lokal': 'Lokal'};
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgMain,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: AppColors.bgCardBorder, borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pilih Suara Adzan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...options.map((s) => ListTile(
            title: Text(labels[s] ?? s, style: const TextStyle(color: AppColors.textSecondary)),
            trailing: prov.settings.adzanSound == s
                ? const Icon(Icons.check_rounded, color: AppColors.primary, size: 18)
                : null,
            onTap: () { prov.setAdzanSound(s); Navigator.pop(context); },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            children: [
              TextSpan(text: 'My', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Sholat', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
        content: const Text(
          'Versi 1.0.0\n\nAplikasi pengingat waktu sholat berbasis lokasi untuk Indonesia.\n\nDibuat dengan ❤️ untuk membantu ibadah sehari-hari.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}