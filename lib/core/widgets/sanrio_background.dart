import 'package:flutter/material.dart';

class SanrioBackground extends StatelessWidget {
  const SanrioBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = scheme.primary;
    final secondary = scheme.secondary;
    final tertiary = scheme.tertiary;

    Color blend(Color source, Color target, double t) =>
        Color.lerp(source, target, t)!;

    final topColor = isDark
        ? blend(primary, const Color(0xFF14121A), 0.82)
        : blend(primary, Colors.white, 0.9);
    final bottomColor = isDark
        ? blend(secondary, const Color(0xFF18131D), 0.84)
        : blend(secondary, Colors.white, 0.93);
    final dotColor = isDark
        ? blend(primary, Colors.white, 0.42).withValues(alpha: 0.2)
        : primary.withValues(alpha: 0.14);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [topColor, bottomColor],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _DotPatternPainter(color: dotColor),
            ),
          ),
        ),
        Positioned(
          top: -48,
          left: -36,
          child: _CloudBlob(
            width: 176,
            height: 124,
            color: isDark
                ? blend(primary, Colors.black, 0.55).withValues(alpha: 0.36)
                : blend(primary, Colors.white, 0.78).withValues(alpha: 0.86),
          ),
        ),
        Positioned(
          top: 98,
          right: -22,
          child: _CloudBlob(
            width: 132,
            height: 96,
            color: isDark
                ? blend(secondary, Colors.black, 0.52).withValues(alpha: 0.32)
                : blend(secondary, Colors.white, 0.76).withValues(alpha: 0.8),
          ),
        ),
        Positioned(
          bottom: 92,
          left: 10,
          child: _CloudBlob(
            width: 104,
            height: 78,
            color: isDark
                ? blend(tertiary, Colors.black, 0.58).withValues(alpha: 0.26)
                : blend(tertiary, Colors.white, 0.78).withValues(alpha: 0.72),
          ),
        ),
        Positioned(
          top: 56,
          right: 20,
          child: _Sparkle(
            icon: Icons.favorite_rounded,
            color: isDark
                ? blend(primary, Colors.white, 0.58)
                : blend(primary, const Color(0xFFC23B77), 0.38),
            size: 14,
          ),
        ),
        Positioned(
          top: 176,
          left: 34,
          child: _Sparkle(
            icon: Icons.auto_awesome_rounded,
            color: isDark
                ? blend(tertiary, Colors.white, 0.52)
                : blend(tertiary, const Color(0xFFE39A31), 0.32),
            size: 13,
          ),
        ),
        Positioned(
          bottom: 150,
          right: 26,
          child: _Sparkle(
            icon: Icons.star_rounded,
            color: isDark
                ? blend(secondary, Colors.white, 0.56)
                : blend(secondary, const Color(0xFF4A99CB), 0.36),
            size: 15,
          ),
        ),
        child,
      ],
    );
  }
}

class _CloudBlob extends StatelessWidget {
  const _CloudBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: size);
  }
}

class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const gap = 22.0;
    for (double y = 14; y < size.height; y += gap) {
      for (double x = 12; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), 1.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
