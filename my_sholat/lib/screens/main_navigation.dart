// lib/screens/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'prayer_screen.dart';
import 'checklist_screen.dart';
import 'ai_advice_screen.dart';
import 'settings_screen.dart';
import 'qibla_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  static const _screens = [
    HomeScreen(),
    PrayerScreen(),
    ChecklistScreen(),
    QiblaScreen(),
    AiAdviceScreen(),
    SettingsScreen(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded,          label: 'Beranda'),
    _NavItem(icon: Icons.calendar_month_rounded, label: 'Jadwal'),
    _NavItem(icon: Icons.check_box_rounded,      label: 'Checklist'),
    _NavItem(icon: Icons.explore_rounded,        label: 'Kiblat'),
    _NavItem(icon: Icons.auto_awesome_rounded,   label: 'Saran'),
    _NavItem(icon: Icons.settings_rounded,       label: 'Pengaturan'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    _animCtrl.reset();
    setState(() => _currentIndex = index);
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: ScaleTransition(
        scale: _scaleAnim,
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgMain,
        border: Border(
          top: BorderSide(color: AppColors.bgCardBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 6,
        top: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (i) {
          final item  = _navItems[i];
          final isActive = i == _currentIndex;
          return GestureDetector(
            onTap: () => _onTabTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: AppDurations.fast,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      size: 22,
                      color: isActive ? AppColors.primary : AppColors.textFaint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? AppColors.primary : AppColors.textFaint,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}