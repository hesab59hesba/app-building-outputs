import 'package:flutter/material.dart';

import 'main.dart';
import 'mood_store.dart';

class MoodGridScreen extends StatelessWidget {
  const MoodGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = MoodStoreScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Day'),
        actions: [
          IconButton(
            tooltip: 'Clear all moods',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => _confirmClear(context, store),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${store.loggedCount} of ${MoodStore.numDays} days logged',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${store.streak}-day streak',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final mood in kMoods)
                    Column(
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 16)),
                        Text(
                          '${store.countOf(mood.id)}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 6,
                padding: const EdgeInsets.all(12),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: [
                  for (var i = 0; i < MoodStore.numDays; i++) _DayCell(index: i),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, MoodStore store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all moods?'),
        content: const Text('Every day in the 30-day grid will be reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      store.clearAll();
    }
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final store = MoodStoreScope.of(context);
    final mood = store.moodAt(index);
    final date = store.dateFor(index);
    final isToday = index == store.todayIndex;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _editMood(context, store, index),
      child: Container(
        decoration: BoxDecoration(
          color: mood?.softColor ?? scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday ? scheme.primary : scheme.outlineVariant,
            width: isToday ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 2),
            Text(mood?.emoji ?? '', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  void _editMood(BuildContext context, MoodStore store, int index) {
    final date = store.dateFor(index);
    final current = store.moodAt(index);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'Pick a mood for ${monthDayLabel(date)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final mood in kMoods)
              ListTile(
                leading: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(mood.label),
                selected: current?.id == mood.id,
                trailing:
                    current?.id == mood.id ? const Icon(Icons.check) : null,
                onTap: () {
                  store.setMood(index, mood.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
            if (current != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear day'),
                onTap: () {
                  store.setMood(index, null);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
