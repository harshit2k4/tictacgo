import '../domain/game_board.dart';
import '../domain/player.dart';

/// This is the core Mini-Max Algorithm

class AiService {
  // Set AI to be O
  static const Player aiPlayer = Player.o;
  static const Player humanPlayer = Player.x;

  /// The entry point for the AI to find the best move
  int findBestMove(GameBoard board) {
    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < 9; i++) {
      if (board.cells[i] == Player.none) {
        // Try the move
        board.cells[i] = aiPlayer;
        int score = _minimax(board, 0, false);
        // Undo the move
        board.cells[i] = Player.none;

        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }
    return move;
  }

  int _minimax(GameBoard board, int depth, bool isMaximizing) {
    // Check terminal states
    final winner = _checkWinner(board.cells);
    if (winner == aiPlayer) return 10 - depth;
    if (winner == humanPlayer) return depth - 10;
    if (!board.cells.contains(Player.none)) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board.cells[i] == Player.none) {
          board.cells[i] = aiPlayer;
          int score = _minimax(board, depth + 1, false);
          board.cells[i] = Player.none;
          bestScore = (score > bestScore) ? score : bestScore;
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board.cells[i] == Player.none) {
          board.cells[i] = humanPlayer;
          int score = _minimax(board, depth + 1, true);
          board.cells[i] = Player.none;
          bestScore = (score < bestScore) ? score : bestScore;
        }
      }
      return bestScore;
    }
  }

  // Check winner within the AI service
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
