class NewsModel {
  final int id;
  final String title;
  final String subtitle;
  final String context;
  NewsModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.context,
  });
  factory NewsModel.fromMap(Map<String, dynamic> map) => NewsModel(
      id: map['id'].toInt(),
      title: map['hline'],
      subtitle: map["seoHeadline"],
      context: map["context"]);
  Map<String, String> tomap() => {
        "title": title,
        "subtitle": subtitle,
        "context": context,
      };
}
