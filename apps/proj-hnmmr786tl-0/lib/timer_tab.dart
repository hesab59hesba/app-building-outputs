import 'dart:async';

import 'package:flutter/material.dart';

import 'package:clock_app/time_format.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  static const List<int> _presets = [1, 3, 5, 10, 15];

  Duration _total = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);
  bool _running = false;
  DateTime? _deadline;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    if (_remaining <= Duration.zero) return;
    _deadline = DateTime.now().add(_remaining);
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
    setState(() => _running = true);
  }

  void _tick() {
    if (!mounted || !_running) return;
    final left = _deadline!.difference(DateTime.now());
    if (left > Duration.zero) {
      setState(() => _remaining = left);
    } else {
      _finish();
    }
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _finish() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remaining = Duration.zero;
    });
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.timer_rounded, size: 44),
        title: const Text("Time's up!"),
        content: const Text('Your countdown has finished.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK')),
        ],
      ),
    ).then((_) {
      if (mounted) _reset();
    });
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _remaining = _total;
    });
  }

  void _setPreset(int minutes) {
    setState(() => _total = _remaining = Duration(minutes: minutes));
  }

  void _adjust(int minutes, int seconds) {
    final next = _remaining + Duration(minutes: minutes, seconds: seconds);
    if (next.isNegative) return;
    setState(() => _total = _remaining = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = _total > Duration.zero
        ? (1 - _remaining.inMilliseconds / _total.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble()
        : 0.0;
    final canReset =
        !_running && (_remaining == Duration.zero || _remaining != _total);
    return Scaffold(
      appBar: AppBar(title: const Text('Timer')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                            value: progress, strokeWidth: 10),
                      ),
                      Text(
                        formatHms(_remaining),
                        key: const ValueKey<String>('timer-display'),
                        style: theme.textTheme.displayLarge!
                            .copyWith(fontFeatures: tabularFigures),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final minutes in _presets)
                        ActionChip(
                          label: Text('$minutes min'),
                          onPressed:
                              _running ? null : () => _setPreset(minutes),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _running ? null : () => _adjust(-1, 0),
                        child: const Text('-1 min'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _running ? null : () => _adjust(1, 0),
                        child: const Text('+1 min'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _running ? null : () => _adjust(0, -10),
                        child: const Text('-10 sec'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _running ? null : () => _adjust(0, 10),
                        child: const Text('+10 sec'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: canReset ? _reset : null,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      const SizedBox(width: 16),
                      FloatingActionButton.large(
                        onPressed: _running ? _pause : _start,
                        child: Icon(_running
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
