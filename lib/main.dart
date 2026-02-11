import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const ValentineApp());

class ValentineApp extends StatelessWidget {
  const ValentineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ValentineHome(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  final List<String> emojiOptions = ['Sweet Heart', 'Party Heart'];
  String selectedEmoji = 'Sweet Heart';
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupid\'s Canvas'),
        backgroundColor: const Color(0xFFF8BBD0),
      ),
      body: Container(
        // Background: soft pink-to-red radial gradient
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFFFCE4EC),
              Color(0xFFF48FB1),
              Color(0xFFE91E63),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedEmoji,
              dropdownColor: const Color(0xFFFCE4EC),
              items: emojiOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedEmoji = value ?? selectedEmoji),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _sparkleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(300, 300),
                      painter: HeartEmojiPainter(
                        type: selectedEmoji,
                        sparklePhase: _sparkleController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/valHeart.png'),
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HeartEmojiPainter extends CustomPainter {
  HeartEmojiPainter({required this.type, required this.sparklePhase});
  final String type;
  final double sparklePhase;

  Path _buildHeartPath(Offset center, [double scale = 1.0]) {
    return Path()
      ..moveTo(center.dx, center.dy + 60 * scale)
      ..cubicTo(
        center.dx + 110 * scale, center.dy - 10 * scale,
        center.dx + 60 * scale, center.dy - 120 * scale,
        center.dx, center.dy - 40 * scale,
      )
      ..cubicTo(
        center.dx - 60 * scale, center.dy - 120 * scale,
        center.dx - 110 * scale, center.dy - 10 * scale,
        center.dx, center.dy + 60 * scale,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    final random = Random(42);

    // ── Love Trail: faint glowing aura outlines ──
    for (int i = 3; i >= 1; i--) {
      final auraScale = 1.0 + i * 0.08;
      final auraPath = _buildHeartPath(center, auraScale);
      final auraPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = const Color(0xFFE91E63).withOpacity(0.12 * (4 - i));
      canvas.drawPath(auraPath, auraPaint);
    }

    // ── Heart base with linear gradient fill ──
    final heartPath = _buildHeartPath(center);
    final Rect heartBounds = heartPath.getBounds();
    final gradientShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: type == 'Party Heart'
          ? const [Color(0xFFFF80AB), Color(0xFFF48FB1), Color(0xFFAD1457)]
          : const [Color(0xFFFF5252), Color(0xFFE91E63), Color(0xFF880E4F)],
    ).createShader(heartBounds);

    paint
      ..shader = gradientShader
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, paint);
    paint.shader = null;

    // ── Face features ──
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 10, eyePaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 10), 10, eyePaint);

    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - 28, center.dy - 8), 4, pupilPaint);
    canvas.drawCircle(Offset(center.dx + 32, center.dy - 8), 4, pupilPaint);

    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy + 20), radius: 30),
      0, 3.14, false, mouthPaint,
    );

    // ── Party hat + festive confetti ──
    if (type == 'Party Heart') {
      final hatPath = Path()
        ..moveTo(center.dx, center.dy - 110)
        ..lineTo(center.dx - 40, center.dy - 40)
        ..lineTo(center.dx + 40, center.dy - 40)
        ..close();

      final hatShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFD54F), Color(0xFFFFA726), Color(0xFFFF7043)],
      ).createShader(hatPath.getBounds());
      canvas.drawPath(hatPath, Paint()..shader = hatShader);

      canvas.drawCircle(
        Offset(center.dx, center.dy - 115), 8,
        Paint()..color = const Color(0xFFFF1744),
      );

      final stripePaint = Paint()
        ..color = const Color(0xFFE91E63)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(center.dx - 15, center.dy - 60),
          Offset(center.dx + 5, center.dy - 90), stripePaint);
      canvas.drawLine(Offset(center.dx + 15, center.dy - 60),
          Offset(center.dx - 5, center.dy - 90), stripePaint);

      // Festive Confetti: triangles, circles, rectangles
      final confettiColors = [
        const Color(0xFFFF1744), const Color(0xFFFF9100),
        const Color(0xFFFFEA00), const Color(0xFF00E676),
        const Color(0xFF2979FF), const Color(0xFFD500F9),
      ];
      for (int i = 0; i < 20; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final radius = 100 + random.nextDouble() * 60;
        final cx = center.dx + cos(angle) * radius;
        final cy = center.dy + sin(angle) * radius - 20;
        final color = confettiColors[i % confettiColors.length];
        final confettiPaint = Paint()..color = color.withOpacity(0.85);
        final shape = i % 3;
        if (shape == 0) {
          canvas.drawPath(
            Path()..moveTo(cx, cy - 6)..lineTo(cx - 5, cy + 4)..lineTo(cx + 5, cy + 4)..close(),
            confettiPaint,
          );
        } else if (shape == 1) {
          canvas.drawCircle(Offset(cx, cy), 4, confettiPaint);
        } else {
          canvas.drawRect(
            Rect.fromCenter(center: Offset(cx, cy), width: 8, height: 5),
            confettiPaint,
          );
        }
      }
    }

    // ── Animated Sparkles ──
    _drawSparkles(canvas, center);
  }

  void _drawSparkles(Canvas canvas, Offset center) {
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const int sparkleCount = 12;
    for (int i = 0; i < sparkleCount; i++) {
      final baseAngle = (2 * pi / sparkleCount) * i;
      final phase = (sparklePhase + i / sparkleCount) % 1.0;
      final radius = 90 + 30 * sin(phase * 2 * pi);
      final opacity =
          (0.3 + 0.7 * ((sin(phase * 2 * pi) + 1) / 2)).clamp(0.0, 1.0);
      final sx = center.dx + cos(baseAngle) * radius;
      final sy = center.dy + sin(baseAngle) * radius;

      sparklePaint.color = Colors.white.withOpacity(opacity);

      const double armLen = 6;
      canvas.drawLine(Offset(sx - armLen, sy), Offset(sx + armLen, sy), sparklePaint);
      canvas.drawLine(Offset(sx, sy - armLen), Offset(sx, sy + armLen), sparklePaint);
      canvas.drawLine(
        Offset(sx - armLen * 0.6, sy - armLen * 0.6),
        Offset(sx + armLen * 0.6, sy + armLen * 0.6), sparklePaint,
      );
      canvas.drawLine(
        Offset(sx + armLen * 0.6, sy - armLen * 0.6),
        Offset(sx - armLen * 0.6, sy + armLen * 0.6), sparklePaint,
      );
      canvas.drawCircle(Offset(sx, sy), 2,
          Paint()..color = Colors.white.withOpacity(opacity));
    }
  }

  @override
  bool shouldRepaint(covariant HeartEmojiPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.sparklePhase != sparklePhase;
}