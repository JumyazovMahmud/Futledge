class Player {
  final String name;
  final String photoUrl;
  final String teamName;
  final String nationality;
  final int? age;
  final String? position;

  Player({
    required this.name,
    required this.photoUrl,
    required this.teamName,
    required this.nationality,
    this.age,
    this.position,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    final teamData = json['team'] as Map<String, dynamic>? ?? {};

    return Player(
      name: json['name'] ?? 'Unknown Player',
      photoUrl: json['photo'] ?? '',
      teamName: teamData['name'] ?? 'No Team',
      nationality: json['nationality'] ?? '',
      age: json['age'] as int?,
      position: json['position'] as String?,
    );
  }
}