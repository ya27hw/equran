import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:emushaf/backend/surah_model.dart';
import 'package:emushaf/home/home.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  // ----- HIVE -----
  await Hive.initFlutter();

  Hive.registerAdapter(SurahAdapter());

  await Hive.openBox("bookmarks");
  await Hive.openBox(
    "settings",
  );
  await Hive.openBox("surahs");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Box settingsBox = Hive.box("settings");
  static MaterialColor mySeed = _getPrimaryColor();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
        light: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: mySeed, brightness: Brightness.light)),
        dark: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: mySeed, brightness: Brightness.dark)),
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => MaterialApp(
          scrollBehavior:
          ScrollConfiguration.of(context).copyWith(scrollbars: false),
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: darkTheme,
              home: const HomePage(),
            ));
  }

  static MaterialColor _getPrimaryColor() {
    final colorIndex = settingsBox.get("color");
    return colorIndex != null ? Colors.primaries[colorIndex] : Colors.purple;
  }
}
