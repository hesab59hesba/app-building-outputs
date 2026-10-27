import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const DiceRollerApp());
}

class DiceRollerApp extends StatelessWidget {
  const DiceRollerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Roller',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const DiceRollerPage(),
    );
  }
}

class DiceType {
  final String label;
  final int sides;
  final String icon;
  const DiceType(this.label, this.sides, this.icon);
}

const diceTypes = [
  DiceType('d4', 4, '🔺'),
  DiceType('d6', 6, '🎲'),
  DiceType('d8', 8, '🔶'),
  DiceType('d20', 20, '💎'),
];

class RollResult {
  final int diceTypeIndex;
  final int value;
  final DateTime time;
  RollResult(this.diceTypeIndex, this.value) : time = DateTime.now();
}

class DiceRollerModel extends ChangeNotifier {
  final Random _random = Random();
  final List<RollResult> _history = [];

  List<RollResult> get history => List.unmodifiable(_history);

  int roll(int diceTypeIndex) {
    final result = RollResult(diceTypeIndex, _random.nextInt(diceTypes[diceTypeIndex].sides) + 1);
    _history.insert(0, result);
    notifyListeners();
    return result.value;
  }

  void clear() {
    _history.clear();
    notifyListeners();
  }
}

class DiceRollerPage extends StatefulWidget {
  const DiceRollerPage({super.key});

  @override
  State<DiceRollerPage> createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage> {
  final DiceRollerModel _model = DiceRollerModel();
  int _selected = 0;
  int? _lastRoll;

  void _roll() {
    setState(() {
      _lastRoll = _model.roll(_selected);
    });
  }

  void _clear() {
    setState(() {
      _lastRoll = null;
      _model.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Roller'),
        actions: [
          IconButton(
            tooltip: 'Clear history',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _model.history.isEmpty ? null : _clear,
          ),
        ],
      ),
      body: Column(
        children: [
          SegmentedButton<int>(
            segments: [
              for (var i = 0; i < diceTypes.length; i++)
                ButtonSegment(value: i, label: Text(diceTypes[i].label)),
            ],
            selected: {_selected},
            onSelectionChanged: (selection) =>
                setState(() => _selected = selection.first),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    diceTypes[_selected].icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastRoll == null ? '—' : '$_lastRoll',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: colors.primary),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _roll,
                    icon: const Icon(Icons.casino),
                    label: Text('Roll ${diceTypes[_selected].label}'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _model.history.isEmpty
                ? const Center(child: Text('No rolls yet'))
                : ListView.builder(
                    itemCount: _model.history.length,
                    itemBuilder: (context, index) {
                      final roll = _model.history[index];
                      final dice = diceTypes[roll.diceTypeIndex];
                      final time = MaterialLocalizations.of(context)
                          .formatTimeOfDay(TimeOfDay.fromDateTime(roll.time));
                      return ListTile(
                        leading: Text(dice.icon, style: const TextStyle(fontSize: 20)),
                        title: Text('${dice.label} → ${roll.value}'),
                        subtitle: Text(time),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
