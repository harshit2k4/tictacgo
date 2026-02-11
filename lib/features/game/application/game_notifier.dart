import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tictacgo/features/game/application/ai_service.dart';
import 'package:tictacgo/features/game/domain/difficulty.dart';
import 'package:tictacgo/features/game/domain/game_mode.dart';
import 'package:tictacgo/features/game/domain/game_stats.dart';
import '../domain/game_board.dart';
import '../domain/player.dart';

// Required for Riverpod code generation
// Run in terminal: dart run build_runner build
part 'game_notifier.g.dart';

final selectedDifficultyProvider = StateProvider<Difficulty>(
  (ref) => Difficulty.hard,
);

@Riverpod(keepAlive: true)
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

  // void makeMove(int index) {
  //   // Block if AI is thinking
  //   if (state.cells[index] != Player.none ||
  //       state.winner != null ||
  //       state.isDraw ||
  //       state.isAiThinking) {
  //     return;
  //   }

  //   // Execute Human Move
  //   final newCells = List<Player>.from(state.cells);
  //   newCells[index] = state.currentPlayer;

  //   final winner = _calculateWinner(newCells);
  //   final isDraw = !newCells.contains(Player.none) && winner == null;

  //   state = state.copyWith(
  //     cells: newCells,
  //     currentPlayer: state.currentPlayer == Player.x ? Player.o : Player.x,
  //     winner: winner,
  //     isDraw: isDraw,
  //     isAiThinking:
  //         (winner == null &&
  //         !isDraw &&
  //         Player.o == (state.currentPlayer == Player.x ? Player.o : Player.x)),
  //   );

  //   // save to db
  //   if (winner != null || isDraw) {
  //     _checkAndSaveResult(winner, isDraw);
  //   }

  //   if (state.isAiThinking) {
  //     _triggerAiMove();
  //   }
  // }

  void makeMove(int index) {
    // Standard checks
    if (state.cells[index] != Player.none ||
        state.winner != null ||
        state.isDraw ||
        state.isAiThinking) {
      return;
    }
    // Execute the current move
    final newCells = List<Player>.from(state.cells);
    newCells[index] = state.currentPlayer;

    final result = _calculateWinner(newCells);
    final winner = result.$1;
    final winningLine = result.$2;

    final isDraw = !newCells.contains(Player.none) && winner == null;
    final nextPlayer = state.currentPlayer == Player.x ? Player.o : Player.x;

    // Check if we should actually trigger the AI
    // Trigger the AI if:
    // - It's Single Player mode
    // - No one has won yet
    // - It's now the AI's turn (Player O)
    final shouldTriggerAi =
        state.gameMode == GameMode.singlePlayer &&
        winner == null &&
        !isDraw &&
        nextPlayer == Player.o;

    state = state.copyWith(
      cells: newCells,
      currentPlayer: nextPlayer,
      winner: winner,
      winningLine: winningLine,
      isDraw: isDraw,
      isAiThinking: shouldTriggerAi,
    );
    // Update stats only for Single Player games
    if (state.gameMode == GameMode.singlePlayer) {
      _checkAndSaveResult(winner, isDraw);
    }
    // Only call the AI service if the flag is true
    if (shouldTriggerAi) {
      _triggerAiMove();
    }
  }

  void _triggerAiMove() {
    Future.delayed(const Duration(milliseconds: 400), () {
      final aiMove = AiService().findBestMove(state, state.difficulty);

      if (aiMove != -1) {
        final newCells = List<Player>.from(state.cells);
        newCells[aiMove] = Player.o;

        final result = _calculateWinner(newCells);
        final winner = result.$1;
        final winningLine = result.$2;

        final isDraw = !newCells.contains(Player.none) && winner == null;

        state = state.copyWith(
          cells: newCells,
          currentPlayer: Player.x,
          winner: winner,
          winningLine: winningLine,
          isDraw: isDraw,
          isAiThinking: false,
        );

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

  void startGame(Difficulty difficulty, GameMode mode) {
    state = GameBoard.empty(
      difficulty: difficulty,
      gameMode: mode,
      isTossing: true, // The UI will see this and show the coin flip
    );
  }

  // Called when the animation finishes
  void completeToss(Player starter) {
    state = state.copyWith(isTossing: false, currentPlayer: starter);

    // If it's Single Player and AI (O) won the toss, let it move!
    if (state.gameMode == GameMode.singlePlayer && starter == Player.o) {
      _triggerAiMove();
    }
  }

  // Player? _calculateWinner(List<Player> cells) {
  //   const lines = [
  //     [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
  //     [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
  //     [0, 4, 8], [2, 4, 6], // Diagonals
  //   ];

  //   for (var line in lines) {
  //     if (cells[line[0]] != Player.none &&
  //         cells[line[0]] == cells[line[1]] &&
  //         cells[line[0]] == cells[line[2]]) {
  //       return cells[line[0]];
  //     }
  //   }
  //   return null;
  // }
  (Player?, List<int>?) _calculateWinner(List<Player> cells) {
    const lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Cols
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var line in lines) {
      if (cells[line[0]] != Player.none &&
          cells[line[0]] == cells[line[1]] &&
          cells[line[0]] == cells[line[2]]) {
        return (cells[line[0]], line);
      }
    }
    return (null, null);
  }

  // void resetGame() {
  //   /// There are two options
  //   // Option A: Use the difficulty already stored in the current game session
  //   final currentDifficulty = state.difficulty;
  //   state = GameBoard.empty(difficulty: currentDifficulty);

  //   // Option B: Always reset to whatever the user has selected on the Home Screen
  //   // state = GameBoard.empty(difficulty: ref.read(selectedDifficultyProvider));
  // }

  // void resetGame() {
  //   // Must capture the current mode and difficulty before clearing the board
  //   final currentDifficulty = state.difficulty;
  //   final currentMode = state.gameMode;

  //   // Pass them back in so the game stays in the mode the user chose
  //   state = GameBoard.empty(
  //     difficulty: currentDifficulty,
  //     gameMode: currentMode,
  //   );
  // }
  void resetGame() {
    final winner = state.winner;
    final currentDifficulty = state.difficulty;
    final currentMode = state.gameMode;

    // Update Session Scores
    int newXScore = state.playerXScore;
    int newOScore = state.playerOScore;
    if (winner == Player.x) newXScore++;
    if (winner == Player.o) newOScore++;

    // Logic: Winner starts. If draw, pick random.
    final nextStarter = winner ?? (Random().nextBool() ? Player.x : Player.o);

    state = GameBoard.empty(
      difficulty: currentDifficulty,
      gameMode: currentMode,
      currentPlayer: nextStarter,
      xScore: newXScore,
      oScore: newOScore,
      isTossing: false, // Only toss for the first game!
    );

    if (currentMode == GameMode.singlePlayer && nextStarter == Player.o) {
      _triggerAiMove();
    }
  }
}
