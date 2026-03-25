import 'dart:math' as math;

import 'package:flutter/material.dart';

class CutePetAvatar extends StatelessWidget {
  const CutePetAvatar({
    super.key,
    required this.speciesId,
    this.size = 120,
    this.withShadow = true,
  });

  final String speciesId;
  final double size;
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    final style = _PetStyle.of(speciesId);
    final headSize = size * 0.56;
    final bodyW = size * 0.5;
    final bodyH = size * 0.34;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (withShadow)
            Positioned(
              bottom: size * 0.04,
              child: Container(
                width: size * 0.52,
                height: size * 0.11,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ..._buildTail(style, size),
          Positioned(
            bottom: size * 0.18,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ..._buildArms(style, size),
                _buildBody(style, bodyW, bodyH),
              ],
            ),
          ),
          ..._buildLegs(style, size),
          Positioned(
            top: size * 0.04,
            child: _buildHead(style, headSize),
          ),
        ],
      ),
    );
  }

  Widget _buildHead(_PetStyle style, double headSize) {
    final faceSize = headSize * 0.46;

    return SizedBox(
      width: headSize,
      height: headSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ..._buildEars(style, headSize),
          Container(
            width: headSize,
            height: headSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [style.headTop, style.headBottom],
              ),
              boxShadow: [
                BoxShadow(
                  color: style.headBottom.withValues(alpha: 0.34),
                  blurRadius: headSize * 0.12,
                  offset: Offset(0, headSize * 0.06),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: headSize * 0.12,
                  left: headSize * 0.18,
                  child: Container(
                    width: headSize * 0.3,
                    height: headSize * 0.16,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                ..._buildHeadMarks(style, headSize),
                Positioned(
                  bottom: headSize * 0.18,
                  child: Container(
                    width: faceSize,
                    height: faceSize * 0.8,
                    decoration: BoxDecoration(
                      color: style.faceColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Positioned(
                  left: headSize * 0.29,
                  top: headSize * 0.42,
                  child: _eye(headSize),
                ),
                Positioned(
                  right: headSize * 0.29,
                  top: headSize * 0.42,
                  child: _eye(headSize),
                ),
                Positioned(
                  left: headSize * 0.22,
                  top: headSize * 0.56,
                  child: _blush(headSize, style.blushColor),
                ),
                Positioned(
                  right: headSize * 0.22,
                  top: headSize * 0.56,
                  child: _blush(headSize, style.blushColor),
                ),
                Positioned(
                  top: headSize * 0.57,
                  child: _noseMouth(headSize, style.noseColor),
                ),
                ..._buildHeadDecor(style, headSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(_PetStyle style, double bodyW, double bodyH) {
    return Container(
      width: bodyW,
      height: bodyH,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [style.bodyTop, style.bodyBottom],
        ),
        borderRadius: BorderRadius.circular(bodyW),
        boxShadow: [
          BoxShadow(
            color: style.bodyBottom.withValues(alpha: 0.22),
            blurRadius: bodyW * 0.1,
            offset: Offset(0, bodyW * 0.04),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: bodyH * 0.16,
            child: Container(
              width: bodyW * 0.44,
              height: bodyH * 0.54,
              decoration: BoxDecoration(
                color: style.bellyColor.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          ..._buildBodyMarks(style, bodyW, bodyH),
        ],
      ),
    );
  }

  List<Widget> _buildArms(_PetStyle style, double size) {
    final armW = size * 0.13;
    final armH = size * 0.2;
    if (style.isPenguinWing) {
      return [
        Positioned(
          left: size * 0.19,
          top: size * 0.03,
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              width: armW * 0.95,
              height: armH,
              decoration: BoxDecoration(
                color: style.limbColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        Positioned(
          right: size * 0.19,
          top: size * 0.03,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: armW * 0.95,
              height: armH,
              decoration: BoxDecoration(
                color: style.limbColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      Positioned(
        left: size * 0.17,
        top: size * 0.03,
        child: Transform.rotate(
          angle: -0.32,
          child: Container(
            width: armW,
            height: armH,
            decoration: BoxDecoration(
              color: style.limbColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
      Positioned(
        right: size * 0.17,
        top: size * 0.03,
        child: Transform.rotate(
          angle: 0.32,
          child: Container(
            width: armW,
            height: armH,
            decoration: BoxDecoration(
              color: style.limbColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildLegs(_PetStyle style, double size) {
    final legW = size * 0.14;
    final legH = size * 0.12;
    final footColor = style.footColor ?? style.limbColor;
    return [
      Positioned(
        left: size * 0.3,
        bottom: size * 0.08,
        child: Container(
          width: legW,
          height: legH,
          decoration: BoxDecoration(
            color: footColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      Positioned(
        right: size * 0.3,
        bottom: size * 0.08,
        child: Container(
          width: legW,
          height: legH,
          decoration: BoxDecoration(
            color: footColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildTail(_PetStyle style, double size) {
    switch (style.tailType) {
      case _TailType.none:
        return const [];
      case _TailType.short:
        return [
          Positioned(
            right: size * 0.16,
            bottom: size * 0.26,
            child: Container(
              width: size * 0.1,
              height: size * 0.1,
              decoration: BoxDecoration(
                color: style.tailColor ?? style.bodyBottom,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ];
      case _TailType.long:
        return [
          Positioned(
            right: size * 0.08,
            bottom: size * 0.22,
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                width: size * 0.24,
                height: size * 0.11,
                decoration: BoxDecoration(
                  color: style.tailColor ?? style.bodyBottom,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ];
      case _TailType.fluffy:
        return [
          Positioned(
            right: size * 0.06,
            bottom: size * 0.2,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: size * 0.28,
                height: size * 0.14,
                decoration: BoxDecoration(
                  color: style.tailColor ?? style.bodyBottom,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: size * 0.1,
                    height: size * 0.11,
                    margin: EdgeInsets.only(right: size * 0.02),
                    decoration: BoxDecoration(
                      color: style.tailTipColor ?? style.bellyColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ];
    }
  }

  List<Widget> _buildEars(_PetStyle style, double headSize) {
    final earSize = headSize * 0.26;
    switch (style.earType) {
      case _EarType.round:
        return [
          _roundEar(
            left: headSize * 0.07,
            top: -headSize * 0.05,
            earSize: earSize,
            color: style.earColor,
            innerColor: style.innerEarColor,
          ),
          _roundEar(
            left: headSize * 0.67,
            top: -headSize * 0.05,
            earSize: earSize,
            color: style.earColor,
            innerColor: style.innerEarColor,
          ),
        ];
      case _EarType.point:
        return [
          _pointEar(
            left: headSize * 0.08,
            top: -headSize * 0.1,
            earSize: earSize,
            color: style.earColor,
            innerColor: style.innerEarColor,
            flip: false,
          ),
          _pointEar(
            left: headSize * 0.66,
            top: -headSize * 0.1,
            earSize: earSize,
            color: style.earColor,
            innerColor: style.innerEarColor,
            flip: true,
          ),
        ];
      case _EarType.long:
        return [
          _longEar(
            left: headSize * 0.12,
            top: -headSize * 0.34,
            earW: headSize * 0.18,
            earH: headSize * 0.48,
            color: style.earColor,
            innerColor: style.innerEarColor,
          ),
          _longEar(
            left: headSize * 0.7,
            top: -headSize * 0.34,
            earW: headSize * 0.18,
            earH: headSize * 0.48,
            color: style.earColor,
            innerColor: style.innerEarColor,
          ),
        ];
      case _EarType.floppy:
        return [
          _floppyEar(
            left: -headSize * 0.04,
            top: headSize * 0.16,
            earW: headSize * 0.2,
            earH: headSize * 0.33,
            color: style.earColor,
            angle: -0.36,
          ),
          _floppyEar(
            left: headSize * 0.84,
            top: headSize * 0.16,
            earW: headSize * 0.2,
            earH: headSize * 0.33,
            color: style.earColor,
            angle: 0.36,
          ),
        ];
      case _EarType.tiny:
        return [
          _roundEar(
            left: headSize * 0.23,
            top: -headSize * 0.03,
            earSize: headSize * 0.15,
            color: style.earColor,
            innerColor: style.innerEarColor,
          ),
          _roundEar(
            left: headSize * 0.62,
            top: -headSize * 0.03,
            earSize: headSize * 0.15,
            color: style.earColor,
            innerColor: style.innerEarColor,
          ),
        ];
      case _EarType.none:
        return const [];
    }
  }

  List<Widget> _buildHeadMarks(_PetStyle style, double headSize) {
    if (style.speciesId != 'panda') {
      return const [];
    }
    return [
      Positioned(
        left: headSize * 0.2,
        top: headSize * 0.39,
        child: Container(
          width: headSize * 0.2,
          height: headSize * 0.14,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A42),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
      Positioned(
        right: headSize * 0.2,
        top: headSize * 0.39,
        child: Container(
          width: headSize * 0.2,
          height: headSize * 0.14,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A42),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildHeadDecor(_PetStyle style, double headSize) {
    switch (style.speciesId) {
      case 'deer':
        return [
          Positioned(
            left: headSize * 0.14,
            top: -headSize * 0.16,
            child: _antler(headSize * 0.24, false),
          ),
          Positioned(
            right: headSize * 0.14,
            top: -headSize * 0.16,
            child: _antler(headSize * 0.24, true),
          ),
        ];
      case 'penguin':
        return [
          Positioned(
            bottom: headSize * 0.2,
            child: Container(
              width: headSize * 0.12,
              height: headSize * 0.08,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB44D),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ];
      default:
        return const [];
    }
  }

  List<Widget> _buildBodyMarks(_PetStyle style, double bodyW, double bodyH) {
    if (style.speciesId == 'cat') {
      return [
        Positioned(
          top: bodyH * 0.06,
          child: Container(
            width: bodyW * 0.34,
            height: bodyH * 0.07,
            decoration: BoxDecoration(
              color: style.accentColor.withValues(alpha: 0.44),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ];
    }
    return const [];
  }

  Widget _roundEar({
    required double left,
    required double top,
    required double earSize,
    required Color color,
    required Color innerColor,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: earSize,
        height: earSize,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Container(
            width: earSize * 0.5,
            height: earSize * 0.5,
            decoration: BoxDecoration(
              color: innerColor.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pointEar({
    required double left,
    required double top,
    required double earSize,
    required Color color,
    required Color innerColor,
    required bool flip,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: flip ? 0.24 : -0.24,
        child: SizedBox(
          width: earSize,
          height: earSize,
          child: CustomPaint(
            painter: _TriangleEarPainter(color: color, innerColor: innerColor),
          ),
        ),
      ),
    );
  }

  Widget _longEar({
    required double left,
    required double top,
    required double earW,
    required double earH,
    required Color color,
    required Color innerColor,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: earW,
        height: earH,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          child: Container(
            width: earW * 0.4,
            height: earH * 0.76,
            decoration: BoxDecoration(
              color: innerColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  Widget _floppyEar({
    required double left,
    required double top,
    required double earW,
    required double earH,
    required Color color,
    required double angle,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: earW,
          height: earH,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _eye(double headSize) {
    return Container(
      width: headSize * 0.068,
      height: headSize * 0.082,
      decoration: BoxDecoration(
        color: const Color(0xFF2F2D36),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: const Alignment(-0.2, -0.2),
        child: Container(
          width: headSize * 0.017,
          height: headSize * 0.017,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _blush(double headSize, Color color) {
    return Container(
      width: headSize * 0.088,
      height: headSize * 0.04,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _noseMouth(double headSize, Color noseColor) {
    return SizedBox(
      width: headSize * 0.2,
      height: headSize * 0.13,
      child: CustomPaint(
        painter: _NoseMouthPainter(color: noseColor),
      ),
    );
  }

  Widget _antler(double size, bool flip) {
    return Transform.flip(
      flipX: flip,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _AntlerPainter(),
        ),
      ),
    );
  }
}

enum _EarType { round, point, long, floppy, tiny, none }

enum _TailType { none, short, long, fluffy }

class _PetStyle {
  const _PetStyle({
    required this.speciesId,
    required this.headTop,
    required this.headBottom,
    required this.bodyTop,
    required this.bodyBottom,
    required this.faceColor,
    required this.bellyColor,
    required this.earColor,
    required this.innerEarColor,
    required this.limbColor,
    required this.blushColor,
    required this.noseColor,
    required this.accentColor,
    required this.earType,
    required this.tailType,
    this.tailColor,
    this.tailTipColor,
    this.footColor,
    this.isPenguinWing = false,
  });

  final String speciesId;
  final Color headTop;
  final Color headBottom;
  final Color bodyTop;
  final Color bodyBottom;
  final Color faceColor;
  final Color bellyColor;
  final Color earColor;
  final Color innerEarColor;
  final Color limbColor;
  final Color blushColor;
  final Color noseColor;
  final Color accentColor;
  final _EarType earType;
  final _TailType tailType;
  final Color? tailColor;
  final Color? tailTipColor;
  final Color? footColor;
  final bool isPenguinWing;

  static _PetStyle of(String speciesId) {
    switch (speciesId) {
      case 'panda':
        return const _PetStyle(
          speciesId: 'panda',
          headTop: Color(0xFFF7F7F9),
          headBottom: Color(0xFFE7E8EE),
          bodyTop: Color(0xFFF2F2F6),
          bodyBottom: Color(0xFFDFE0E8),
          faceColor: Color(0xFFFFFFFF),
          bellyColor: Color(0xFFFFFFFF),
          earColor: Color(0xFF4E505A),
          innerEarColor: Color(0xFFAEB2C0),
          limbColor: Color(0xFF4A4C56),
          blushColor: Color(0xFFFFD8E3),
          noseColor: Color(0xFF474853),
          accentColor: Color(0xFF3B3B43),
          earType: _EarType.round,
          tailType: _TailType.short,
        );
      case 'rabbit':
        return const _PetStyle(
          speciesId: 'rabbit',
          headTop: Color(0xFFF3EEFF),
          headBottom: Color(0xFFE4DBFF),
          bodyTop: Color(0xFFEDE4FF),
          bodyBottom: Color(0xFFDCCEFF),
          faceColor: Color(0xFFFFFFFF),
          bellyColor: Color(0xFFFFF7FF),
          earColor: Color(0xFFE4D9FF),
          innerEarColor: Color(0xFFFFC7E2),
          limbColor: Color(0xFFD7C8FF),
          blushColor: Color(0xFFFFD8ED),
          noseColor: Color(0xFF6D627F),
          accentColor: Color(0xFF9C84D7),
          earType: _EarType.long,
          tailType: _TailType.short,
        );
      case 'cat':
        return const _PetStyle(
          speciesId: 'cat',
          headTop: Color(0xFFFFDFBE),
          headBottom: Color(0xFFF8CFA4),
          bodyTop: Color(0xFFF9D6B4),
          bodyBottom: Color(0xFFF1BE8C),
          faceColor: Color(0xFFFFF2E4),
          bellyColor: Color(0xFFFFEFE0),
          earColor: Color(0xFFF3C493),
          innerEarColor: Color(0xFFFFB5C9),
          limbColor: Color(0xFFE7B07A),
          blushColor: Color(0xFFFFD1D9),
          noseColor: Color(0xFF8D6E5E),
          accentColor: Color(0xFFC78556),
          earType: _EarType.point,
          tailType: _TailType.long,
          tailColor: Color(0xFFE5A872),
        );
      case 'dog':
        return const _PetStyle(
          speciesId: 'dog',
          headTop: Color(0xFFEBCBA5),
          headBottom: Color(0xFFDDB487),
          bodyTop: Color(0xFFE3BF97),
          bodyBottom: Color(0xFFD39F6E),
          faceColor: Color(0xFFF9EBDD),
          bellyColor: Color(0xFFF5E2CE),
          earColor: Color(0xFFB97F56),
          innerEarColor: Color(0xFFE2C3A8),
          limbColor: Color(0xFFC58E61),
          blushColor: Color(0xFFFFD7C9),
          noseColor: Color(0xFF765C4D),
          accentColor: Color(0xFFB97B4C),
          earType: _EarType.floppy,
          tailType: _TailType.long,
          tailColor: Color(0xFFC58A5C),
        );
      case 'fox':
        return const _PetStyle(
          speciesId: 'fox',
          headTop: Color(0xFFFFB975),
          headBottom: Color(0xFFF29C59),
          bodyTop: Color(0xFFFFB063),
          bodyBottom: Color(0xFFEE9250),
          faceColor: Color(0xFFFFF2E3),
          bellyColor: Color(0xFFFFF0DF),
          earColor: Color(0xFFF1924D),
          innerEarColor: Color(0xFFFFE7CF),
          limbColor: Color(0xFFEB954E),
          blushColor: Color(0xFFFFD7C6),
          noseColor: Color(0xFF6D5446),
          accentColor: Color(0xFFD67839),
          earType: _EarType.point,
          tailType: _TailType.fluffy,
          tailColor: Color(0xFFE98F49),
          tailTipColor: Color(0xFFFFEFD9),
        );
      case 'hamster':
        return const _PetStyle(
          speciesId: 'hamster',
          headTop: Color(0xFFFFDDB8),
          headBottom: Color(0xFFF4C18E),
          bodyTop: Color(0xFFFAD2A8),
          bodyBottom: Color(0xFFF0B987),
          faceColor: Color(0xFFFFF3E7),
          bellyColor: Color(0xFFFFEEDC),
          earColor: Color(0xFFF3B888),
          innerEarColor: Color(0xFFFFD3C0),
          limbColor: Color(0xFFE8B27C),
          blushColor: Color(0xFFFFD6D9),
          noseColor: Color(0xFF8E705D),
          accentColor: Color(0xFFD48E54),
          earType: _EarType.round,
          tailType: _TailType.none,
        );
      case 'penguin':
        return const _PetStyle(
          speciesId: 'penguin',
          headTop: Color(0xFF7382A1),
          headBottom: Color(0xFF4C5977),
          bodyTop: Color(0xFF5B6A8B),
          bodyBottom: Color(0xFF414F6D),
          faceColor: Color(0xFFF6FAFF),
          bellyColor: Color(0xFFF1F6FF),
          earColor: Color(0xFF606E8D),
          innerEarColor: Color(0xFF8493B3),
          limbColor: Color(0xFF3F4D6B),
          blushColor: Color(0xFFFFD6E1),
          noseColor: Color(0xFF5C6374),
          accentColor: Color(0xFFFFB44D),
          earType: _EarType.none,
          tailType: _TailType.none,
          footColor: Color(0xFFFFB44D),
          isPenguinWing: true,
        );
      case 'koala':
        return const _PetStyle(
          speciesId: 'koala',
          headTop: Color(0xFFC9CFDC),
          headBottom: Color(0xFFAFB8CA),
          bodyTop: Color(0xFFC1C8D8),
          bodyBottom: Color(0xFFA4AFC4),
          faceColor: Color(0xFFF8FBFF),
          bellyColor: Color(0xFFF0F4FB),
          earColor: Color(0xFFAEB7C9),
          innerEarColor: Color(0xFFDDE4F4),
          limbColor: Color(0xFFAAB3C5),
          blushColor: Color(0xFFFFD7E4),
          noseColor: Color(0xFF61697C),
          accentColor: Color(0xFF8E99B1),
          earType: _EarType.round,
          tailType: _TailType.short,
        );
      case 'deer':
        return const _PetStyle(
          speciesId: 'deer',
          headTop: Color(0xFFE5B98F),
          headBottom: Color(0xFFD29A6F),
          bodyTop: Color(0xFFDDAE82),
          bodyBottom: Color(0xFFC28A62),
          faceColor: Color(0xFFFFF1E3),
          bellyColor: Color(0xFFFFE9D4),
          earColor: Color(0xFFC98A5F),
          innerEarColor: Color(0xFFEBC1A9),
          limbColor: Color(0xFFC38860),
          blushColor: Color(0xFFFFD6D5),
          noseColor: Color(0xFF7A5C4C),
          accentColor: Color(0xFF9A7054),
          earType: _EarType.point,
          tailType: _TailType.short,
        );
      case 'alpaca':
        return const _PetStyle(
          speciesId: 'alpaca',
          headTop: Color(0xFFF8EEE2),
          headBottom: Color(0xFFECDCC9),
          bodyTop: Color(0xFFF0E3D4),
          bodyBottom: Color(0xFFE2D1BC),
          faceColor: Color(0xFFFFF7EE),
          bellyColor: Color(0xFFFFF4E7),
          earColor: Color(0xFFE6D3BF),
          innerEarColor: Color(0xFFF3E8DA),
          limbColor: Color(0xFFDCC7AE),
          blushColor: Color(0xFFFFD7DF),
          noseColor: Color(0xFF7D6C5E),
          accentColor: Color(0xFFBEA78C),
          earType: _EarType.tiny,
          tailType: _TailType.none,
        );
      default:
        return of('rabbit');
    }
  }
}

class _TriangleEarPainter extends CustomPainter {
  const _TriangleEarPainter({
    required this.color,
    required this.innerColor,
  });

  final Color color;
  final Color innerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(outer, Paint()..color = color);

    final inner = Path()
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.24, size.height * 0.88)
      ..lineTo(size.width * 0.76, size.height * 0.88)
      ..close();
    canvas.drawPath(inner, Paint()..color = innerColor.withValues(alpha: 0.84));
  }

  @override
  bool shouldRepaint(covariant _TriangleEarPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.innerColor != innerColor;
  }
}

class _NoseMouthPainter extends CustomPainter {
  const _NoseMouthPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final nose = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.28),
      size.width * 0.12,
      nose,
    );

    final mouth = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.1, size.width * 0.045)
      ..strokeCap = StrokeCap.round;

    final left = Path()
      ..moveTo(size.width * 0.5, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.72,
        size.width * 0.24,
        size.height * 0.58,
      );
    final right = Path()
      ..moveTo(size.width * 0.5, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.72,
        size.width * 0.76,
        size.height * 0.58,
      );
    canvas.drawPath(left, mouth);
    canvas.drawPath(right, mouth);
  }

  @override
  bool shouldRepaint(covariant _NoseMouthPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _AntlerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF926F58)
      ..strokeWidth = size.width * 0.14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.95),
      Offset(size.width * 0.5, size.height * 0.15),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.17, size.height * 0.35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.2, size.height * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
