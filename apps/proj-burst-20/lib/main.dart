import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

void main() {
  runApp(const SortTrayApp());
}

const List<String> _originalItems = <String>[
  'Apples',
  'Bananas',
  'Cherries',
  'Dates',
  'Elderberries',
  'Figs',
  'Grapes',
  'Honeydew',
];

class SortTrayApp extends StatelessWidget {
  const SortTrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sort Tray',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const SortTrayHome(),
    );
  }
}

class SortTrayHome extends StatefulWidget {
  const SortTrayHome({super.key});

  @override
  State<SortTrayHome> createState() => _SortTrayHomeState();
}

class _SortTrayHomeState extends State<SortTrayHome> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List<String>.of(_originalItems);
  }

  void _moveItem(int from, int to) {
    setState(() {
      if (from < 0 || from >= _items.length) return;
      if (to < 0 || to >= _items.length) return;
      final String item = _items.removeAt(from);
      _items.insert(to, item);
    });
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      final String item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  void _resetOrder() {
    setState(() {
      _items = List<String>.of(_originalItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sort Tray'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset order',
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetOrder,
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length,
        onReorderItem: _handleReorder,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? builtChild) {
              final double elevation = lerpDouble(0, 6, animation.value)!;
              return Material(
                elevation: elevation,
                borderRadius: BorderRadius.circular(12),
                child: builtChild,
              );
            },
            child: child,
          );
        },
        itemBuilder: (BuildContext context, int index) {
          final String item = _items[index];
          return Card(
            key: ValueKey<String>(item),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(item),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Move ${item} up',
                    icon: const Icon(Icons.arrow_upward),
                    onPressed:
                        index > 0 ? () => _moveItem(index, index - 1) : null,
                  ),
                  IconButton(
                    tooltip: 'Move ${item} down',
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: index < _items.length - 1
                        ? () => _moveItem(index, index + 1)
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
