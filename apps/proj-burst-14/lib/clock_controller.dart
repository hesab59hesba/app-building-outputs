import 'dart:async';

import 'package:flutter/foundation.dart';

/// In-memory state machine for a two-player chess clock.
///
/// Each player has a countdown. Tapping the side of the player whose clock is
/// running ends their turn and starts the opponent's clock. The clock can be
/// paused, the players can swap sides (remaining times trade places), and the
/// game is over as soon as one clock reaches zero.
class ClockController extends ChangeNotifier {
  ClockController({Duration baseTime = const Duration(minutes: 5)})
      : _baseTime = baseTime,
        _remaining = <Duration>[baseTime, baseTime];

  static const List<Duration> presets = <Duration>[
    Duration(minutes: 1),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
  ];

  static const List<String> sideNames = <String>['White', 'Black'];
  static const int white = 0;
  static const int black = 1;

  final List<Duration> _remaining;
  Duration _baseTime;
  int? _active; // Index of the clock that is running.
  bool _paused = false;
  int? _flagged; // Index of the clock that ran out of time.
  Timer? _ticker;
  DateTime _lastTick = DateTime.now();

  Duration get baseTime => _baseTime;
  Duration remaining(int side) => _remaining[side];
  int? get activeSide => _active;
  bool get isPaused => _paused;
  bool get isOver => _flagged != null;
  bool get isRunning => _active != null && !_paused && !isOver;
  bool get isReady => _active == null && !isOver;
  int get winner => _flagged == white ? black : white;

  /// Starts the clock of [side] (only from the untouched, ready state).
  void start(int side) {
    if (isOver || _active != null) return;
    _active = side;
    _paused = false;
    _lastTick = DateTime.now();
    _startTicker();
    notifyListeners();
  }

  /// Tapping a side either starts that clock (ready state) or, for the player
  /// whose clock is running, hands the move to the opponent. Taps on the
  /// waiting side and taps while paused are ignored.
  void tap(int side) {
    if (isOver || _paused) return;
    if (_active == null) {
      start(side);
      return;
    }
    if (side == _active) {
      _active = 1 - side;
      _lastTick = DateTime.now();
      notifyListeners();
    }
  }

  void togglePause() {
    if (_active == null || isOver) return;
    _paused = !_paused;
    if (_paused) {
      _ticker?.cancel();
      _ticker = null;
    } else {
      _startTicker();
    }
    notifyListeners();
  }

  /// Swaps the two players: remaining times trade places. A running clock
  /// keeps running for the seat (the player who sat down there now has the
  /// other side's remaining time).
  void swap() {
    final swap = _remaining[white];
    _remaining[white] = _remaining[black];
    _remaining[black] = swap;
    notifyListeners();
  }

  /// Stops everything and restores both clocks to the current base time.
  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _remaining[white] = _baseTime;
    _remaining[black] = _baseTime;
    _active = null;
    _paused = false;
    _flagged = null;
    notifyListeners();
  }

  /// Selects a new time control and resets the game.
  void setBaseTime(Duration base) {
    _baseTime = base;
    reset();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = null;
    if (!isRunning) return;
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastTick);
    _lastTick = now;
    final side = _active;
    if (side == null || isOver) return;
    final left = _remaining[side] - elapsed;
    if (left <= Duration.zero) {
      _remaining[side] = Duration.zero;
      _flagged = side;
      _ticker?.cancel();
      _ticker = null;
    } else {
      _remaining[side] = left;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
