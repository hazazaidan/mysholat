
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'permission_screen.dart';   // TAMBAH
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  // TAMBAH: terima flag permissionDone
  final bool permissionDone;
  const SplashScreen({super.key, this.permissionDone = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Navigasi setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.permissionDone
            ? const MainNavigation()       // sudah pernah buka → langsung masuk
            : const PermissionScreen(),    // TAMBAH: pertama kali → permission dulu
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo icon masjid
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 1.5),
                ),
                child: const Icon(Icons.mosque_rounded,
                    size: 38, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5),
                  children: [
                    TextSpan(
                        text: 'My',
                        style: TextStyle(color: Colors.white)),
                    TextSpan(
                        text: 'Sholat',
                        style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Teman Ibadah Modernmu',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.bgCardBorder,
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}