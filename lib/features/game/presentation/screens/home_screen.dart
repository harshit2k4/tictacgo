import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:tictacgo/features/game/application/game_notifier.dart';
import 'package:tictacgo/features/game/domain/difficulty.dart';
import 'package:tictacgo/features/game/domain/game_mode.dart';
import 'package:tictacgo/features/game/domain/game_stats.dart';
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
              const SizedBox(height: 32),

              // --- NEW STATS CARD ---
              ValueListenableBuilder(
                valueListenable: Hive.box<GameStats>('stats_box').listenable(),
                builder: (context, box, _) {
                  final stats = box.get('global_stats') ?? GameStats();
                  return Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHomeStat(
                            context,
                            "Wins",
                            stats.wins.toString(),
                            Colors.green,
                          ),
                          _buildHomeStat(
                            context,
                            "Draws",
                            stats.draws.toString(),
                            Colors.orange,
                          ),
                          _buildHomeStat(
                            context,
                            "Losses",
                            stats.losses.toString(),
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // ----------------------
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
                      .startGame(selectedDifficulty, GameMode.singlePlayer);
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
                onPressed: () {
                  ref
                      .read(gameNotifierProvider.notifier)
                      .startGame(selectedDifficulty, GameMode.localMultiplayer);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.tablet_android),
                label: const Text('Pass & Play'),
              ),

              const SizedBox(height: 12),

              FilledButton.tonalIcon(
                onPressed: () {
                  // Placeholder for Cross-Device (Bluetooth/WiFi)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nearby Cross-Device play coming soon!"),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                icon: const Icon(Icons.group),
                label: const Text('2 Player Nearby (P2P)'),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
