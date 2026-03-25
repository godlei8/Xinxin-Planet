import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFE95C96);
  static const Color secondaryColor = Color(0xFF89CFF0);
  static const Color accentColor = Color(0xFFFFD66B);
  static const Color backgroundColor = Color(0xFFFFF8FC);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFFF6D7A);
  static const Color successColor = Color(0xFF63C8A5);
  static const Color warningColor = Color(0xFFF5A65B);

  static const Color textPrimary = Color(0xFF5D3552);
  static const Color textSecondary = Color(0xFF8E6B84);
  static const Color textHint = Color(0xFFBFA8B7);

  static const Color greyColor = Color(0xFFB3A3B2);
  static const Color lightGrey = Color(0xFFF8EDF5);
  static const Color darkGrey = Color(0xFF755B70);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFF3F8);

  static const List<Color> themeColors = [
    Color(0xFFE95C96),
    Color(0xFFFF8FA7),
    Color(0xFF89CFF0),
    Color(0xFFA9E5D1),
    Color(0xFFFFD66B),
    Color(0xFFFFB1D4),
    Color(0xFFB5C7FF),
    Color(0xFFFFB879),
    Color(0xFF8CD9C6),
    Color(0xFFD8A7F9),
  ];

  static const List<String> themeColorCodes = [
    '#E95C96',
    '#FF8FA7',
    '#89CFF0',
    '#A9E5D1',
    '#FFD66B',
    '#FFB1D4',
    '#B5C7FF',
    '#FFB879',
    '#8CD9C6',
    '#D8A7F9',
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
