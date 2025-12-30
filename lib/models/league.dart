class League {
  final String id;
  final String name;
  final String country;
  final String type;
  final String logoUrl;

  League({
    required this.id,
    required this.name,
    required this.country,
    required this.type,
    required this.logoUrl,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown League',
      country: json['country'] ?? '',
      type: json['type'] ?? '',
      logoUrl: json['logo'] ?? '',
    );
  }
}