class Standing {
  final int position;
  final String teamName;
  final String teamLogo;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int points;

  Standing({
    required this.position,
    required this.teamName,
    required this.teamLogo,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.points,
  });

  factory Standing.fromJson(Map<String, dynamic> json) {
    final teamData = json['team'] as Map<String, dynamic>? ?? {};

    return Standing(
      position: json['position'] as int? ?? 0,
      teamName: teamData['name'] ?? 'Unknown Team',
      teamLogo: teamData['logo'] ?? '',
      played: json['played'] as int? ?? 0,
      win: json['win'] as int? ?? 0,
      draw: json['draw'] as int? ?? 0,
      lose: json['lose'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }
}