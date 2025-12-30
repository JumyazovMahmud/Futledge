class NewsItem {
  final String title;
  final String description;
  final String imageUrl;
  final String? link;
  final String? source;

  NewsItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.link,
    this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? '',
      link: json['link'] as String?,
      source: json['source'] as String?,
    );
  }
}