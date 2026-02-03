import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictacgo/features/game/application/game_notifier.dart';
import 'package:tictacgo/features/game/domain/difficulty.dart';
import 'package:tictacgo/features/game/presentation/screens/game_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the selected difficulty
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'Tic Tac Go',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Text('Play the classic, evolved.'),
              const Spacer(),

              const Text(
                'Select Difficulty',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Material 3 Segmented Button
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<Difficulty>(
                  segments: const [
                    ButtonSegment(value: Difficulty.easy, label: Text('Easy')),
                    ButtonSegment(value: Difficulty.medium, label: Text('Med')),
                    ButtonSegment(value: Difficulty.hard, label: Text('Hard')),
                  ],
                  selected: {selectedDifficulty},
                  onSelectionChanged: (Set<Difficulty> newSelection) {
                    ref.read(selectedDifficultyProvider.notifier).state =
                        newSelection.first;
                  },
                ),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () {
                  // Tell the notifier to initialize with the selected difficulty
                  ref
                      .read(gameNotifierProvider.notifier)
                      .startGame(selectedDifficulty);

                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.person),
                label: const Text('Single Player'),
              ),
              const SizedBox(height: 12),

              FilledButton.tonalIcon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.group),
                label: const Text('2 Player Nearby'),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
