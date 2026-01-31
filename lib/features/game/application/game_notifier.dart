import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/game_board.dart';
import '../domain/player.dart';

// This line is required for Riverpod code generation
// Run in terminal: dart run build_runner build
part 'game_notifier.g.dart';

@riverpod
class GameNotifier extends _$GameNotifier {
  @override
  GameBoard build() {
    // Start with an empty board
    return GameBoard.empty();
  }

  void makeMove(int index) {
    // Logic: If cell is taken or game is over, do nothing
    if (state.cells[index] != Player.none || state.winner != null) return;

    // Logic: Place the mark
    final newCells = List<Player>.from(state.cells);
    newCells[index] = state.currentPlayer;

    // Check for Winner
    final winner = _calculateWinner(newCells);

    // Check for Draw
    final isDraw = !newCells.contains(Player.none) && winner == null;

    // Update State
    state = state.copyWith(
      cells: newCells,
      currentPlayer: state.currentPlayer == Player.x ? Player.o : Player.x,
      winner: winner,
      isDraw: isDraw,
    );
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
    state = GameBoard.empty();
  }
}
