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

  // Coin toss for single player
  final bool isTossing; // Is the coin currently in the air?
  final int playerXScore; // Session score for X
  final int playerOScore; // Session score for O

  GameBoard({
    required this.cells,
    this.currentPlayer = Player.x,
    this.winner,
    this.isDraw = false,
    this.isAiThinking = false,
    this.difficulty = Difficulty.hard, // Default to hard
    this.gameMode = GameMode.singlePlayer, // Default to single player
    this.isTossing = false, // Default to false
    this.playerXScore = 0, // Start at 0
    this.playerOScore = 0, // Start at 0
  });

  // This creates a fresh, empty 3x3 grid
  factory GameBoard.empty({
    Difficulty difficulty = Difficulty.hard,
    GameMode gameMode = GameMode.singlePlayer,
    Player currentPlayer = Player.x,
    bool isTossing = false,
    int xScore = 0,
    int oScore = 0,
  }) {
    return GameBoard(
      cells: List.generate(9, (_) => Player.none),
      difficulty: difficulty,
      gameMode: gameMode,
      currentPlayer: currentPlayer,
      isTossing: isTossing,
      playerXScore: xScore,
      playerOScore: oScore,
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
    bool? isTossing,
    int? playerXScore,
    int? playerOScore,
  }) {
    return GameBoard(
      cells: cells ?? this.cells,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner ?? this.winner,
      isDraw: isDraw ?? this.isDraw,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      isTossing: isTossing ?? this.isTossing,
      playerXScore: playerXScore ?? this.playerXScore,
      playerOScore: playerOScore ?? this.playerOScore,
    );
  }
}
