import 'package:confetti/confetti.dart'; // 1. Add this import
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:tictacgo/features/game/application/game_notifier.dart';
import 'package:tictacgo/features/game/domain/game_board.dart';
import 'package:tictacgo/features/game/domain/game_mode.dart';
import 'package:tictacgo/features/game/domain/game_stats.dart';
import 'package:tictacgo/features/game/domain/player.dart';
import 'package:tictacgo/features/game/presentation/widgets/game_cell.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // init controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameNotifierProvider);

    // LISTEN for game end
    ref.listen(gameNotifierProvider, (previous, next) {
      if ((next.winner != null || next.isDraw) &&
          (previous?.winner == null && previous?.isDraw == false)) {
        // Fire confetti only on human win
        if (next.winner == Player.x) {
          _confettiController.play();
        }

        _showGameOverDialog(context, next, ref);
      }
    });

    return Stack(
      // Wrap in Stack for the confetti layer
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Tic Tac Go'),
            actions: [
              IconButton(
                onPressed: () =>
                    ref.read(gameNotifierProvider.notifier).resetGame(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    state.winner != null
                        ? 'Winner: ${state.winner == Player.x ? "X" : "O"}'
                        : state.isDraw
                        ? 'It\'s a Draw!'
                        : 'Player ${state.currentPlayer == Player.x ? "X" : "O"}\'s Turn',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return GameCell(
                              index: index,
                              player: state.cells[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),

        // Confetti Widget Layer
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  void _showGameOverDialog(
    BuildContext context,
    GameBoard state,
    WidgetRef ref,
  ) {
    final statsBox = Hive.box<GameStats>('stats_box');
    final stats = statsBox.get('global_stats') ?? GameStats();

    // Logic: Determine text, icons, and colors based on Mode
    final bool isLocal = state.gameMode == GameMode.localMultiplayer;
    final bool isDraw = state.isDraw;

    String title;
    String subtitle;
    IconData icon;
    Color color;

    if (isDraw) {
      title = "It's a Draw";
      subtitle = "A perfectly balanced match!";
      icon = Icons.handshake;
      color = Colors.orange;
    } else if (isLocal) {
      // Celebration for both players in Pass & Play
      title = state.winner == Player.x ? "Player X Wins!" : "Player O Wins!";
      subtitle = "A hard-fought tactical battle.";
      icon = Icons.emoji_events;
      color = state.winner == Player.x ? Colors.blue : Colors.red;
    } else {
      // Classic Hero vs AI logic
      title = state.winner == Player.x ? "Victory!" : "Defeat";
      subtitle = state.winner == Player.x
          ? "You outsmarted the AI!"
          : "The AI was one step ahead.";
      icon = state.winner == Player.x
          ? Icons.emoji_events
          : Icons.sentiment_very_dissatisfied;
      color = state.winner == Player.x ? Colors.green : Colors.red;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Game Over",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Updated Icon/Avatar
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: color.withOpacity(0.1),
                    child: Icon(icon, size: 40, color: color),
                  ),
                  const SizedBox(height: 16),
                  // Updated Result Text
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Career Stats (Only show label "Career Stats" to clarify these aren't match stats)
                  if (!isLocal) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn("Wins", stats.wins),
                          _buildStatColumn("Draws", stats.draws),
                          _buildStatColumn("Losses", stats.losses),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close Dialog
                            Navigator.of(context).pop(); // Exit Game Screen
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Exit"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref.read(gameNotifierProvider.notifier).resetGame();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Play Again"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widget for stats
  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
