import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../preferences/app_preferences.dart';
import '../../services/notification_service.dart';

class AppBootstrapData {
  const AppBootstrapData({
    required this.preferences,
    required this.themeColorIndex,
    required this.isDarkMode,
  });

  final AppPreferencesRepository preferences;
  final int themeColorIndex;
  final bool isDarkMode;
}

Future<AppBootstrapData> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await NotificationService.initialize();

  final preferences = await AppPreferencesRepository.create();
  final snapshot = preferences.loadSnapshot();

  return AppBootstrapData(
    preferences: preferences,
    themeColorIndex: snapshot.themeColorIndex,
    isDarkMode: snapshot.isDarkMode,
  );
}
