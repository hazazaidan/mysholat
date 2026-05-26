// lib/screens/qibla_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _qiblaDirection;
  double  _compassHeading = 0;
  bool    _hasCompass     = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateQibla());
    _listenCompass();
  }

  void _calculateQibla() {
    final prov = context.read<PrayerProvider>();
    final loc  = prov.currentLocation;
    if (loc == null) return;

    final userLat  = _toRad(loc.latitude);
    final userLng  = _toRad(loc.longitude);
    final kaabaLat = _toRad(_kaabaLat);
    final kaabaLng = _toRad(_kaabaLng);

    final dLng = kaabaLng - userLng;
    final y    = math.sin(dLng) * math.cos(kaabaLat);
    final x    = math.cos(userLat) * math.sin(kaabaLat) -
                 math.sin(userLat) * math.cos(kaabaLat) * math.cos(dLng);

    setState(() {
      _qiblaDirection = (_toDeg(math.atan2(y, x)) + 360) % 360;
    });
  }

  void _listenCompass() {
    FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      setState(() {
        _compassHeading = event.heading ?? 0;
        _hasCompass = true;
      });
    });
  }

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;

  double get _needleAngle {
    if (_qiblaDirection == null) return 0;
    return _toRad((_qiblaDirection! - _compassHeading + 360) % 360);
  }

  bool get _isAligned =>
      _qiblaDirection != null &&
      ((_compassHeading - _qiblaDirection!).abs() % 360) < 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins'),
            children: [
              TextSpan(text: 'Arah ',  style: TextStyle(color: Colors.white)),
              TextSpan(text: 'Kiblat', style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
      ),
      body: Consumer<PrayerProvider>(
        builder: (_, prov, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildLocationInfo(prov),
                const SizedBox(height: 20),
                _hasCompass ? _buildCompass() : _buildNoCompass(),
                const SizedBox(height: 16),
                if (_qiblaDirection != null) _buildQiblaInfo(),
                const SizedBox(height: 12),
                _buildTipsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── FIX: pakai 2 baris agar tidak overflow di layar sempit
  Widget _buildLocationInfo(PrayerProvider prov) {
    final loc = prov.currentLocation;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded,
              color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: loc != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prov.cityName,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${loc.latitude.toStringAsFixed(4)}°, '
                        '${loc.longitude.toStringAsFixed(4)}°',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ],
                  )
                : Text(
                    prov.cityName,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompass() {
    return Column(
      children: [
        Text(
          _qiblaDirection != null
              ? '${_qiblaDirection!.toStringAsFixed(1)}° dari Utara'
              : 'Menghitung arah kiblat...',
          style: const TextStyle(fontSize: 13, color: AppColors.textHint),
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isAligned
                ? '✅ Anda menghadap Kiblat!'
                : 'Putar hingga jarum hijau lurus ke atas',
            key: ValueKey(_isAligned),
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  _isAligned ? FontWeight.w600 : FontWeight.normal,
              color: _isAligned ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Lingkaran kompas
        SizedBox(
          width: 280, height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background lingkaran
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgCard,
                  border: Border.all(
                    color: _isAligned
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : AppColors.bgCardBorder,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                          alpha: _isAligned ? 0.25 : 0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Tick marks
              CustomPaint(
                size: const Size(260, 260),
                painter: _TickPainter(),
              ),

              // Label N E S W
              ..._cardinalLabels(),

              // Jarum kompas merah (north)
              Transform.rotate(
                angle: -_toRad(_compassHeading),
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _NeedlePainter(
                    northColor: Colors.red,
                    southColor: Colors.white24,
                  ),
                ),
              ),

              // Jarum kiblat hijau
              if (_qiblaDirection != null)
                Transform.rotate(
                  angle: _needleAngle,
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _NeedlePainter(
                      northColor: AppColors.primary,
                      southColor:
                          AppColors.primary.withValues(alpha: 0.3),
                      isQibla: true,
                    ),
                  ),
                ),

              // Titik tengah
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _cardinalLabels() {
    const items = [
      ('U', 0.0),
      ('T', math.pi / 2),
      ('S', math.pi),
      ('B', -math.pi / 2),
    ];
    return items.map((item) {
      final (label, angle) = item;
      const r = 118.0;
      final dx = r * math.sin(angle);
      final dy = -r * math.cos(angle);
      return Positioned(
        left: 140 + dx - 8,
        top:  140 + dy - 8,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: label == 'U'
                ? AppColors.primary
                : AppColors.textFaint,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildNoCompass() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_off_rounded,
              size: 48, color: AppColors.textFaint),
          const SizedBox(height: 12),
          const Text('Sensor Kompas Tidak Tersedia',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(height: 6),
          Text(
            'Perangkat ini tidak memiliki sensor magnetometer.\n'
            'Gunakan kompas fisik untuk menentukan arah kiblat.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
          if (_qiblaDirection != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Kiblat: ${_qiblaDirection!.toStringAsFixed(1)}° dari Utara',
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQiblaInfo() {
    final selisih =
        (_qiblaDirection! - _compassHeading + 360) % 360;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.bgCardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem('Arah Kiblat',
              '${_qiblaDirection!.toStringAsFixed(1)}°'),
          Container(width: 1, height: 36, color: AppColors.bgCardBorder),
          _infoItem('Heading', '${_compassHeading.toStringAsFixed(1)}°'),
          Container(width: 1, height: 36, color: AppColors.bgCardBorder),
          _infoItem('Selisih', '${selisih.toStringAsFixed(1)}°'),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textHint)),
        ],
      );

  Widget _buildTipsCard() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.bgCardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 3, height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tips: Jauhkan dari benda logam & elektronik.\n'
                'Kalibrasi dengan membuat gerakan angka 8 dengan HP.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.5,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
}

// ── Painter tick marks lingkaran kompas
class _TickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    final paint = Paint()
      ..color = AppColors.bgCardBorder
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i++) {
      final angle = i * math.pi * 2 / 72;
      final isMajor = i % 9 == 0;
      final len = isMajor ? 10.0 : 5.0;
      paint.color = isMajor
          ? AppColors.textFaint
          : AppColors.bgCardBorder;
      final x1 = cx + (r - 4) * math.cos(angle);
      final y1 = cy + (r - 4) * math.sin(angle);
      final x2 = cx + (r - 4 - len) * math.cos(angle);
      final y2 = cy + (r - 4 - len) * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_TickPainter _) => false;
}

// ── Painter jarum kompas
class _NeedlePainter extends CustomPainter {
  final Color northColor;
  final Color southColor;
  final bool  isQibla;

  const _NeedlePainter({
    required this.northColor,
    required this.southColor,
    this.isQibla = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx  = size.width / 2;
    final cy  = size.height / 2;
    final len = isQibla ? 75.0 : 65.0;
    final w   = isQibla ? 4.5 : 3.5;

    final paintN = Paint()
      ..color = northColor
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(cx, cy), Offset(cx, cy - len), paintN);

    if (isQibla) {
      // Lingkaran kecil di ujung jarum kiblat
      canvas.drawCircle(
          Offset(cx, cy - len - 7),
          5,
          Paint()..color = northColor);
    } else {
      final paintS = Paint()
        ..color = southColor
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
          Offset(cx, cy), Offset(cx, cy + len * 0.5), paintS);
    }
  }

  @override
  bool shouldRepaint(_NeedlePainter old) =>
      old.northColor != northColor || old.isQibla != isQibla;
}