/// Un champion et son bilan face à un adversaire donné.
class CounterPick {
  final String championId;
  final int games;
  final int wins;

  const CounterPick({
    required this.championId,
    required this.games,
    required this.wins,
  });

  double get winRate => games == 0 ? 0 : wins / games;
}
