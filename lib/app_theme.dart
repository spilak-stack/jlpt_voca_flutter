import 'package:flutter/material.dart';


class AppTheme extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const AppTheme({
    super.key,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static AppTheme of(BuildContext context) {
    final AppTheme? result =
        context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(result != null, 'No AppTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}