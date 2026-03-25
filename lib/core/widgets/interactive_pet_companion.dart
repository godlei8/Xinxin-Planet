import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum PetType {
  bunny,
  cat,
  bear,
  fox,
  puppy,
  panda,
  chick,
  deer,
}

extension PetTypeX on PetType {
  String get id => name;

  String get label {
    switch (this) {
      case PetType.bunny:
        return '\u68c9\u82b1\u5154';
      case PetType.cat:
        return '\u5976\u6cb9\u732b';
      case PetType.bear:
        return '\u53ef\u53ef\u718a';
      case PetType.fox:
        return '\u7126\u7cd6\u72d0';
      case PetType.puppy:
        return '\u5e03\u4e01\u72d7';
      case PetType.panda:
        return '\u56e2\u56e2\u718a\u732b';
      case PetType.chick:
        return '\u5143\u6c14\u5c0f\u9e21';
      case PetType.deer:
        return '\u661f\u5149\u5c0f\u9e7f';
    }
  }

  String get hint {
    switch (this) {
      case PetType.bunny:
        return '\u4f1a\u8f7b\u8f7b\u8df3\u8d77\u6765\uff0c\u966a\u4f60\u5f00\u59cb\u4eca\u5929\u3002';
      case PetType.cat:
        return '\u70b9\u4e00\u70b9\u4f1a\u772f\u773c\u6492\u5a07\uff0c\u62d6\u52a8\u4f1a\u8ddf\u7740\u667a\u5b50\u3002';
      case PetType.bear:
        return '\u8f6f\u4e4e\u4e4e\u5730\u5b88\u7740\u4f60\uff0c\u628a\u6bcf\u4e00\u6b65\u90fd\u53d8\u5f97\u7a33\u4e00\u70b9\u3002';
      case PetType.fox:
        return '\u7075\u5de7\u53c8\u4eae\u773c\uff0c\u9002\u5408\u966a\u4f60\u51b2\u4e00\u628a\u72b6\u6001\u3002';
      case PetType.puppy:
        return '\u770b\u5230\u4f60\u884c\u52a8\u5c31\u4f1a\u5f00\u5fc3\u6447\u5c3e\u5df4\u3002';
      case PetType.panda:
        return '\u6162\u6162\u6765\u6ca1\u5173\u7cfb\uff0c\u5b83\u6700\u4f1a\u966a\u4eba\u7a33\u5b9a\u575a\u6301\u3002';
      case PetType.chick:
        return '\u5c0f\u5c0f\u4e00\u53ea\uff0c\u4f46\u5f88\u4f1a\u7ed9\u4f60\u6253\u6c14\u3002';
      case PetType.deer:
        return '\u8f7b\u76c8\u5b89\u9759\uff0c\u50cf\u628a\u4eca\u5929\u53d8\u5f97\u66f4\u67d4\u548c\u3002';
    }
  }

