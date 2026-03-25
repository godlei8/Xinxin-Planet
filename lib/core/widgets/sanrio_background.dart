import 'package:flutter/material.dart';

class SanrioBackground extends StatelessWidget {
  const SanrioBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF1C1522), Color(0xFF241A2B)]
                    : const [Color(0xFFFFF3FA), Color(0xFFFFFEFF)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _DotPatternPainter(
                color:
                    isDark ? const Color(0x22FFFFFF) : const Color(0x22E95C96),
              ),
            ),
          ),
        ),
        Positioned(
          top: -48,
          left: -36,
          child: _CloudBlob(
            width: 176,
            height: 124,
            color: isDark ? const Color(0x334E3A56) : const Color(0x99FFE0EE),
          ),
        ),
        Positioned(
          top: 98,
          right: -22,
          child: _CloudBlob(
            width: 132,
            height: 96,
            color: isDark ? const Color(0x3341697D) : const Color(0x99DAF1FF),
          ),
        ),
        Positioned(
          bottom: 92,
          left: 10,
          child: _CloudBlob(
            width: 104,
            height: 78,
            color: isDark ? const Color(0x334E6A62) : const Color(0x99E4F9E3),
          ),
        ),
        Positioned(
          top: 56,
          right: 20,
          child: _Sparkle(
            icon: Icons.favorite_rounded,
            color: isDark ? const Color(0xCCFFC5E2) : const Color(0xFFE95C96),
            size: 14,
          ),
        ),
        Positioned(
          top: 176,
          left: 34,
          child: _Sparkle(
            icon: Icons.auto_awesome_rounded,
            color: isDark ? const Color(0xCCFFE69A) : const Color(0xFFF5B746),
            size: 13,
          ),
        ),
        Positioned(
          bottom: 150,
          right: 26,
          child: _Sparkle(
            icon: Icons.star_rounded,
            color: isDark ? const Color(0xCCBCE4FF) : const Color(0xFF77BBE7),
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
