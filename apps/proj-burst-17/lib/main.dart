import 'package:flutter/material.dart';

import 'grid_screen.dart';
import 'mood_store.dart';

void main() => runApp(const MoodDayApp());

class MoodDayApp extends StatefulWidget {
  const MoodDayApp({super.key});

  @override
  State<MoodDayApp> createState() => _MoodDayAppState();
}

class _MoodDayAppState extends State<MoodDayApp> {
  final MoodStore _store = MoodStore();

  @override
  Widget build(BuildContext context) {
    return MoodStoreScope(
      store: _store,
      child: MaterialApp(
        title: 'Mood Day',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        home: const MoodGridScreen(),
      ),
    );
  }
}

class MoodStoreScope extends InheritedNotifier<MoodStore> {
  const MoodStoreScope({
    super.key,
    required MoodStore store,
    required super.child,
  }) : super(notifier: store);

  static MoodStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MoodStoreScope>()!.notifier!;
}
