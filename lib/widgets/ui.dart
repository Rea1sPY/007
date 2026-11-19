import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'effects.dart';

Route<T> fxRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(c),
            child: child,
          ),
        );
      },
    );

Route<T> openRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => AnimatedBuilder(
        animation: a,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(a.value);
          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX((1 - t) * 0.5);
          return Opacity(
            opacity: t,
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: m,
              child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
            ),
          );
        },
      ),
    );

class _Corners extends CustomPainter {
  const _Corners(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const l = 12.0;
    void c(double x, double y, double dx, double dy) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * l, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * l), p);
    }

    c(0, 0, 1, 1);
    c(s.width, 0, -1, 1);
    c(0, s.height, 1, -1);
    c(s.width, s.height, -1, -1);
  }

  @override
  bool shouldRepaint(covariant _Corners old) => old.color != color;
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.onTap,
    this.margin,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final a = accent ?? C.line2;
    final body = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: C.panel.withAlpha(235),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent == null ? C.line : a.withAlpha(120)),
        boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: CustomPaint(
        foregroundPainter: _Corners(accent == null ? C.line2 : a),
        child: Padding(padding: padding, child: child),
      ),
    );
    if (onTap == null) return body;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: body);
  }
}

enum BtnKind { primary, ghost, danger }

class AppBtn extends StatefulWidget {
  const AppBtn(
    this.label, {
    super.key,
    this.onTap,
    this.icon,
    this.kind = BtnKind.primary,
    this.expand = true,
    this.height = 52,
  });
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final BtnKind kind;
  final bool expand;
  final double height;

  @override
  State<AppBtn> createState() => _AppBtnState();
}

class _AppBtnState extends State<AppBtn> {
  bool _down = false;
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    final ghost = widget.kind == BtnKind.ghost;
    final base = ghost ? C.blue : C.red;
    Color bg;
    if (!on) {
      bg = C.panel;
    } else if (ghost) {
      bg = _down || _hover ? C.line : C.panel2;
    } else if (_down) {
      bg = Color.alphaBlend(Colors.black.withAlpha(70), base);
    } else if (_hover) {
      bg = Color.alphaBlend(Colors.white.withAlpha(25), base);
    } else {
      bg = base;
    }
    final fg = !on ? C.dim : (ghost ? C.blue : Colors.white);
    final border = _focus
        ? Colors.white
        : !on
            ? C.line
            : ghost
                ? C.blue.withAlpha(140)
                : base;
    Widget body = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: _focus ? 2 : 1),
        boxShadow: on && !ghost ? [BoxShadow(color: base.withAlpha(70), blurRadius: 20)] : null,
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20, color: fg),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts(15, color: fg, w: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (on && widget.kind == BtnKind.primary) body = LightSweep(child: body);
    return FocusableActionDetector(
      enabled: on,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focus = v),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: on ? (_) => setState(() => _down = true) : null,
        onTapUp: on ? (_) => setState(() => _down = false) : null,
        onTapCancel: on ? () => setState(() => _down = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.97 : 1,
          duration: const Duration(milliseconds: 160),
          child: body,
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.color = C.blue, this.icon});
  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withAlpha(28),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(110)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(text, style: ts(11, color: color, w: FontWeight.w600)),
        ]),
      );
}

class SecTitle extends StatelessWidget {
  const SecTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Row(children: [
          Container(width: 3, height: 16, color: C.red),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: ts(16, w: FontWeight.w700))),
          if (trailing != null) trailing!,
        ]),
      );
}

class Stage extends StatelessWidget {
  const Stage({
    super.key,
    required this.child,
    this.title,
    this.actions = const [],
    this.back = true,
  });
  final Widget child;
  final String? title;
  final List<Widget> actions;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Backdrop(
        child: SafeArea(
          child: Column(
            children: [
              if (title != null)
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
                  child: Row(children: [
                    if (back && Navigator.of(context).canPop())
                      IconButton(
                        tooltip: 'بازگشت',
                        icon: const Icon(Icons.arrow_back, color: C.text),
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    else
                      const SizedBox(width: 16),
                    Expanded(child: GlitchEffect(child: Text(title!, style: ts(18, w: FontWeight.w700)))),
                    ...actions,
                  ]),
                ),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

void snack(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

Future<bool> confirm(BuildContext context, String title, String body,
    {String yes = 'تأیید', String no = 'انصراف'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: C.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: C.line2),
      ),
      title: Text(title, style: ts(17, w: FontWeight.w700)),
      content: Text(body, style: ts(14, color: C.muted, h: 1.6)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(no, style: ts(14, color: C.muted))),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(yes, style: ts(14, color: C.red, w: FontWeight.w700))),
      ],
    ),
  );
  return r ?? false;
}
