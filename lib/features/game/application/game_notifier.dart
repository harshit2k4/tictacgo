import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictacgo/features/game/application/ai_service.dart';
import 'package:tictacgo/features/game/domain/difficulty.dart';
import 'package:tictacgo/features/game/domain/game_stats.dart';
import '../domain/game_board.dart';
import '../domain/player.dart';

// Required for Riverpod code generation
// Run in terminal: dart run build_runner build
part 'game_notifier.g.dart';

final selectedDifficultyProvider = StateProvider<Difficulty>(
  (ref) => Difficulty.hard,
);

@riverpod
class GameNotifier extends _$GameNotifier {
  @override
  GameBoard build() {
    // Start with an empty board
    final initialDifficulty = ref.watch(selectedDifficultyProvider);
    return GameBoard.empty(difficulty: initialDifficulty);
  }

  final gameStatsProvider = Provider<GameStats>((ref) {
    final box = Hive.box<GameStats>('stats_box');
    return box.get('global_stats') ?? GameStats();
  });

  void makeMove(int index) {
    // Block if AI is thinking
    if (state.cells[index] != Player.none ||
        state.winner != null ||
        state.isDraw ||
        state.isAiThinking) {
      return;
    }

    // Execute Human Move
    final newCells = List<Player>.from(state.cells);
    newCells[index] = state.currentPlayer;

    final winner = _calculateWinner(newCells);
    final isDraw = !newCells.contains(Player.none) && winner == null;

    state = state.copyWith(
      cells: newCells,
      currentPlayer: state.currentPlayer == Player.x ? Player.o : Player.x,
      winner: winner,
      isDraw: isDraw,
      isAiThinking:
          (winner == null &&
          !isDraw &&
          Player.o == (state.currentPlayer == Player.x ? Player.o : Player.x)),
    );

    // save to db
    if (winner != null || isDraw) {
      _checkAndSaveResult(winner, isDraw);
    }

    if (state.isAiThinking) {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() {
    Future.delayed(const Duration(milliseconds: 400), () {
      final aiMove = AiService().findBestMove(state, state.difficulty);

      if (aiMove != -1) {
        final newCells = List<Player>.from(state.cells);
        newCells[aiMove] = Player.o;

        final winner = _calculateWinner(newCells);
        final isDraw = !newCells.contains(Player.none) && winner == null;

        state = state.copyWith(
          cells: newCells,
          currentPlayer: Player.x,
          winner: winner,
          isDraw: isDraw,
          isAiThinking: false,
        );

        // save to db
        if (winner != null || isDraw) {
          _checkAndSaveResult(winner, isDraw);
        }
      }
    });
  }

  void _checkAndSaveResult(Player? winner, bool isDraw) {
    if (winner != null || isDraw) {
      final box = Hive.box<GameStats>('stats_box');

      // Get the existing stats, or a fresh object if null
      final stats = box.get('global_stats') ?? GameStats();

      // Update the values
      if (isDraw) {
        stats.draws++;
      } else if (winner == Player.x) {
        stats.wins++;
      } else if (winner == Player.o) {
        stats.losses++;
      }

      // Manually put it back into the box using the key
      // This works whether the object was already in the box or newly created
      box.put('global_stats', stats);
    }
  }

  void startGame(Difficulty difficulty) {
    state = GameBoard.empty(difficulty: difficulty);
  }

  Player? _calculateWinner(List<Player> cells) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var line in lines) {
      if (cells[line[0]] != Player.none &&
          cells[line[0]] == cells[line[1]] &&
          cells[line[0]] == cells[line[2]]) {
        return cells[line[0]];
      }
    }
    return null;
  }

  void resetGame() {
    /// There are two options
    // Option A: Use the difficulty already stored in the current game session
    final currentDifficulty = state.difficulty;
    state = GameBoard.empty(difficulty: currentDifficulty);

    // Option B: Always reset to whatever the user has selected on the Home Screen
    // state = GameBoard.empty(difficulty: ref.read(selectedDifficultyProvider));
  }
}
