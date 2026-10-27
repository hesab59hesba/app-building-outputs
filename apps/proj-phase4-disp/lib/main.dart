import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DispatchProbeApp());
}

class DispatchProbeApp extends StatelessWidget {
  const DispatchProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dispatch Probe',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const CounterPage(),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;

  void _increment() {
    HapticFeedback.mediumImpact();
    setState(() => _count++);
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() => _count = 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _increment,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_count',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 140,
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'tap anywhere to count',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reset,
        tooltip: 'Reset counter',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
