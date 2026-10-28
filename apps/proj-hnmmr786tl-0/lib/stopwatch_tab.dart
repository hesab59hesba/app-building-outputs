import 'dart:async';

import 'package:flutter/material.dart';

import 'package:clock_app/time_format.dart';

class StopwatchTab extends StatefulWidget {
  const StopwatchTab({super.key});

  @override
  State<StopwatchTab> createState() => _StopwatchTabState();
}

class _StopwatchTabState extends State<StopwatchTab> {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _laps = [];
  Timer? _ticker;

  bool get _running => _stopwatch.isRunning;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_running) {
        _stopwatch.stop();
        _ticker?.cancel();
        _ticker = null;
      } else {
        _stopwatch.start();
        _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  void _addLap() {
    setState(() => _laps.add(_stopwatch.elapsed));
  }

  void _reset() {
    setState(() {
      _stopwatch
        ..stop()
        ..reset();
      _ticker?.cancel();
      _ticker = null;
      _laps.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = _stopwatch.elapsed;
    final canReset = !_running && (elapsed > Duration.zero || _laps.isNotEmpty);
    final splits = <Duration>[
      for (var i = 0; i < _laps.length; i++)
        _laps[i] - (i == 0 ? Duration.zero : _laps[i - 1]),
    ];
    Duration? best;
    Duration? worst;
    if (splits.length >= 2) {
      best = splits.reduce((a, b) => a < b ? a : b);
      worst = splits.reduce((a, b) => a > b ? a : b);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch')),
      body: Column(
        children: [
          const Spacer(),
          Text(
            formatStopwatch(elapsed),
            key: const ValueKey<String>('stopwatch-display'),
            style: theme.textTheme.displayLarge!.copyWith(fontFeatures: tabularFigures),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _running ? _addLap : null,
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Lap'),
                ),
                FloatingActionButton.large(
                  onPressed: _toggle,
                  child: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
                OutlinedButton.icon(
                  onPressed: canReset ? _reset : null,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: _laps.isEmpty
                ? Center(child: Text('No laps yet', style: theme.textTheme.bodyMedium))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _laps.length,
                    itemBuilder: (context, index) {
                      final lap = _laps.length - index;
                      final split = splits[lap - 1];
                      final Color? color = split == best
                          ? Colors.green
                          : split == worst
                              ? Colors.orange
                              : null;
                      return ListTile(
                        leading: Text(
                          'Lap $lap',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(formatStopwatch(_laps[lap - 1])),
                        trailing: Text(
                          formatStopwatch(split),
                          style: TextStyle(color: color, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
