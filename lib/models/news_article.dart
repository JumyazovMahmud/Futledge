class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String publishedAt;
  final String source;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No title',
      description: json['description'] ?? 'No description',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? '',
      source: json['source']?['name'] ?? json['source'] ?? 'Unknown',
    );
  }
}