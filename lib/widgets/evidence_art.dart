import 'dart:math';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/util.dart';
import 'brand.dart';

class EvidenceArt extends StatelessWidget {
  const EvidenceArt({super.key, required this.scene, required this.caption, this.radius = 10});
  final String scene;
  final String caption;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(painter: _ArtPainter(scene, caption), size: Size.infinite),
      );
}

class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.scene, this.caption);
  final String scene;
  final String caption;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final r = Random(seedOf(scene + caption));
    final rect = Offset.zero & s;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1220), Color(0xFF1A2233), Color(0xFF0C0F16)],
        ).createShader(rect),
    );
    switch (scene) {
      case 'corridor':
        _corridor(canvas, w, h, r);
        break;
      case 'tower':
        _tower(canvas, w, h, r);
        break;
      case 'desk':
        _desk(canvas, w, h);
        break;
      default:
        _room(canvas, w, h, r);
    }
    final grain = Paint()..color = Colors.white.withAlpha(10);
    for (var i = 0; i < 160; i++) {
      canvas.drawRect(Rect.fromLTWH(r.nextDouble() * w, r.nextDouble() * h, 1.4, 1.4), grain);
    }
    final line = Paint()..color = Colors.black.withAlpha(35);
    for (double y = 0; y < h; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, w, 1), line);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(radius: 0.9, colors: [Colors.transparent, Colors.black.withAlpha(170)])
            .createShader(rect),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: caption.isEmpty ? 'REC' : caption,
        style: const TextStyle(color: C.green, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: w - 20);
    tp.paint(canvas, Offset(10, h - tp.height - 8));
    canvas.drawCircle(Offset(w - 16, 16), 4, Paint()..color = C.red);
  }

  void _corridor(Canvas c, double w, double h, Random r) {
    final vp = Offset(w * 0.5, h * 0.46);
    final p = Paint()
      ..color = C.blue.withAlpha(70)
      ..strokeWidth = 1.2;
    for (final e in [Offset(0, 0), Offset(w, 0), Offset(0, h), Offset(w, h), Offset(0, h * 0.5), Offset(w, h * 0.5)]) {
      c.drawLine(e, vp, p);
    }
    for (var i = 1; i < 6; i++) {
      final t = i / 6;
      final rr = Rect.fromCenter(center: vp, width: w * (1 - t) * 1.1, height: h * (1 - t) * 1.1);
      c.drawRect(rr, p);
    }
    c.drawRect(Rect.fromCenter(center: vp, width: w * 0.08, height: h * 0.16), Paint()..color = C.amber.withAlpha(90));
    final body = Paint()..color = const Color(0xFF05070B);
    final fx = w * 0.56;
    c.drawCircle(Offset(fx, h * 0.42), h * 0.045, body);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(fx - h * 0.05, h * 0.465, h * 0.1, h * 0.2), const Radius.circular(8)),
      body,
    );
    c.drawRect(Rect.fromLTWH(fx - 2, h * 0.47, 4, h * 0.09), Paint()..color = C.blue);
  }

  void _tower(Canvas c, double w, double h, Random r) {
    final star = Paint()..color = Colors.white.withAlpha(120);
    for (var i = 0; i < 40; i++) {
      c.drawCircle(Offset(r.nextDouble() * w, r.nextDouble() * h * 0.5), 0.8, star);
    }
    final dark = Paint()..color = const Color(0xFF04060A);
    for (var i = 0; i < 9; i++) {
      final bw = w * 0.09;
      final bh = h * (0.12 + r.nextDouble() * 0.2);
      c.drawRect(Rect.fromLTWH(i * bw * 1.1, h - bh, bw, bh), dark);
    }
    final tx = w * 0.62;
    c.drawRect(Rect.fromLTWH(tx - w * 0.02, h * 0.3, w * 0.04, h * 0.7), dark);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(tx - w * 0.09, h * 0.2, w * 0.18, h * 0.12), const Radius.circular(6)),
      dark,
    );
    c.drawRect(Rect.fromLTWH(tx - w * 0.07, h * 0.235, w * 0.14, h * 0.04), Paint()..color = C.amber.withAlpha(200));
    c.drawLine(Offset(tx, h * 0.2), Offset(tx, h * 0.1), Paint()..color = C.red..strokeWidth = 2);
    c.drawCircle(Offset(tx, h * 0.095), 3, Paint()..color = C.red);
  }

  void _desk(Canvas c, double w, double h) {
    c.drawRect(Rect.fromLTWH(0, h * 0.62, w, h * 0.38), Paint()..color = const Color(0xFF1C1710));
    c.drawRect(Rect.fromLTWH(0, h * 0.62, w, 3), Paint()..color = C.amber.withAlpha(90));
    final metal = Paint()..color = const Color(0xFF8D96A8);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.28, w * 0.16, h * 0.36), const Radius.circular(10)),
      metal,
    );
    c.drawRect(Rect.fromLTWH(w * 0.2, h * 0.28, w * 0.16, h * 0.05), Paint()..color = C.red.withAlpha(200));
    final cup = Paint()..color = const Color(0xFFE8EDF5);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.55, h * 0.46, w * 0.12, h * 0.17), const Radius.circular(6)),
      cup,
    );
    c.drawArc(Rect.fromLTWH(w * 0.65, h * 0.5, w * 0.06, h * 0.08), -pi / 2, pi, false,
        Paint()..color = cup.color..style = PaintingStyle.stroke..strokeWidth = 3);
    c.drawOval(Rect.fromLTWH(w * 0.1, h * 0.7, w * 0.8, h * 0.06), Paint()..color = Colors.black.withAlpha(90));
    c.drawCircle(Offset(w * 0.5, h * 0.22), h * 0.16, Paint()..color = C.amber.withAlpha(26));
  }

  void _room(Canvas c, double w, double h, Random r) {
    c.drawRect(Rect.fromLTWH(0, h * 0.7, w, h * 0.3), Paint()..color = const Color(0xFF10131B));
    final p = Paint()..color = C.blue.withAlpha(60);
    for (var i = 0; i < 4; i++) {
      final x = w * (0.1 + i * 0.22);
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, h * 0.3, w * 0.16, h * 0.4), const Radius.circular(4)),
        Paint()..color = const Color(0xFF0A0D14),
      );
      c.drawRect(Rect.fromLTWH(x + 6, h * 0.34, w * 0.16 - 12, h * 0.06), p);
      for (var k = 0; k < 3; k++) {
        c.drawCircle(Offset(x + 14 + k * 14, h * 0.5), 2.5, Paint()..color = [C.red, C.green, C.amber][(k + r.nextInt(3)) % 3]);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.scene != scene || old.caption != caption;
}

class _RuledPainter extends CustomPainter {
  const _RuledPainter(this.gap);
  final double gap;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = const Color(0x1A3A4A66);
    for (double y = gap; y < s.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _RuledPainter old) => false;
}

class PaperDoc extends StatelessWidget {
  const PaperDoc({super.key, required this.title, required this.content, this.note = false});
  final String title;
  final String content;
  final bool note;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF1B1B22);
    final paper = note ? const Color(0xFFF1E2A0) : const Color(0xFFE9E3D1);
    return Transform.rotate(
      angle: note ? 0.012 : 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [BoxShadow(color: Color(0xAA000000), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: CustomPaint(
          painter: const _RuledPainter(27),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, style: ts(17, color: ink, w: FontWeight.w800))),
              if (!note) const TopSecretStamp(text: 'CLASSIFIED', size: 11),
            ]),
            const Divider(color: Color(0x553A4A66), height: 22),
            Text(content, style: ts(14, color: ink, h: 1.95)),
          ]),
        ),
      ),
    );
  }
}
