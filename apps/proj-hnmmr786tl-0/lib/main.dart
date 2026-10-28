import 'package:flutter/material.dart';

import 'package:clock_app/alarms_tab.dart';
import 'package:clock_app/stopwatch_tab.dart';
import 'package:clock_app/timer_tab.dart';
import 'package:clock_app/world_clock_tab.dart';

void main() {
  runApp(const ClockApp());
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF4355B9);
    return MaterialApp(
      title: 'Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: const ClockHomePage(),
    );
  }
}

class ClockHomePage extends StatefulWidget {
  const ClockHomePage({super.key});

  @override
  State<ClockHomePage> createState() => _ClockHomePageState();
}

class _ClockHomePageState extends State<ClockHomePage> {
  int _tab = 0;

  static const List<Widget> _tabs = [
    WorldClockTab(),
    AlarmsTab(),
    TimerTab(),
    StopwatchTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.public_rounded), label: 'World Clock'),
          NavigationDestination(icon: Icon(Icons.alarm_rounded), label: 'Alarms'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Timer'),
          NavigationDestination(icon: Icon(Icons.stop_circle_outlined), label: 'Stopwatch'),
        ],
      ),
    );
  }
}
