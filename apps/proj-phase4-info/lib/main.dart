import 'dart:async';

import 'package:flutter/material.dart';

void main() => runApp(const StopwatchApp());

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const StopwatchPage(),
    );
  }
}

String formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hundredths =
      (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
  return '${hours > 0 ? '$hours:' : ''}$minutes:$seconds.$hundredths';
}

class StopwatchModel extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _laps = <Duration>[];
  Timer? _ticker;

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsed => _stopwatch.elapsed;
  List<Duration> get laps => List.unmodifiable(_laps);

  void start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (!_stopwatch.isRunning) return;
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    _ticker?.cancel();
    _ticker = null;
    _laps.clear();
    notifyListeners();
  }

  void lap() {
    if (!_stopwatch.isRunning) return;
    _laps.insert(0, _stopwatch.elapsed);
    notifyListeners();
  }

  Duration splitAt(int index) {
    final total = _laps[index];
    final previous = index + 1 < _laps.length ? _laps[index + 1] : Duration.zero;
    return total - previous;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final StopwatchModel _model = StopwatchModel();

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final running = _model.isRunning;
        final elapsed = _model.elapsed;
        final canReset = running || elapsed > Duration.zero;
        final laps = _model.laps;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Stopwatch'),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatDuration(elapsed),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: running ? _model.lap : null,
                        icon: const Icon(Icons.flag),
                        label: const Text('Lap'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: running ? _model.pause : _model.start,
                        icon: Icon(running ? Icons.pause : Icons.play_arrow),
                        label: Text(running ? 'Pause' : 'Start'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.tonalIcon(
                        onPressed: canReset ? _model.reset : null,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colorScheme.outlineVariant),
                Expanded(
                  flex: 3,
                  child: laps.isEmpty
                      ? Center(
                          child: Text(
                            'No laps yet — press Lap while running.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          itemCount: laps.length,
                          itemBuilder: (context, index) {
                            final lapNumber = laps.length - index;
                            return ListTile(
                              leading: Text(
                                'Lap $lapNumber',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              title: Text(
                                formatDuration(_model.splitAt(index)),
                                textAlign: TextAlign.end,
                              ),
                              trailing: Text(
                                formatDuration(laps[index]),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
