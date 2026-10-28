import 'package:flutter/material.dart';

import 'parking_spot.dart';
import 'spot_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final SpotStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarSpot'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          return switch (store.status) {
            SpotStatus.locating => const _LocatingView(),
            SpotStatus.idle => _IdleView(store: store),
            SpotStatus.saved => _SavedView(store: store),
          };
        },
      ),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.store});

  final SpotStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.local_parking,
                size: 64,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Where did you park?',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap below once when you leave the car. '
              'CarSpot remembers the spot and guides you back.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: store.saveCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Save my parking spot'),
            ),
            if (store.error != null) ...[
              const SizedBox(height: 20),
              _ErrorBanner(message: store.error!),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocatingView extends StatelessWidget {
  const _LocatingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Getting your GPS fix…'),
        ],
      ),
    );
  }
}

class _SavedView extends StatelessWidget {
  const _SavedView({required this.store});

  final SpotStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spot = store.spot!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car_filled,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text('Your car is parked here', style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                ListenableBuilder(
                  listenable: store,
                  builder: (context, _) => Chip(
                    avatar: const Icon(Icons.schedule, size: 18),
                    label: Text('Parked for ${formatElapsed(DateTime.now().difference(spot.savedAt))}'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${spot.latitude.toStringAsFixed(6)}, ${spot.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                ListenableBuilder(
                  listenable: store,
                  builder: (context, _) {
                    final distance = store.distanceMeters;
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          if (store.isMeasuring)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              Icons.social_distance,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            distance == null
                                ? 'Distance unknown'
                                : 'Car is ${formatDistance(distance)} away',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed:
                                store.isMeasuring ? null : store.refreshDistance,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Locate me'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: NoteField(spot: spot, onCommit: store.updateNote),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _openDirections(context),
          icon: const Icon(Icons.navigation),
          label: const Text('Walk me to my car'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _confirmRelease(context),
          icon: const Icon(Icons.delete_outline),
          label: const Text('I found my car — release spot'),
        ),
        if (store.error != null) ...[
          const SizedBox(height: 12),
          _ErrorBanner(message: store.error!),
        ],
      ],
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await store.openDirections();
    if (!messenger.mounted) return;
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not open a maps app on this device.'),
        ),
      );
    }
  }

  Future<void> _confirmRelease(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Release parking spot?'),
        content: const Text('The saved location will be forgotten.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Release'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      store.release();
    }
  }
}

class NoteField extends StatefulWidget {
  const NoteField({super.key, required this.spot, required this.onCommit});

  final ParkingSpot spot;
  final ValueChanged<String> onCommit;

  @override
  State<NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends State<NoteField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.spot.note ?? '');
  }

  @override
  void didUpdateWidget(NoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spot != widget.spot && widget.spot != oldWidget.spot) {
      _controller.text = widget.spot.note ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    widget.onCommit(_controller.text);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onSubmitted: widget.onCommit,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Add a note (level, row, landmark…)',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Save note',
          onPressed: _commit,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatElapsed(Duration elapsed) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = elapsed.inHours;
  final minutes = elapsed.inMinutes.remainder(60);
  final seconds = elapsed.inSeconds.remainder(60);
  return '$hours:${two(minutes)}:${two(seconds)}';
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
