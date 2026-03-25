import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routes/main_navigation.dart';
import 'services/notification_service.dart';
import 'services/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final themeColorIndex = prefs.getInt('theme_color_index') ?? 0;
  final isDarkMode = prefs.getBool('dark_mode') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        themeColorIndexProvider.overrideWith((ref) => themeColorIndex),
        isDarkModeProvider.overrideWith((ref) => isDarkMode),
      ],
      child: const XinxinPlanetApp(),
    ),
  );
}

class XinxinPlanetApp extends ConsumerWidget {
  const XinxinPlanetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColorIndex = ref.watch(themeColorIndexProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final primaryColor = AppColors.themeColors[themeColorIndex];

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(primaryColor: primaryColor),
      darkTheme: AppTheme.darkTheme(primaryColor: primaryColor),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigationPage(),
    );
  }
}
