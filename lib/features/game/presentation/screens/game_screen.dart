import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictacgo/features/game/application/game_notifier.dart';
import 'package:tictacgo/features/game/domain/player.dart';
import 'package:tictacgo/features/game/presentation/widgets/game_cell.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameNotifierProvider);

    return Scaffold(
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
            // Status Text
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

            // Main board
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

            // Bottom Spacer for uniform look
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
