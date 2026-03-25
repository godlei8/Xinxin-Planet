import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFFF8FA3);
  static const Color secondaryColor = Color(0xFF8FDCC8);
  static const Color accentColor = Color(0xFFFFD97D);
  static const Color backgroundColor = Color(0xFFFFFBF8);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF62C7A6);
  static const Color warningColor = Color(0xFFF5A65B);

  static const Color textPrimary = Color(0xFF4D4456);
  static const Color textSecondary = Color(0xFF8A8293);
  static const Color textHint = Color(0xFFB5AFBF);

  static const Color greyColor = Color(0xFFAAA3B5);
  static const Color lightGrey = Color(0xFFF3EDF4);
  static const Color darkGrey = Color(0xFF655E6F);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFF4F1);

  static const List<Color> themeColors = [
    Color(0xFFFF8FA3),
    Color(0xFFFFB86C),
    Color(0xFF8FDCC8),
    Color(0xFF7DB8FF),
    Color(0xFFC7A6FF),
    Color(0xFFF7A8D7),
    Color(0xFFFFD97D),
    Color(0xFF74D3AE),
    Color(0xFFA9B6FF),
    Color(0xFF9BCB6B),
  ];

  static const List<String> themeColorCodes = [
    '#FF8FA3',
    '#FFB86C',
    '#8FDCC8',
    '#7DB8FF',
    '#C7A6FF',
    '#F7A8D7',
    '#FFD97D',
    '#74D3AE',
    '#A9B6FF',
    '#9BCB6B',
  ];

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}
