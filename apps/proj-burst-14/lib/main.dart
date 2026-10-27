import 'package:flutter/material.dart';

import 'clock_page.dart';

void main() {
  runApp(const ChessClockApp());
}

class ChessClockApp extends StatelessWidget {
  const ChessClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const ClockPage(),
    );
  }
}
