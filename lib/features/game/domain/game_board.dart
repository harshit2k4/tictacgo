import 'package:tictacgo/features/game/domain/player.dart';

class GameBoard {
  final List<Player> cells;
  final Player currentPlayer;
  final Player? winner;
  final bool isDraw;

  GameBoard({
    required this.cells,
    this.currentPlayer = Player.x,
    this.winner,
    this.isDraw = false,
  });

  // This creates a fresh, empty 3x3 grid
  factory GameBoard.empty() {
    return GameBoard(cells: List.generate(9, (_) => Player.none));
  }

  // The 'copyWith' method is essential for Riverpod.
  // It lets us update the state safely.
  GameBoard copyWith({
    List<Player>? cells,
    Player? currentPlayer,
    Player? winner,
    bool? isDraw,
  }) {
    return GameBoard(
      cells: cells ?? this.cells,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner ?? this.winner,
      isDraw: isDraw ?? this.isDraw,
    );
  }
}
