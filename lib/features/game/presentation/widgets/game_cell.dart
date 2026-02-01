import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tictacgo/features/game/application/game_notifier.dart';
import 'package:tictacgo/features/game/domain/player.dart';

class GameCell extends ConsumerWidget {
  final int index;
  final Player player;

  const GameCell({super.key, required this.index, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThinking = ref.watch(
      gameNotifierProvider.select((s) => s.isAiThinking),
    );

    return GestureDetector(
      onTap: isThinking
          ? null
          : () => ref.read(gameNotifierProvider.notifier).makeMove(index),
      child: Opacity(
        // Subtly dim the board while AI makes the move
        opacity: isThinking ? 0.7 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            // Using M3 Surface container colors
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: _buildPlayerMarker()),
        ),
      ),
    );
  }

  Widget _buildPlayerMarker() {
    // Simple text for now, replace with animations later
    if (player == Player.x) {
      return const Text(
        'X',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      );
    } else if (player == Player.o) {
      return const Text(
        'O',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      );
    }
    return const SizedBox.shrink();
  }
}
