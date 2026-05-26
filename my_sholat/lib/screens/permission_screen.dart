// lib/screens/permission_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/providers.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import 'main_navigation.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool   _locationGranted = false;
  bool   _notifGranted    = false;
  bool   _isLoading       = false;
  bool   _locationLoading = false;
  String _selectedCity    = 'Yogyakarta';

  Future<void> _requestLocation() async {
    if (_locationLoading) return;
    setState(() => _locationLoading = true);

    try {
      final result = await LocationService().getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationGranted = result != null;
          if (result != null) _selectedCity = result.city;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationGranted = false);
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _requestNotification() async {
    await NotificationService().requestPermission();
    if (mounted) setState(() => _notifGranted = true);
  }

  Future<void> _proceed() async {
    setState(() => _isLoading = true);

    if (!_locationGranted) await _requestLocation();
    if (!_notifGranted)    await _requestNotification();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_done', true);
    await prefs.setString(AppStrings.keyCity, _selectedCity);

    if (!mounted) return;

    // ── TAMBAH: sync kota ke SettingsProvider agar Settings ikut update ──
    await context.read<SettingsProvider>().updateCity(_selectedCity);

    context.read<PrayerProvider>().loadPrayers(city: _selectedCity);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('Pilih Kota',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: IndonesianCities.cities.length,
              itemBuilder: (_, i) {
                final city     = IndonesianCities.cities[i];
                final selected = city == _selectedCity;
                return ListTile(
                  title: Text(city,
                      style: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal)),
                  trailing: selected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _selectedCity = city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShieldIllustration(),
                    const SizedBox(height: 28),
                    const Text(
                      'Untuk memastikan Anda berada di\narah yang benar, aktifkan izin berikut',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildCityTile(),
                    const SizedBox(height: 10),
                    _buildPermissionTile(
                      icon: Icons.location_on_rounded,
                      title: 'Izin Lokasi',
                      subtitle: 'Untuk mendapatkan waktu sholat yang lebih akurat',
                      isGranted: _locationGranted,
                      isLoading: _locationLoading,
                      onTap: _requestLocation,
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionTile(
                      icon: Icons.notifications_rounded,
                      title: 'Izin Pemberitahuan',
                      subtitle: 'Untuk menerima notifikasi sholat dengan segera',
                      isGranted: _notifGranted,
                      isLoading: false,
                      onTap: _requestNotification,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _proceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Melanjutkan',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityTile() {
    return GestureDetector(
      onTap: _showCityPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.bgCardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.location_city_rounded,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Kota',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(_selectedCity,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.primary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textFaint, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Text('MySholat',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  letterSpacing: 0.5)),
          const Spacer(),
          Text(_formattedTime(),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildShieldIllustration() {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
          const Icon(Icons.verified_user_rounded,
              size: 52, color: AppColors.primary),
          Positioned(
            top: 14, right: 14,
            child: Icon(Icons.star_rounded,
                size: 16,
                color: Colors.amber.withValues(alpha: 0.8)),
          ),
          Positioned(
            bottom: 18, left: 14,
            child: Icon(Icons.star_rounded,
                size: 12,
                color: Colors.amber.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isGranted
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.bgCard,
          border: Border.all(
            color: isGranted
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.bgCardBorder,
            width: isGranted ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGranted
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textHint)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGranted
                    ? AppColors.primary
                    : AppColors.bgCardBorder,
                border: Border.all(
                  color: isGranted
                      ? AppColors.primary
                      : AppColors.bgCardBorderActive,
                  width: 1.5,
                ),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(3),
                      child: CircularProgressIndicator(
                          color: AppColors.primary, strokeWidth: 2),
                    )
                  : isGranted
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13)
                      : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }
}