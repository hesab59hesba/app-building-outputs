import 'package:flutter/material.dart';

void main() {
  runApp(const B3VerificationApp());
}

class B3VerificationApp extends StatelessWidget {
  const B3VerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seed = ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal);
    return MaterialApp(
      title: 'Tip Calculator',
      debugShowCheckedModeBanner: false,
      theme: seed,
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const TipCalculatorPage(),
    );
  }
}

class TipCalculatorPage extends StatefulWidget {
  const TipCalculatorPage({super.key});

  @override
  State<TipCalculatorPage> createState() => _TipCalculatorPageState();
}

class _TipCalculatorPageState extends State<TipCalculatorPage> {
  final TextEditingController _billController = TextEditingController();
  double _tipPercent = 15;

  double get _billAmount {
    final raw = _billController.text.trim().replaceAll(',', '.');
    return double.tryParse(raw) ?? 0;
  }

  double get _tipAmount => _billAmount * _tipPercent / 100;

  double get _total => _billAmount + _tipAmount;

  @override
  void dispose() {
    _billController.dispose();
    super.dispose();
  }

  String _money(double value) => '\$${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tip Calculator')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _billController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Bill amount',
                  prefixIcon: Icon(Icons.receipt_long),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Text(
                'Tip percentage: ${_tipPercent.round()}%',
                style: textTheme.titleMedium,
              ),
              Slider(
                value: _tipPercent,
                min: 0,
                max: 30,
                divisions: 30,
                label: '${_tipPercent.round()}%',
                onChanged: (value) => setState(() => _tipPercent = value),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final p in const [10, 15, 20, 25])
                    ChoiceChip(
                      label: Text('$p%'),
                      selected: _tipPercent.round() == p,
                      onSelected: (_) => setState(() => _tipPercent = p.toDouble()),
                    ),
                ],
              ),
              const Spacer(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tip', style: textTheme.titleMedium),
                          Text(
                            _money(_tipAmount),
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: textTheme.titleLarge),
                          Text(
                            _money(_total),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
