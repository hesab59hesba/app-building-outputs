import "package:flutter/material.dart";

void main() {
  runApp(const B1VerificationApp());
}

class B1VerificationApp extends StatelessWidget {
  const B1VerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "B1 Verification",
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _count = 0;

  void _increment() {
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("B1 Verification"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Current count",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "$_count",
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _increment,
              icon: const Icon(Icons.add),
              label: const Text("Increment"),
            ),
          ],
        ),
      ),
    );
  }
}
