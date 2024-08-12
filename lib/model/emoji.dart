class Emoji {
  final String name;
  final String url;

  const Emoji({required this.name, required this.url});

  factory Emoji.fromJson(Map<String, dynamic> json) {
    return Emoji(name: json['name'], url: json['url']);
  }

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}
