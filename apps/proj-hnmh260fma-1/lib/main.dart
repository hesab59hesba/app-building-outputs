import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'spot_store.dart';

void main() {
  runApp(CarSpotApp(store: SpotStore()));
}

class CarSpotApp extends StatelessWidget {
  const CarSpotApp({super.key, required this.store});

  final SpotStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarSpot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(store: store),
    );
  }
}
