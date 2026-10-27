import 'package:flutter/material.dart';

import 'date_logic.dart';

void main() {
  runApp(const LeapCheckApp());
}

class LeapCheckApp extends StatelessWidget {
  const LeapCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.indigo;
    return MaterialApp(
      title: 'Leap Check',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _leapYearController = TextEditingController();
  final _monthYearController =
      TextEditingController(text: DateTime.now().year.toString());

  int? _checkedYear;
  String? _leapError;
  int _selectedMonth = DateTime.now().month;

  @override
  void dispose() {
    _leapYearController.dispose();
    _monthYearController.dispose();
    super.dispose();
  }

  void _checkLeapYear() {
    final year = int.tryParse(_leapYearController.text.trim());
    setState(() {
      if (year == null || year < 1) {
        _checkedYear = null;
        _leapError = 'Please enter a valid year (e.g. 2024).';
      } else {
        _checkedYear = year;
        _leapError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leap Check'),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildLeapCard(theme),
            const SizedBox(height: 16),
            _buildMonthCard(theme),
            const SizedBox(height: 16),
            Text(
              'Leap years occur every 4 years, except century years '
              'not divisible by 400.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeapCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Leap Year Checker', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _leapYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Year',
                hintText: 'e.g. 2024',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _checkLeapYear(),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _checkLeapYear,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Check'),
            ),
            if (_leapError != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _leapError!,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
            if (_checkedYear != null) ...[
              const SizedBox(height: 12),
              _LeapResult(year: _checkedYear!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(ThemeData theme) {
    final yearText = _monthYearController.text.trim();
    final year = int.tryParse(yearText);
    final validYear = year != null && year >= 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Days in a Month', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedMonth,
                      isExpanded: true,
                      isDense: true,
                      underline: const SizedBox.shrink(),
                      items: [
                        for (var i = 1; i <= 12; i++)
                          DropdownMenuItem(
                            value: i,
                            child: Text(monthNames[i - 1]),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedMonth = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _monthYearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      hintText: 'e.g. 2024',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  validYear ? Icons.calendar_today : Icons.info_outline,
                  color: validYear
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validYear
                        ? '${monthNames[_selectedMonth - 1]} $year has '
                            '${daysInMonth(year, _selectedMonth)} days.'
                        : 'Please enter a valid year.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: validYear ? null : theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeapResult extends StatelessWidget {
  const _LeapResult({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final leap = isLeapYear(year);
    return Row(
      children: [
        Icon(
          leap ? Icons.check_circle : Icons.cancel,
          color: leap ? Colors.green : theme.colorScheme.error,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            leap
                ? '$year is a leap year (366 days).'
                : '$year is not a leap year (365 days).',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
