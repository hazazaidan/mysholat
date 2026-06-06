// lib/widgets/countdown_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import 'prayer_time_popup.dart';

class CountdownWidget extends StatefulWidget {
  final Duration? duration;
  final String prayerName;
  final String prayerTime;
  final String cityName;
  final VoidCallback? onMarkDone;

  const CountdownWidget({
    super.key,
    required this.duration,
    required this.prayerName,
    required this.prayerTime,
    this.cityName = 'Yogyakarta',
    this.onMarkDone,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool _popupShown = false; // ← guard agar popup hanya muncul sekali

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration ?? Duration.zero;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration && widget.duration != null) {
      _remaining  = widget.duration!;
      _popupShown = false; // reset guard saat prayer berganti
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        } else if (!_popupShown) {
          // ← BARU: countdown = 0 → tampilkan popup otomatis
          _popupShown = true;
          _showPrayerPopupAuto();
        }
      });
    });
  }

  void _showPrayerPopupAuto() {
    // Pastikan widget masih mounted dan context tersedia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PrayerTimePopup.show(
        context,
        prayerName: widget.prayerName,
        prayerTime: widget.prayerTime,
        cityName: widget.cityName,
        onMarkDone: widget.onMarkDone,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sholat Berikutnya',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white70,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.prayerName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          widget.prayerTime,
          style: const TextStyle(fontSize: 13, color: Colors.white70),
        ),
        const SizedBox(height: 10),
        ScaleTransition(
          scale: _pulseAnim,
          child: Text(
            DateFormatter.formatDuration(_remaining),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const Text(
          'menuju waktu sholat',
          style: TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class CountdownCompact extends StatefulWidget {
  final Duration? duration;
  const CountdownCompact({super.key, required this.duration});

  @override
  State<CountdownCompact> createState() => _CountdownCompactState();
}

class _CountdownCompactState extends State<CountdownCompact> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration ?? Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining.inSeconds > 0) {
          _remaining = _remaining - const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void didUpdateWidget(CountdownCompact old) {
    super.didUpdateWidget(old);
    if (widget.duration != old.duration && widget.duration != null) {
      _remaining = widget.duration!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormatter.formatDuration(_remaining),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 1,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}