import 'dart:math';
import '../domain/game_board.dart';
import '../domain/player.dart';
import '../domain/difficulty.dart';

class AiService {
  static const Player aiPlayer = Player.o;
  static const Player humanPlayer = Player.x;

  int findBestMove(GameBoard board, Difficulty difficulty) {
    // EASY: Just pick a random empty spot
    if (difficulty == Difficulty.easy) {
      final availableIndices = <int>[];
      for (int i = 0; i < 9; i++) {
        if (board.cells[i] == Player.none) availableIndices.add(i);
      }
      return availableIndices[Random().nextInt(availableIndices.length)];
    }

    // MEDIUM & HARD: Use Minimax with different depth limits
    int maxDepth = (difficulty == Difficulty.medium) ? 2 : 100;

    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < 9; i++) {
      if (board.cells[i] == Player.none) {
        board.cells[i] = aiPlayer;
        int score = _minimax(board, 0, false, maxDepth);
        board.cells[i] = Player.none;

        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  int _minimax(GameBoard board, int depth, bool isMaximizing, int maxDepth) {
    final winner = _checkWinner(board.cells);
    if (winner == aiPlayer) return 10 - depth;
    if (winner == humanPlayer) return depth - 10;
    if (!board.cells.contains(Player.none) || depth >= maxDepth) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board.cells[i] == Player.none) {
          board.cells[i] = aiPlayer;
          int score = _minimax(board, depth + 1, false, maxDepth);
          board.cells[i] = Player.none;
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board.cells[i] == Player.none) {
          board.cells[i] = humanPlayer;
          int score = _minimax(board, depth + 1, true, maxDepth);
          board.cells[i] = Player.none;
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  Player? _checkWinner(List<Player> cells) {
    const lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
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
}
