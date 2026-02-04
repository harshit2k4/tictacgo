import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Run in terminal to generate part files
/// dart run build_runner build --delete-conflicting-outputs
part 'game_stats.g.dart';

@HiveType(typeId: 0)
class GameStats extends HiveObject {
  @HiveField(0)
  int wins;

  @HiveField(1)
  int losses;

  @HiveField(2)
  int draws;

  GameStats({this.wins = 0, this.losses = 0, this.draws = 0});
}
