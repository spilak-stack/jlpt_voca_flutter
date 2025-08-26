import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'main_page.dart';
import 'json_shuffle.dart';

void main() {
  runApp(const MyApp());
  jsonInitShuffle(5);
  jsonInitShuffle(4);
  jsonInitShuffle(3);
  jsonInitShuffle(2);
  jsonInitShuffle(1);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
        themeMode: _themeMode,
        toggleTheme: _toggleTheme,
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF002A32),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF002A32),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: _themeMode,
          home: MainPage(toggleTheme: _toggleTheme),
          debugShowCheckedModeBanner: false,
        ));
  }
}
