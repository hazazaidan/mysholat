// lib/widgets/mosque_painter.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget masjid siluet custom paint untuk splash screen
class MosqueWidget extends StatelessWidget {
  final double width;
  final double height;

  const MosqueWidget({
    super.key,
    this.width = 260,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: MosquePainter(),
    );
  }
}

class MosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()..color = const Color(0xFF0F2A1A);
    final strokePaint = Paint()
      ..color = const Color(0xFF1E5A34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final primaryPaint = Paint()..color = AppColors.primary;
    final primaryFaintPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.35);
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // ─── Shadow/glow dasar ────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.97), width: w * 0.85, height: h * 0.06),
      Paint()..color = AppColors.primary.withOpacity(0.08),
    );

    // ─── Menara kiri ──────────────────────────────────────────────────────
    _drawMinaret(canvas, w * 0.06, w * 0.14, h, fillPaint, strokePaint);

    // ─── Menara kanan ─────────────────────────────────────────────────────
    _drawMinaret(canvas, w * 0.86, w * 0.94, h, fillPaint, strokePaint);

    // ─── Badan bangunan utama ─────────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.54, w * 0.80, h * 0.46),
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, fillPaint);
    canvas.drawRRect(bodyRect, strokePaint);

    // ─── Kubah utama ──────────────────────────────────────────────────────
    final domePath = Path()
      ..moveTo(w * 0.25, h * 0.54)
      ..quadraticBezierTo(w * 0.5, h * 0.04, w * 0.75, h * 0.54)
      ..close();
    canvas.drawPath(domePath, Paint()..color = const Color(0xFF0F3A1A));
    canvas.drawPath(domePath, strokePaint);

    // Glow pada kubah
    canvas.drawPath(domePath, glowPaint);

    // ─── Kubah kecil kiri & kanan ─────────────────────────────────────────
    _drawSmallDome(canvas, w * 0.12, w * 0.34, h * 0.54, h, fillPaint, strokePaint);
    _drawSmallDome(canvas, w * 0.66, w * 0.88, h * 0.54, h, fillPaint, strokePaint);

    // ─── Tiang/spire menara kiri ──────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.092, h * 0.08, w * 0.019, h * 0.22),
        const Radius.circular(2),
      ),
      primaryPaint,
    );
    // Bulan sabit menara kiri
    _drawCrescent(canvas, Offset(w * 0.10, h * 0.075), 7, primaryPaint);

    // ─── Tiang/spire menara kanan ─────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.889, h * 0.08, w * 0.019, h * 0.22),
        const Radius.circular(2),
      ),
      primaryPaint,
    );
    _drawCrescent(canvas, Offset(w * 0.90, h * 0.075), 7, primaryPaint);

    // ─── Spire kubah utama ────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.489, h * 0.0, w * 0.022, h * 0.07),
        const Radius.circular(2),
      ),
      primaryPaint,
    );
    // Bulan sabit kubah utama — lebih besar
    _drawCrescent(canvas, Offset(w * 0.50, h * 0.0), 10, primaryPaint);

    // ─── Pintu utama ──────────────────────────────────────────────────────
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.435, h * 0.70, w * 0.130, h * 0.30),
      const Radius.circular(8),
    );
    canvas.drawRRect(doorRect, Paint()..color = const Color(0xFF0A1A0A));
    canvas.drawRRect(doorRect, strokePaint);

    // ─── Jendela kiri ─────────────────────────────────────────────────────
    _drawWindow(canvas, w * 0.175, h * 0.66, w * 0.11, h * 0.13, fillPaint, strokePaint);

    // ─── Jendela kanan ────────────────────────────────────────────────────
    _drawWindow(canvas, w * 0.715, h * 0.66, w * 0.11, h * 0.13, fillPaint, strokePaint);

    // ─── Bintang dekoratif ────────────────────────────────────────────────
    for (final pos in [
      Offset(w * 0.88, h * 0.08),
      Offset(w * 0.93, h * 0.22),
      Offset(w * 0.12, h * 0.06),
      Offset(w * 0.04, h * 0.28),
    ]) {
      canvas.drawCircle(pos, 1.8, primaryFaintPaint);
    }

    // Bintang lebih terang
    canvas.drawCircle(Offset(w * 0.96, h * 0.12), 2.5,
        Paint()..color = AppColors.primary.withOpacity(0.5));
  }

  void _drawMinaret(Canvas canvas, double x1, double x2, double h,
      Paint fill, Paint stroke) {
    // Badan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x1, h * 0.44, x2 - x1, h * 0.56),
        const Radius.circular(4),
      ),
      fill,
    );
    // Kubah menara
    final path = Path()
      ..moveTo(x1, h * 0.44)
      ..quadraticBezierTo((x1 + x2) / 2, h * 0.26, x2, h * 0.44)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF0F3A1A));
    canvas.drawPath(path, stroke);
  }

  void _drawSmallDome(Canvas canvas, double x1, double x2, double baseY,
      double h, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(x1, baseY)
      ..quadraticBezierTo((x1 + x2) / 2, baseY - h * 0.12, x2, baseY)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF0F3A1A));
    canvas.drawPath(path, stroke);
  }

  void _drawWindow(Canvas canvas, double x, double y, double w, double h,
      Paint fill, Paint stroke) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF1A3A2A));
    canvas.drawRRect(rect, stroke);
  }

  void _drawCrescent(Canvas canvas, Offset center, double radius, Paint paint) {
    final strokePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: radius * 2, height: radius * 2),
      0.6,
      5.0,
      false,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated mosque widget dengan glow effect
class AnimatedMosqueWidget extends StatefulWidget {
  final double width;
  final double height;

  const AnimatedMosqueWidget({
    super.key,
    this.width = 260,
    this.height = 200,
  });

  @override
  State<AnimatedMosqueWidget> createState() => _AnimatedMosqueWidgetState();
}

class _AnimatedMosqueWidgetState extends State<AnimatedMosqueWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: widget.width * 0.85,
            height: widget.height * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.12 * _glowAnim.value),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Mosque
          child!,
        ],
      ),
      child: MosqueWidget(width: widget.width, height: widget.height),
    );
  }
}