  List<String> get encouragements {
    switch (this) {
      case PetType.bunny:
        return const [
          '\u5c0f\u6b65\u4e5f\u7b97\u8fdb\u6b65\u54e6\u3002',
          '\u5148\u5b8c\u6210\u4e00\u70b9\u70b9\uff0c\u4eca\u5929\u5c31\u4eae\u4e86\u3002',
          '\u4f60\u5df2\u7ecf\u5728\u8ba4\u771f\u751f\u6d3b\u4e86\u3002',
        ];
      case PetType.cat:
        return const [
          '\u6162\u6162\u6765\uff0c\u4e5f\u662f\u5728\u524d\u8fdb\u3002',
          '\u4f60\u505a\u5f97\u6bd4\u60f3\u8c61\u4e2d\u66f4\u597d\u3002',
          '\u7ed9\u4eca\u5929\u4e00\u4e2a\u8f7b\u8f7b\u7684\u5f00\u59cb\u5427\u3002',
        ];
      case PetType.bear:
        return const [
          '\u7a33\u7a33\u505a\u5b8c\u4e00\u4ef6\u4e8b\uff0c\u5c31\u5f88\u5389\u5bb3\u3002',
          '\u4e0d\u7740\u6025\uff0c\u4f60\u6709\u81ea\u5df1\u7684\u8282\u594f\u3002',
          '\u7ee7\u7eed\u4e00\u70b9\u70b9\uff0c\u72b6\u6001\u4f1a\u56de\u6765\u3002',
        ];
      case PetType.fox:
        return const [
          '\u73b0\u5728\u51fa\u53d1\uff0c\u4eca\u5929\u4f1a\u5f88\u987a\u3002',
          '\u4f60\u5df2\u7ecf\u51c6\u5907\u597d\u4e86\uff0c\u53bb\u8bd5\u8bd5\u770b\u3002',
          '\u8fd9\u4e00\u5c0f\u6b65\uff0c\u4f1a\u628a\u597d\u8fd0\u5e26\u8d77\u6765\u3002',
        ];
      case PetType.puppy:
        return const [
          '\u51b2\u5440\uff0c\u6211\u5728\u65c1\u8fb9\u7ed9\u4f60\u52a0\u6cb9\u3002',
          '\u505a\u5b8c\u8fd9\u4e00\u4ef6\uff0c\u5c31\u503c\u5f97\u5f00\u5fc3\u3002',
          '\u4f60\u884c\u52a8\u8d77\u6765\u7684\u6837\u5b50\u5f88\u95ea\u4eae\u3002',
        ];
      case PetType.panda:
        return const [
          '\u522b\u6025\uff0c\u7a33\u5b9a\u5c31\u662f\u8d85\u80fd\u529b\u3002',
          '\u4f60\u4eca\u5929\u4e5f\u6709\u5728\u8ba4\u771f\u575a\u6301\u3002',
          '\u8f7b\u8f7b\u505a\u4e0b\u53bb\uff0c\u5c31\u4f1a\u770b\u5230\u6210\u679c\u3002',
        ];
      case PetType.chick:
        return const [
          '\u55e8\u557e\uff0c\u4eca\u5929\u4e5f\u8981\u5143\u6c14\u4e00\u70b9\u3002',
          '\u5148\u505a\u6700\u5c0f\u7684\u4e00\u6b65\u5427\u3002',
          '\u4f60\u6bd4\u6628\u5929\u53c8\u66f4\u9760\u8fd1\u76ee\u6807\u4e86\u3002',
        ];
      case PetType.deer:
        return const [
          '\u628a\u4eca\u5929\u8fc7\u6e29\u67d4\u4e00\u70b9\u4e5f\u5f88\u597d\u3002',
          '\u5b89\u9759\u524d\u8fdb\uff0c\u672c\u8eab\u5c31\u5f88\u6709\u529b\u91cf\u3002',
          '\u6bcf\u4e00\u4efd\u4e13\u6ce8\uff0c\u90fd\u4f1a\u7559\u4e0b\u5149\u3002',
        ];
    }
  }

  static PetType fromId(String value) {
    return PetType.values.firstWhere(
      (type) => type.id == value,
      orElse: () => PetType.bunny,
    );
  }
}

class PetCompanionCard extends StatelessWidget {
  const PetCompanionCard({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.size = 150,
    this.compact = false,
    this.padding,
    this.interactive = false,
  });

  final PetType type;
  final String? title;
  final String? subtitle;
  final double size;
  final bool compact;
  final EdgeInsetsGeometry? padding;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final config = _PetConfig.fromType(type);

    return Container(
      padding: padding ?? EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.cardStart,
            config.cardEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: config.shadowColor.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: compact
          ? Row(
              children: [
                interactive
                    ? InteractivePetCompanion(
                        type: type,
                        size: size,
                        enableInteraction: true,
                        showBubble: true,
                      )
                    : PetAvatarPreview(type: type, size: size),
                const SizedBox(width: 12),
                Expanded(
                  child: _PetTexts(
                    type: type,
                    title: title,
                    subtitle: subtitle,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                interactive
                    ? InteractivePetCompanion(
                        type: type,
                        size: size,
                        enableInteraction: true,
                        showBubble: true,
                      )
                    : PetAvatarPreview(type: type, size: size),
                const SizedBox(height: 10),
                _PetTexts(
                  type: type,
                  title: title,
                  subtitle: subtitle,
                  centered: true,
                ),
              ],
            ),
    );
  }
}

class PetAvatarPreview extends StatelessWidget {
  const PetAvatarPreview({
    super.key,
    required this.type,
    this.size = 72,
  });

