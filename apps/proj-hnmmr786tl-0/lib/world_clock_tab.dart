import 'dart:async';

import 'package:flutter/material.dart';

import 'package:clock_app/time_format.dart';

class WorldCity {
  const WorldCity(this.name, this.flag, this.offset);

  final String name;
  final String flag;
  final Duration offset;
}

const List<WorldCity> worldCities = [
  WorldCity('Los Angeles', '🇺🇸', Duration(hours: -8)),
  WorldCity('New York', '🇺🇸', Duration(hours: -5)),
  WorldCity('São Paulo', '🇧🇷', Duration(hours: -3)),
  WorldCity('London', '🇬🇧', Duration.zero),
  WorldCity('Paris', '🇫🇷', Duration(hours: 1)),
  WorldCity('Cairo', '🇪🇬', Duration(hours: 2)),
  WorldCity('Dubai', '🇦🇪', Duration(hours: 4)),
  WorldCity('Mumbai', '🇮🇳', Duration(hours: 5, minutes: 30)),
  WorldCity('Beijing', '🇨🇳', Duration(hours: 8)),
  WorldCity('Tokyo', '🇯🇵', Duration(hours: 9)),
  WorldCity('Sydney', '🇦🇺', Duration(hours: 10)),
];

class WorldClockTab extends StatefulWidget {
  const WorldClockTab({super.key});

  @override
  State<WorldClockTab> createState() => _WorldClockTabState();
}

class _WorldClockTabState extends State<WorldClockTab> {
  late final Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _dayLabel(DateTime cityTime) {
    final localDay = DateTime(_now.year, _now.month, _now.day);
    final cityDay = DateTime(cityTime.year, cityTime.month, cityTime.day);
    final diff = cityDay.difference(localDay).inDays;
    return switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      -1 => 'Yesterday',
      _ => diff > 0 ? '+$diff days' : '$diff days',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('World Clock')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              children: [
                Text('Local time', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  formatClockSeconds(_now),
                  style: theme.textTheme.displayLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: tabularFigures,
                  ),
                ),
                const SizedBox(height: 8),
                Text(formatDate(_now), style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...worldCities.map((city) {
            final cityTime = _now.toUtc().add(city.offset);
            final isDay = cityTime.hour >= 6 && cityTime.hour < 18;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(city.flag, style: const TextStyle(fontSize: 28)),
                title: Text(
                  city.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('UTC${offsetLabel(city.offset)} · ${_dayLabel(cityTime)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDay ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatClock(cityTime),
                      style: theme.textTheme.titleLarge!.copyWith(fontFeatures: tabularFigures),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
