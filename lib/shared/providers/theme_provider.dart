import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/constants/app_constants.dart';

part 'theme_provider.g.dart';

/// Provider for managing app theme mode
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  static const String _themeModeKey = 'theme_mode';

  @override
  ThemeMode build() {
    final box = Hive.box(AppConstants.hivePreferencesBox);
    final savedTheme = box.get(_themeModeKey, defaultValue: 'light') as String;

    switch (savedTheme) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final box = Hive.box(AppConstants.hivePreferencesBox);

    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
      default:
        modeString = 'light';
    }

    await box.put(_themeModeKey, modeString);
    state = mode;
  }
}
