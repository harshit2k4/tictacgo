import 'package:tictacgo/features/game/domain/difficulty.dart';
import 'package:tictacgo/features/game/domain/game_mode.dart';
import 'package:tictacgo/features/game/domain/player.dart';

class GameBoard {
  final List<Player> cells;
  final Player currentPlayer;
  final Player? winner;
  final bool isDraw;
  final bool isAiThinking;
  final Difficulty difficulty;
  final GameMode gameMode;

  GameBoard({
    required this.cells,
    this.currentPlayer = Player.x,
    this.winner,
    this.isDraw = false,
    this.isAiThinking = false,
    this.difficulty = Difficulty.hard, // Default to hard
    this.gameMode = GameMode.singlePlayer, // Default to single player
  });

  // This creates a fresh, empty 3x3 grid
  factory GameBoard.empty({
    Difficulty difficulty = Difficulty.hard,
    GameMode gameMode = GameMode.singlePlayer,
  }) {
    return GameBoard(
      cells: List.generate(9, (_) => Player.none),
      difficulty: difficulty,
      gameMode: gameMode,
    );
  }

  // The 'copyWith' method is essential for Riverpod.
  // It lets us update the state safely.
  GameBoard copyWith({
    List<Player>? cells,
    Player? currentPlayer,
    Player? winner,
    bool? isDraw,
    bool? isAiThinking,
    Difficulty? difficulty,
    GameMode? gameMode,
  }) {
    return GameBoard(
      cells: cells ?? this.cells,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner ?? this.winner,
      isDraw: isDraw ?? this.isDraw,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}