  final PetType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = _PetConfig.fromType(type);
    return SizedBox(
      width: size,
      height: size,
      child: ClipRect(
        child: _PetBody(
          type: type,
          config: config,
          size: size,
        ),
      ),
    );
  }
}

class _PetTexts extends StatelessWidget {
  const _PetTexts({
    required this.type,
    this.title,
    this.subtitle,
    this.centered = false,
  });

  final PetType type;
  final String? title;
  final String? subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.left;
    final resolvedTitle = title ?? type.label;
    final resolvedSubtitle = subtitle;

    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          resolvedTitle,
          textAlign: align,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        if (resolvedSubtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            resolvedSubtitle,
            textAlign: align,
            maxLines: centered ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class InteractivePetCompanion extends StatefulWidget {
  const InteractivePetCompanion({
    super.key,
    required this.type,
    this.size = 150,
    this.enableInteraction = true,
    this.showBubble = true,
  });

  final PetType type;
  final double size;
  final bool enableInteraction;
  final bool showBubble;

  @override
  State<InteractivePetCompanion> createState() =>
      _InteractivePetCompanionState();
}

class _InteractivePetCompanionState extends State<InteractivePetCompanion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _random = math.Random();
  final GlobalKey _anchorKey = GlobalKey();
  static const double _bubbleSafeMargin = 10;
  Timer? _bubbleTimer;
  OverlayEntry? _bubbleEntry;
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      lowerBound: 0.96,
      upperBound: 1.08,
      value: 1,
    );
  }

  @override
  void dispose() {
    _hideBubble();
    _controller.dispose();
    super.dispose();
  }

  void _hideBubble() {
    _bubbleTimer?.cancel();
    _bubbleTimer = null;
    _bubbleEntry?.remove();
    _bubbleEntry = null;
  }

  void _showBubble({
    required String text,
    required Color color,
  }) {
    if (!widget.showBubble || !mounted) {
      return;
    }

    _hideBubble();

    final anchorContext = _anchorKey.currentContext;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (anchorContext == null || overlay == null) {
      return;
    }

    final anchorBox = anchorContext.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (anchorBox == null ||
        !anchorBox.hasSize ||
        overlayBox == null ||
        !overlayBox.hasSize) {
      return;
    }

    final anchorOffset =
        anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final bubbleMaxWidth = math.max(widget.size * 2.0, 160.0);
    final bubbleWidth = bubbleMaxWidth
        .clamp(
          140.0,
          overlayBox.size.width - _bubbleSafeMargin * 2,
        )
        .toDouble();
    final estimatedLines = (text.length / 8).ceil().clamp(1, 3).toDouble();
    final estimatedHeight = 18.0 + estimatedLines * 18.0;
    final top = (anchorOffset.dy - estimatedHeight - 16.0).clamp(
      _bubbleSafeMargin,
      overlayBox.size.height - estimatedHeight - _bubbleSafeMargin,
    );
    final left =
        (anchorOffset.dx + anchorBox.size.width / 2 - bubbleWidth / 2).clamp(
      _bubbleSafeMargin,
      overlayBox.size.width - bubbleWidth - _bubbleSafeMargin,
    );

    _bubbleEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: IgnorePointer(
          child: Material(
            color: Colors.transparent,
            child: _PetBubble(
              color: color,
              text: text,
              width: bubbleWidth,
            ),
          ),
        ),
      ),
    );

    overlay.insert(_bubbleEntry!);
    _bubbleTimer = Timer(const Duration(milliseconds: 1800), _hideBubble);
  }

  Future<void> _handleTap() async {
    if (!widget.enableInteraction) {
      return;
    }

    final messages = widget.type.encouragements;
    final config = _PetConfig.fromType(widget.type);
    final text = messages[_random.nextInt(messages.length)];
    _showBubble(text: text, color: config.bubbleColor);

    await _controller.forward();
    await _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = _PetConfig.fromType(widget.type);

    return GestureDetector(
      behavior: widget.enableInteraction
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      onTap: widget.enableInteraction ? _handleTap : null,
      onPanUpdate: widget.enableInteraction
          ? (details) {
              setState(() {
                _tiltY = (_tiltY + details.delta.dx * 0.01).clamp(-0.3, 0.3);
                _tiltX = (_tiltX - details.delta.dy * 0.01).clamp(-0.22, 0.22);
              });
            }
          : null,
      onPanEnd: widget.enableInteraction
          ? (_) {
              setState(() {
                _tiltX = 0;
                _tiltY = 0;
              });
            }
          : null,
      child: SizedBox(
        key: _anchorKey,
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_tiltX)
                    ..rotateY(_tiltY)
                    ..scaleByDouble(
                      _controller.value,
                      _controller.value,
                      1,
                      1,
                    ),
                  child: child,
                );
              },
              child: _PetBody(
                type: widget.type,
                config: config,
                size: widget.size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetBubble extends StatelessWidget {
  const _PetBubble({
    required this.color,
    required this.text,
    required this.width,
  });

  final Color color;
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4E4956),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _PetBody extends StatelessWidget {
  const _PetBody({
    required this.type,
    required this.config,
    required this.size,
  });

  final PetType type;
  final _PetConfig config;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: size * 0.06,
            child: Container(
              width: size * 0.5,
              height: size * 0.11,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * 0.1,
            child: Container(
              width: size * 0.76,
              height: size * 0.76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    config.cardStart.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size * 0.03,
            child: _PetEar(
              type: type,
              color: config.baseColor,
              innerColor: config.innerColor,
              size: size,
              left: true,
            ),
          ),
          Positioned(
            top: size * 0.03,
            child: _PetEar(
              type: type,
              color: config.baseColor,
              innerColor: config.innerColor,
              size: size,
              left: false,
            ),
          ),
          Positioned(
            top: size * 0.12,
            child: Container(
              width: size * 0.68,
              height: size * 0.62,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    config.baseColor,
                    config.shadowColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(size * 0.3),
                boxShadow: [
                  BoxShadow(
                    color: config.shadowColor.withValues(alpha: 0.26),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: size * 0.15,
            left: size * 0.26,
            child: Container(
              width: size * 0.17,
              height: size * 0.11,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(size * 0.08),
              ),
            ),
          ),
          Positioned(
            top: size * 0.3,
            child: Container(
              width: size * 0.44,
              height: size * 0.29,
              decoration: BoxDecoration(
                color: config.faceColor,
                borderRadius: BorderRadius.circular(size * 0.18),
              ),
            ),
          ),
          Positioned(
            top: size * 0.33,
            left: size * 0.32,
            child: _eye(size),
          ),
          Positioned(
            top: size * 0.33,
            right: size * 0.32,
            child: _eye(size),
          ),
          Positioned(
            top: size * 0.39,
            child: Container(
              width: size * 0.085,
              height: size * 0.06,
              decoration: BoxDecoration(
                color: const Color(0xFF544A55),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * 0.46,
            child: Container(
              width: size * 0.15,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF544A55),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(
            top: size * 0.39,
            left: size * 0.23,
            child: _blush(size),
          ),
          Positioned(
            top: size * 0.39,
            right: size * 0.23,
            child: _blush(size),
          ),
          Positioned(
            bottom: size * 0.16,
            left: size * 0.29,
            child: _paw(size),
          ),
          Positioned(
            bottom: size * 0.16,
            right: size * 0.29,
            child: _paw(size),
          ),
          Positioned(
            bottom: size * 0.02,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size * 0.08,
                vertical: size * 0.035,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              child: Icon(
                config.accessoryIcon,
                size: size * 0.16,
                color: config.accessoryColor,
              ),
            ),
          ),
          Positioned(
            right: size * 0.12,
            top: size * 0.2,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: size * 0.11,
              color: config.sparkleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(double size) {
    return Stack(
      children: [
        Container(
          width: size * 0.05,
          height: size * 0.07,
          decoration: BoxDecoration(
            color: const Color(0xFF453C46),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Positioned(
          top: size * 0.01,
          left: size * 0.012,
          child: Container(
            width: size * 0.016,
            height: size * 0.016,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _blush(double size) {
    return Container(
      width: size * 0.08,
      height: size * 0.045,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _paw(double size) {
    return Container(
      width: size * 0.11,
      height: size * 0.07,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(size * 0.06),
      ),
    );
  }
}

class _PetEar extends StatelessWidget {
  const _PetEar({
    required this.type,
    required this.color,
    required this.innerColor,
    required this.size,
    required this.left,
  });

  final PetType type;
  final Color color;
  final Color innerColor;
  final double size;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final angle = left ? -0.28 : 0.28;
    final width = switch (type) {
      PetType.bunny => size * 0.16,
      PetType.cat => size * 0.16,
      PetType.bear => size * 0.14,
      PetType.fox => size * 0.18,
      PetType.puppy => size * 0.18,
      PetType.panda => size * 0.15,
      PetType.chick => size * 0.13,
      PetType.deer => size * 0.15,
    };
    final height = switch (type) {
      PetType.bunny => size * 0.34,
      PetType.cat => size * 0.18,
      PetType.bear => size * 0.14,
      PetType.fox => size * 0.2,
      PetType.puppy => size * 0.2,
      PetType.panda => size * 0.14,
      PetType.chick => size * 0.12,
      PetType.deer => size * 0.26,
    };
    final radius = switch (type) {
      PetType.bunny => BorderRadius.circular(size * 0.12),
      PetType.bear => BorderRadius.circular(size * 0.2),
      PetType.panda => BorderRadius.circular(size * 0.2),
      PetType.chick => BorderRadius.circular(size * 0.08),
      PetType.deer => BorderRadius.circular(size * 0.06),
      _ => BorderRadius.circular(size * 0.08),
    };

    return Transform.translate(
      offset: Offset(left ? -size * 0.14 : size * 0.14, 0),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: radius,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: size * 0.018),
              width: width * 0.48,
              height: height * 0.55,
              decoration: BoxDecoration(
                color: innerColor,
                borderRadius: radius,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PetConfig {
  const _PetConfig({
    required this.baseColor,
    required this.shadowColor,
    required this.innerColor,
    required this.faceColor,
    required this.cardStart,
    required this.cardEnd,
    required this.accessoryIcon,
    required this.accessoryColor,
    required this.bubbleColor,
    required this.sparkleColor,
  });

  final Color baseColor;
  final Color shadowColor;
  final Color innerColor;
  final Color faceColor;
  final Color cardStart;
  final Color cardEnd;
  final IconData accessoryIcon;
  final Color accessoryColor;
  final Color bubbleColor;
  final Color sparkleColor;

  factory _PetConfig.fromType(PetType type) {
    switch (type) {
      case PetType.bunny:
        return const _PetConfig(
          baseColor: Color(0xFFF7F2FF),
          shadowColor: Color(0xFFD9CBFF),
          innerColor: Color(0xFFFFC8D7),
          faceColor: Color(0xFFFFFFFF),
          cardStart: Color(0xFFFFFBFE),
          cardEnd: Color(0xFFF4ECFF),
          accessoryIcon: Icons.local_florist_rounded,
          accessoryColor: Color(0xFFFF93AF),
          bubbleColor: Color(0xFFFFF2F7),
          sparkleColor: Color(0xFFFFB1C5),
        );
      case PetType.cat:
        return const _PetConfig(
          baseColor: Color(0xFFFFF1DC),
          shadowColor: Color(0xFFF0C98F),
          innerColor: Color(0xFFFFD7BF),
          faceColor: Color(0xFFFFFCF7),
          cardStart: Color(0xFFFFFAF1),
          cardEnd: Color(0xFFFFEED6),
          accessoryIcon: Icons.nightlight_round,
          accessoryColor: Color(0xFF7565FF),
          bubbleColor: Color(0xFFFFF7ED),
          sparkleColor: Color(0xFFFFC784),
        );
      case PetType.bear:
        return const _PetConfig(
          baseColor: Color(0xFFE9D5C7),
          shadowColor: Color(0xFFC59F89),
          innerColor: Color(0xFFF6E7DD),
          faceColor: Color(0xFFFFF9F5),
          cardStart: Color(0xFFFFF8F3),
          cardEnd: Color(0xFFF4E5D9),
          accessoryIcon: Icons.favorite_rounded,
          accessoryColor: Color(0xFFFF8EA8),
          bubbleColor: Color(0xFFFFF2EC),
          sparkleColor: Color(0xFFFFBE9C),
        );
      case PetType.fox:
        return const _PetConfig(
          baseColor: Color(0xFFFFCB95),
          shadowColor: Color(0xFFF29D4C),
          innerColor: Color(0xFFFFE3C5),
          faceColor: Color(0xFFFFFAF4),
          cardStart: Color(0xFFFFF7EF),
          cardEnd: Color(0xFFFFE8D2),
          accessoryIcon: Icons.auto_awesome_rounded,
          accessoryColor: Color(0xFF66C8A7),
          bubbleColor: Color(0xFFFFF4E8),
          sparkleColor: Color(0xFFFFB968),
        );
      case PetType.puppy:
        return const _PetConfig(
          baseColor: Color(0xFFF6DFC4),
          shadowColor: Color(0xFFD9AF84),
          innerColor: Color(0xFFFFE8CF),
          faceColor: Color(0xFFFFFBF7),
          cardStart: Color(0xFFFFFAF4),
          cardEnd: Color(0xFFF9E8D7),
          accessoryIcon: Icons.pets_rounded,
          accessoryColor: Color(0xFF5ABAA0),
          bubbleColor: Color(0xFFFFF3E8),
          sparkleColor: Color(0xFFFFC56F),
        );
      case PetType.panda:
        return const _PetConfig(
          baseColor: Color(0xFFF1F3F7),
          shadowColor: Color(0xFFD1D6E0),
          innerColor: Color(0xFFE5EAF4),
          faceColor: Color(0xFFFFFFFF),
          cardStart: Color(0xFFFFFFFF),
          cardEnd: Color(0xFFF0F4FA),
          accessoryIcon: Icons.eco_rounded,
          accessoryColor: Color(0xFF7BB494),
          bubbleColor: Color(0xFFF5F8FD),
          sparkleColor: Color(0xFFA6B8D2),
        );
      case PetType.chick:
        return const _PetConfig(
          baseColor: Color(0xFFFFE887),
          shadowColor: Color(0xFFFFC94A),
          innerColor: Color(0xFFFFF4C8),
          faceColor: Color(0xFFFFFBED),
          cardStart: Color(0xFFFFFCF1),
          cardEnd: Color(0xFFFFF0BE),
          accessoryIcon: Icons.wb_sunny_rounded,
          accessoryColor: Color(0xFFFFA842),
          bubbleColor: Color(0xFFFFF9E6),
          sparkleColor: Color(0xFFFFD263),
        );
      case PetType.deer:
        return const _PetConfig(
          baseColor: Color(0xFFF0D9C7),
          shadowColor: Color(0xFFD3B095),
          innerColor: Color(0xFFFFECDD),
          faceColor: Color(0xFFFFFAF7),
          cardStart: Color(0xFFFFFBF7),
          cardEnd: Color(0xFFF6E8DE),
          accessoryIcon: Icons.stars_rounded,
          accessoryColor: Color(0xFF8A7BFF),
          bubbleColor: Color(0xFFFFF3EE),
          sparkleColor: Color(0xFFB7A5FF),
        );
    }
  }
}

class PetSelectorCard extends StatelessWidget {
  const PetSelectorCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final PetType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = _PetConfig.fromType(type);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [config.cardStart, config.cardEnd]
                  : [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.92),
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.2),
              width: selected ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? config.shadowColor.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: selected ? 18 : 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Spacer(),
                  _SelectorStateChip(selected: selected),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: selected ? 0.22 : 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: PetAvatarPreview(
                    type: type,
                    size: 68,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                type.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: selected ? scheme.primary : null,
                    ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  type.hint,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.84),
                      ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selected
                      ? '\u5f53\u524d\u966a\u4f34'
                      : '\u70b9\u51fb\u5207\u6362',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected ? scheme.primary : scheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorStateChip extends StatelessWidget {
  const _SelectorStateChip({
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        selected ? '\u5df2\u9009\u4e2d' : '\u53ef\u5207\u6362',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color.withValues(alpha: selected ? 1 : 0.78),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
