class Match {
  final String homeTeam;
  final String awayTeam;
  final String homeScore;
  final String awayScore;
  final String status;
  final String time;
  final String leagueName;
  final String? date;

  Match({
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore = '-',
    this.awayScore = '-',
    required this.status,
    required this.time,
    required this.leagueName,
    this.date,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final homeTeamData = json['homeTeam'] as Map<String, dynamic>? ?? {};
    final awayTeamData = json['awayTeam'] as Map<String, dynamic>? ?? {};
    final leagueData = json['league'] as Map<String, dynamic>? ?? {};

    return Match(
      homeTeam: homeTeamData['name'] ?? 'Unknown',
      awayTeam: awayTeamData['name'] ?? 'Unknown',
      homeScore: json['homeScore']?.toString() ?? '-',
      awayScore: json['awayScore']?.toString() ?? '-',
      status: json['status'] ?? 'Scheduled',
      time: json['time'] ?? '--:--',
      leagueName: leagueData['name'] ?? 'Unknown League',
      date: json['date'] as String?,
    );
  }
}