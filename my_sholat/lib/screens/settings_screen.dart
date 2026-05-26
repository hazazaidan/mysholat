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
        titleSpacing: 20,
        toolbarHeight: 52,
        title: const Text('Pengaturan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<SettingsProvider>(
        builder: (_, prov, __) {
          final accent = prov.themeColor;
          return ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              _buildProfileCard(prov, accent),
              const SizedBox(height: 8),
              _buildSectionLabel('PENGATURAN UMUM'),
              _buildGroup([
                _buildItem(
                  icon: Icons.location_on_rounded,
                  label: 'Lokasi',
                  value: prov.city,
                  accent: accent,
                  isFirst: true,
                  isLast: false,
                  onTap: () => _showCityPicker(context, prov),
                ),
                _buildDivider(),
                _buildToggleItem(
                  icon: Icons.dark_mode_rounded,
                  label: 'Mode Gelap',
                  value: prov.settings.darkMode,
                  accent: accent,
                  isFirst: false,
                  isLast: false,
                  onChanged: (_) => prov.toggleDarkMode(),
                ),
                _buildDivider(),
                _buildItem(
                  icon: Icons.language_rounded,
                  label: 'Bahasa',
                  value: 'Indonesia',
                  accent: accent,
                  isFirst: false,
                  isLast: true,
                  onTap: () => _showComingSoon(context, 'Bahasa'),
                ),
              ]),
              _buildSectionLabel('TEMA WARNA'),
              _buildThemePicker(prov, accent),
              _buildSectionLabel('NOTIFIKASI & ADZAN'),
              _buildGroup([
                _buildToggleItem(
                  icon: Icons.notifications_rounded,
                  label: 'Aktifkan Notifikasi',
                  value: prov.notificationsEnabled,
                  accent: accent,
                  isFirst: true,
                  isLast: false,
                  onChanged: (_) => prov.toggleNotifications(),
                ),
                _buildDivider(),
                _buildToggleItem(
                  icon: Icons.vibration_rounded,
                  label: 'Getar Saat Adzan',
                  value: prov.settings.vibration,
                  accent: accent,
                  isFirst: false,
                  isLast: false,
                  onChanged: (_) => prov.toggleVibration(),
                ),
                _buildDivider(),
                _buildItem(
                  icon: Icons.timer_rounded,
                  label: 'Pengingat Sebelum Adzan',
                  value: '${prov.settings.reminderMinutes} menit',
                  accent: accent,
                  isFirst: false,
                  isLast: true,
                  onTap: () => _showReminderPicker(context, prov, accent),
                ),
              ]),
              _buildSectionLabel('LAINNYA'),
              _buildGroup([
                _buildItem(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang MySholat',
                  value: 'v1.0.0',
                  accent: accent,
                  isFirst: true,
                  isLast: false,
                  onTap: () => _showAbout(context, accent),
                ),
                _buildDivider(),
                _buildItem(
                  icon: Icons.shield_outlined,
                  label: 'Kebijakan Privasi',
                  accent: accent,
                  isFirst: false,
                  isLast: true,
                  onTap: () => _showComingSoon(context, 'Kebijakan Privasi'),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  // ── Profile Card ──────────────────────────────────────────────────────────
  Widget _buildProfileCard(SettingsProvider prov, Color accent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.18),
            AppColors.bgCardActive,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengguna MySholat',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: accent, size: 12),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text('${prov.city}, Indonesia',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: accent.withValues(alpha: 0.8))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge aktif
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Text('Aktif',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent)),
          ),
        ],
      ),
    );
  }

  // ── Tema Warna Picker (card baru) ─────────────────────────────────────────
  Widget _buildThemePicker(SettingsProvider prov, Color accent) {
    final themes = [
      {'label': 'Hijau', 'color': const Color(0xFF10B981)},
      {'label': 'Teal', 'color': const Color(0xFF00BFA5)},
      {'label': 'Biru', 'color': const Color(0xFF3B82F6)},
      {'label': 'Ungu', 'color': const Color(0xFF9B59B6)},
      {'label': 'Amber', 'color': const Color(0xFFF59E0B)},
      {'label': 'Gold', 'color': const Color(0xFFC9A84C)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, color: accent, size: 15),
              const SizedBox(width: 8),
              Text('Pilih Warna Tema',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    spreadRadius: 1)
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 17)
                          : null,
                    ),
                    const SizedBox(height: 5),
                    Text(label,
                        style: TextStyle(
                            fontSize: 9,
                            color:
                                isSelected ? color : AppColors.textFaint,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Group wrapper ─────────────────────────────────────────────────────────
  Widget _buildGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Divider(
        height: 1,
        thickness: 1,
        indent: 54,
        endIndent: 0,
        color: AppColors.bgCardBorder,
      );

  Widget _buildSectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textFaint,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4)),
      );

  // ── Item dengan rounded corners per posisi ────────────────────────────────
  Widget _buildItem({
    required IconData icon,
    required String label,
    String? value,
    required Color accent,
    required bool isFirst,
    required bool isLast,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: accent, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textSecondary)),
              ),
              if (value != null) ...[
                Text(value,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint.withValues(alpha: 0.8))),
                const SizedBox(width: 4),
              ],
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textFaint, size: 17),
            ],
          ),
        ),
      );

  Widget _buildToggleItem({
    required IconData icon,
    required String label,
    required bool value,
    required Color accent,
    required bool isFirst,
    required bool isLast,
    required ValueChanged<bool> onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: accent, size: 15),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13.5, color: AppColors.textSecondary)),
            ),
            Transform.scale(
              scale: 0.82,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: accent,
                inactiveThumbColor: AppColors.textFaint,
                inactiveTrackColor: AppColors.bgCardBorder,
              ),
            ),
          ],
        ),
      );

  // ── Bottom Sheets ─────────────────────────────────────────────────────────
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
            decoration: BoxDecoration(
                color: AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pilih Kota',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: IndonesianCities.cities.length,
              itemBuilder: (_, i) {
                final city = IndonesianCities.cities[i];
                return ListTile(
                  title: Text(city,
                      style: const TextStyle(
                          color: AppColors.textSecondary)),
                  trailing: prov.city == city
                      ? Icon(Icons.check_rounded,
                          color: prov.themeColor, size: 18)
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

  void _showReminderPicker(
      BuildContext context, SettingsProvider prov, Color accent) {
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
            decoration: BoxDecoration(
                color: AppColors.bgCardBorder,
                borderRadius: BorderRadius.circular(2)),
          ),
          const Text('Pengingat Sebelum Adzan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...options.map((min) => ListTile(
                title: Text('$min menit sebelumnya',
                    style: const TextStyle(color: AppColors.textSecondary)),
                trailing: prov.settings.reminderMinutes == min
                    ? Icon(Icons.check_rounded, color: accent, size: 18)
                    : null,
                onTap: () {
                  prov.setReminderMinutes(min);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context, Color accent) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMain,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg)),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            children: [
              const TextSpan(
                  text: 'My', style: TextStyle(color: Colors.white)),
              TextSpan(
                  text: 'Sholat', style: TextStyle(color: accent)),
            ],
          ),
        ),
        content: const Text(
          'Versi 1.0.0\n\nAplikasi pengingat waktu sholat berbasis lokasi untuk Indonesia.\n\nDibuat dengan ❤️ untuk membantu ibadah sehari-hari.',
          style: TextStyle(
              fontSize: 13, color: AppColors.textMuted, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature akan segera hadir',
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}