import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardsApp());
}

const _seedDeck = <({String question, String answer})>[
  (
    question: 'What does CPU stand for?',
    answer: 'Central Processing Unit',
  ),
  (
    question: 'Which planet is closest to the Sun?',
    answer: 'Mercury',
  ),
  (
    question: 'What is the capital of Portugal?',
    answer: 'Lisbon',
  ),
  (
    question: 'In Flutter, which widget centers its child?',
    answer: 'Center',
  ),
  (
    question: 'How many sides does a hexagon have?',
    answer: '6',
  ),
  (
    question: 'What does HTTP status 404 mean?',
    answer: 'Not Found',
  ),
];

@immutable
class CardStats {
  final int correct;
  final int wrong;

  const CardStats({this.correct = 0, this.wrong = 0});
}

class Flashcard {
  Flashcard({required this.question, required this.answer});

  final String question;
  final String answer;

  int correct = 0;
  int wrong = 0;

  CardStats get stats => CardStats(correct: correct, wrong: wrong);
}

class StudySession extends ChangeNotifier {
  StudySession() : cards = _seedDeck.map<Flashcard>((seed) {
    return Flashcard(question: seed.question, answer: seed.answer);
  }).toList();

  final List<Flashcard> cards;  int index = 0;
  bool revealed = false;

  Flashcard? get currentCard =>
      index < cards.length ? cards[index] : null;

  bool get isFinished => index >= cards.length;

  double get progress => cards.isEmpty ? 0 : index / cards.length;

  int get totalCorrect =>
      cards.fold(0, (sum, card) => sum + card.correct);

  int get totalWrong => cards.fold(0, (sum, card) => sum + card.wrong);

  void revealAnswer() {
    if (isFinished || revealed) return;
    revealed = true;
    notifyListeners();
  }

  void markCorrect() {
    final card = currentCard;
    if (card == null || !revealed) return;
    card.correct++;
    _advance();
  }

  void markWrong() {
    final card = currentCard;
    if (card == null || !revealed) return;
    card.wrong++;
    _advance();
  }

  void _advance() {
    revealed = false;
    index++;
    notifyListeners();
  }

  void restart() {
    for (final card in cards) {
      card.correct = 0;
      card.wrong = 0;
    }
    index = 0;
    revealed = false;
    notifyListeners();
  }
}

class FlashcardsApp extends StatelessWidget {
  const FlashcardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: StudyScreen(),
    );
  }
}

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final StudySession _session = StudySession();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finished = _session.isFinished;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            tooltip: 'Restart deck',
            icon: const Icon(Icons.restart_alt),
            onPressed: () => setState(_session.restart),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: finished ? 1.0 : _session.progress,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  finished
                      ? 'Done'
                      : 'Card ${_session.index + 1} / ${_session.cards.length}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: finished
                    ? _SummaryView(
                        session: _session,
                        onRestart: () => setState(_session.restart),
                      )
                    : _CardView(
                        key: ValueKey(_session.index),
                        card: _session.cards[_session.index],
                        revealed: _session.revealed,
                        onFlip: () => setState(_session.revealAnswer),
                        onCorrect: () => setState(_session.markCorrect),
                        onWrong: () => setState(_session.markWrong),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView({
    super.key,
    required this.card,
    required this.revealed,
    required this.onFlip,
    required this.onCorrect,
    required this.onWrong,
  });

  final Flashcard card;
  final bool revealed;
  final VoidCallback onFlip;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: revealed ? null : onFlip,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation
                    .drive(Tween(begin: 0.5, end: 0.0)),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Card(
              key: ValueKey(revealed),
              elevation: 4,
              child: Container(
                height: 220,
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      revealed ? 'Answer' : 'Question',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      revealed ? card.answer : card.question,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 18, color: Colors.green.shade600),
            const SizedBox(width: 4),
            Text('${card.correct}'),
            const SizedBox(width: 20),
            Icon(Icons.close, size: 18, color: theme.colorScheme.error),
            const SizedBox(width: 4),
            Text('${card.wrong}'),
          ],
        ),
        const SizedBox(height: 20),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: revealed
              ? Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Correct'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onCorrect,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Wrong'),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onWrong,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: revealed
              ? const SizedBox.shrink()
              : Text(
                  'Tap the card to reveal the answer',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
        ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.session, required this.onRestart});

  final StudySession session;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.emoji_events, size: 48),
              const SizedBox(height: 8),
              Text(
                'Deck complete!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${session.totalCorrect} correct · ${session.totalWrong} wrong',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Divider(height: 24),
              ...session.cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.question,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text('${card.correct}'),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 2),
                      Text('${card.wrong}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text('Study again'),
                onPressed: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
