import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const VaultProbeApp());
}

class VaultProbeApp extends StatelessWidget {
  const VaultProbeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault Probe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const DiceRollerPage(),
    );
  }
}

class DiceRollerPage extends StatefulWidget {
  const DiceRollerPage({super.key});

  @override
  State<DiceRollerPage> createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage> {
  static const _diceFaces = ['\u2680', '\u2681', '\u2682', '\u2683', '\u2684', '\u2685'];

  int _value = 1;
  bool _rolling = false;

  void _roll() {
    if (_rolling) return;
    setState(() => _rolling = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _value = Random().nextInt(6) + 1;
        _rolling = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Vault Probe — Dice Roller')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: AnimatedScale(
                key: ValueKey(_value),
                duration: const Duration(milliseconds: 200),
                scale: _rolling ? 0.85 : 1,
                child: Text(
                  _rolling ? '\u{1F340}' : _diceFaces[_value - 1],
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 96),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _rolling ? 'Rolling...' : 'You rolled a $_value',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _rolling ? null : _roll,
              icon: const Icon(Icons.casino),
              label: const Text('Roll'),
            ),
          ],
        ),
      ),
    );
  }
}
