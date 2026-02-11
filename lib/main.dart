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
    );
  }
}

/* ---------------- HOME ---------------- */

class ValentineHome extends StatefulWidget {
  const ValentineHome({super.key});

  @override
  State<ValentineHome> createState() => _ValentineHomeState();
}

class _ValentineHomeState extends State<ValentineHome>
    with SingleTickerProviderStateMixin {
  String selectedEmoji = 'Lovestruck Heart';
  final List<Offset> trailPoints = [];

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cupid's Canvas 💘")),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/rose_valentine_wallpaper.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedEmoji,
              items: const [
                DropdownMenuItem(
                    value: 'Lovestruck Heart',
                    child: Text("😍 Lovestruck Heart")),
                DropdownMenuItem(
                    value: 'Party Heart',
                    child: Text("🥳 Party Heart")),
              ],
              onChanged: (v) => setState(() => selectedEmoji = v!),
            ),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    trailPoints.add(details.localPosition);
                    if (trailPoints.length > 80) {
                      trailPoints.removeAt(0);
                    }
                  });
                },
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return CustomPaint(
                      painter: HeartPainter(
                        points: trailPoints,
                        type: selectedEmoji,
                        tick: controller.value,
                      ),
                      child: Container(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- PAINTER ---------------- */

class HeartPainter extends CustomPainter {
  final List<Offset> points;
  final String type;
  final double tick;

  HeartPainter({
    required this.points,
    required this.type,
    required this.tick,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      final opacity = i / points.length;
      drawHeart(canvas, points[i], opacity);
    }
  }

  void drawHeart(Canvas canvas, Offset center, double opacity) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(0.8 + sin(tick * 2 * pi) * 0.05);

    final heartPath = Path()
      ..moveTo(0, 40)
      ..cubicTo(80, -10, 40, -90, 0, -40)
      ..cubicTo(-40, -90, -80, -10, 0, 40)
      ..close();

    /// 💖 LOVE TRAIL / AURA (VERY VISIBLE)
    canvas.drawPath(
      heartPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = Colors.pinkAccent.withOpacity(opacity * 0.25),
    );

    /// ❤️ MAIN HEART (LINEAR GRADIENT)
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: type == 'Party Heart'
            ? [Colors.pinkAccent, Colors.deepPurple]
            : [Colors.red, Colors.pinkAccent],
      ).createShader(
        Rect.fromCircle(center: Offset.zero, radius: 90),
      );

    canvas.drawPath(heartPath, fillPaint);

    /// ✨ SPARKLES
    final sparklePaint = Paint()..color = Colors.white.withOpacity(opacity);
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3) + tick * 2 * pi;
      canvas.drawCircle(
        Offset(cos(angle) * 55, sin(angle) * 55),
        2,
        sparklePaint,
      );
    }

    /// 👀 EYES
    if (type == 'Lovestruck Heart') {
      drawMiniHeart(canvas, const Offset(-18, -10));
      drawMiniHeart(canvas, const Offset(18, -10));
    } else {
      canvas.drawCircle(
          const Offset(-15, -5), 5, Paint()..color = Colors.white);
      canvas.drawCircle(
          const Offset(15, -5), 5, Paint()..color = Colors.white);
    }

    /// 😄 SMILE
    canvas.drawArc(
      const Rect.fromLTWH(-25, 10, 50, 30),
      0,
      pi,
      false,
      Paint()
        ..color = Colors.black
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );

    /// 🎉 PARTY HAT
    if (type == 'Party Heart') {
      final hat = Path()
        ..moveTo(0, -90)
        ..lineTo(-30, -30)
        ..lineTo(30, -30)
        ..close();
      canvas.drawPath(hat, Paint()..color = Colors.yellow);
    }

    canvas.restore();
  }

  void drawMiniHeart(Canvas canvas, Offset offset) {
    final p = Path()
      ..moveTo(offset.dx, offset.dy + 6)
      ..cubicTo(offset.dx + 8, offset.dy,
          offset.dx + 4, offset.dy - 8, offset.dx, offset.dy - 3)
      ..cubicTo(offset.dx - 4, offset.dy - 8,
          offset.dx - 8, offset.dy, offset.dx, offset.dy + 6)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
