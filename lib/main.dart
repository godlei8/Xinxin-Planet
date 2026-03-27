import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap/app_bootstrap.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'routes/main_navigation.dart';
import 'services/providers.dart';

Future<void> main() async {
  final bootstrapData = await bootstrapApplication();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesRepositoryProvider
            .overrideWith((ref) => bootstrapData.preferences),
        themeColorIndexProvider
            .overrideWith((ref) => bootstrapData.themeColorIndex),
        isDarkModeProvider.overrideWith((ref) => bootstrapData.isDarkMode),
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
