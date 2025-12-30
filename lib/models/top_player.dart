class TopPlayer {
  final int id;
  final String name;
  final int teamId;
  final String teamName;
  final int assists;
  final Map<String, dynamic> teamColors;

  TopPlayer({
    required this.id,
    required this.name,
    required this.teamId,
    required this.teamName,
    required this.assists,
    required this.teamColors,
  });

  factory TopPlayer.fromJson(Map<String, dynamic> json) {
    return TopPlayer(
      id: json['id'],
      name: json['name'],
      teamId: json['teamId'],
      teamName: json['teamName'],
      assists: json['assists'],
      teamColors: json['teamColors'],
    );
  }
}