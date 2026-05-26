// lib/widgets/countdown_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class CountdownWidget extends StatefulWidget {
  final Duration? duration;
  final String prayerName;
  final String prayerTime;

  const CountdownWidget({
    super.key,
    required this.duration,
    required this.prayerName,
    required this.prayerTime,
  });

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remaining = Duration.zero;

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
      _remaining = widget.duration!;
    }
  }

  void _startTimer() {
    _timer?.cancel();
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
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Countdown ada di atas kartu hijau → semua teks putih/putih70
    // Tidak perlu AppColors.text() di sini karena background selalu hijau
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Sholat Berikutnya',
          style: TextStyle(fontSize: 11, color: Colors.white70, letterSpacing: 1, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          widget.prayerName,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white),
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
              color: Colors.white,           // ← putih supaya kontras di atas hijau
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
        if (_remaining.inSeconds > 0) _remaining = _remaining - const Duration(seconds: 1);
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