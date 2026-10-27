import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'clock_controller.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  final ClockController _clock = ClockController();

  @override
  void initState() {
    super.initState();
    _clock.addListener(_onClockChanged);
  }

  void _onClockChanged() => setState(() {});

  @override
  void dispose() {
    _clock.removeListener(_onClockChanged);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Clock'),
        actions: [
          IconButton(
            tooltip: 'Time control',
            icon: const Icon(Icons.timer_outlined),
            onPressed: _clock.isRunning ? null : _pickTimeControl,
          ),
          IconButton(
            tooltip: 'Swap players',
            icon: const Icon(Icons.swap_vert),
            onPressed: _clock.swap,
          ),
          IconButton(
            tooltip: _clock.isPaused ? 'Resume' : 'Pause',
            icon: Icon(
              _clock.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            onPressed:
                (_clock.isReady || _clock.isOver) ? null : _clock.togglePause,
          ),
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.restart_alt),
            onPressed: _clock.reset,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _SidePanel(side: ClockController.white, clock: _clock),
          ),
          const _HandleBar(),
          Expanded(
            child: _SidePanel(side: ClockController.black, clock: _clock),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTimeControl() async {
    final picked = await showModalBottomSheet<Duration>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text('Time control per player'),
              ),
              for (final preset in ClockController.presets)
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(_presetLabel(preset)),
                  trailing:
                      preset == _clock.baseTime ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(context).pop(preset),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      _clock.setBaseTime(picked);
    }
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.side, required this.clock});

  final int side;
  final ClockController clock;

  static const Color _whitePanel = Color(0xFFF2F1EC);
  static const Color _whiteText = Color(0xFF14161B);
  static const Color _blackPanel = Color(0xFF171A21);
  static const Color _blackText = Colors.white;

  @override
  Widget build(BuildContext context) {
    final isWhite = side == ClockController.white;
    final backgroundColor = isWhite ? _whitePanel : _blackPanel;
    final textColor = isWhite ? _whiteText : _blackText;
    final accent = Theme.of(context).colorScheme.primary;
    final danger = isWhite ? const Color(0xFFB3261E) : const Color(0xFFFF6B6B);

    final active = clock.activeSide == side;
    final runningHere = clock.isRunning && active;
    final dimmed = clock.isRunning && !active;
    final flagged = clock.isOver && clock.winner != side;
    final winner = clock.isOver && clock.winner == side;
    final lowTime =
        clock.isRunning && clock.remaining(side) < const Duration(seconds: 30);
    final timeColor = (flagged || lowTime) ? danger : textColor;

    final String hint;
    if (clock.isOver) {
      hint = winner ? '🏆 Winner on time' : '🚩 Flag falls';
    } else if (clock.isPaused) {
      hint = 'Paused';
    } else if (runningHere) {
      hint = 'Tap when your move is done';
    } else if (dimmed) {
      hint = 'Waiting for ${ClockController.sideNames[1 - side]}…';
    } else {
      hint = 'Tap to start your clock';
    }

    final panel = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.45 : 1.0,
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onTap: () => clock.tap(side),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 6,
                  color: runningHere ? accent : Colors.transparent,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWhite ? Icons.circle_outlined : Icons.circle,
                          size: 16,
                          color: textColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ClockController.sideNames[side].toUpperCase(),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(clock.remaining(side)),
                      style: TextStyle(
                        color: timeColor,
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hint,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // The top half is rotated 180° so a phone laid flat between the players
    // can be read from both sides of the board.
    return side == ClockController.white
        ? Transform.rotate(angle: math.pi, child: panel)
        : panel;
  }
}

class _HandleBar extends StatelessWidget {
  const _HandleBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 28,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.drag_handle,
        size: 20,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

String _formatTime(Duration d) {
  if (d < const Duration(seconds: 10)) {
    final tenths = (d.inMilliseconds % 1000) ~/ 100;
    return '${d.inSeconds}.$tenths';
  }
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = d.inHours;
  return hours > 0 ? '$hours:$minutes$seconds' : '$minutes:$seconds';
}

String _presetLabel(Duration d) =>
    d.inMinutes == 1 ? '1 minute' : '${d.inMinutes} minutes';
