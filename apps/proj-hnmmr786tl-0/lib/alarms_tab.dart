import 'dart:async';

import 'package:flutter/material.dart';

import 'package:clock_app/time_format.dart';

class Alarm {
  Alarm({
    required this.hour,
    required this.minute,
    required this.label,
    this.enabled = true,
  });

  final int hour;
  final int minute;
  final String label;
  bool enabled;
}

class AlarmsTab extends StatefulWidget {
  const AlarmsTab({super.key});

  @override
  State<AlarmsTab> createState() => _AlarmsTabState();
}

class _AlarmsTabState extends State<AlarmsTab> {
  final List<Alarm> _alarms = [];
  final Set<String> _firedKeys = {};
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    for (final alarm in _alarms) {
      if (!alarm.enabled || alarm.hour != now.hour || alarm.minute != now.minute) continue;
      if (_firedKeys.add('${alarm.hashCode}:${now.hour}:${now.minute}')) {
        _showFiredDialog(alarm);
      }
    }
    setState(() {});
  }

  void _showFiredDialog(Alarm alarm) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.alarm_on_rounded, size: 44),
        title: const Text('Alarm!'),
        content: Text('${alarm.label} — it is ${twoDigits(alarm.hour)}:${twoDigits(alarm.minute)}.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Dismiss')),
        ],
      ),
    );
  }

  Future<void> _addAlarm() async {
    final result = await showDialog<(int, int, String)>(
      context: context,
      builder: (context) => const _AlarmEditorDialog(),
    );
    if (!mounted || result == null) return;
    setState(() {
      _alarms.add(Alarm(hour: result.$1, minute: result.$2, label: result.$3));
      _alarms.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    });
  }

  String _ringsIn(Alarm alarm) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    final d = next.difference(now);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return h > 0 ? 'Rings in ${h}h ${twoDigits(m)}m' : 'Rings in ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Alarms')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.add_rounded),
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_add_rounded, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 12),
                  Text('No alarms yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Tap + to add one', style: theme.textTheme.bodyMedium),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final alarm in _alarms)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        alarm.enabled ? Icons.alarm_on_rounded : Icons.alarm_off_rounded,
                        color: alarm.enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
                      ),
                      title: Text(
                        '${twoDigits(alarm.hour)}:${twoDigits(alarm.minute)}',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                      subtitle: Text('${alarm.label} · ${alarm.enabled ? _ringsIn(alarm) : 'Off'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: alarm.enabled,
                            onChanged: (v) => setState(() => alarm.enabled = v),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () => setState(() => _alarms.remove(alarm)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AlarmEditorDialog extends StatefulWidget {
  const _AlarmEditorDialog();

  @override
  State<_AlarmEditorDialog> createState() => _AlarmEditorDialogState();
}

class _AlarmEditorDialogState extends State<_AlarmEditorDialog> {
  late TimeOfDay _time = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  final TextEditingController _label = TextEditingController(text: 'Alarm');

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New alarm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule_rounded),
            title: const Text('Time'),
            trailing: Text(_time.format(context), style: Theme.of(context).textTheme.titleLarge),
            onTap: _pickTime,
          ),
          TextField(
            controller: _label,
            maxLength: 24,
            decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = _label.text.trim();
            Navigator.of(context).pop((_time.hour, _time.minute, name.isEmpty ? 'Alarm' : name));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
