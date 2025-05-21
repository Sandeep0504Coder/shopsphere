import 'dart:convert';
class Photo {
  final String public_id;
  final String url;

  Photo({
    required this.public_id,
    required this.url
  });

   Map<String, dynamic> toMap() {
    return {
      'public_id': public_id,
      'url': url,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      public_id: map['public_id'] ?? '',
      url: map['url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Photo.fromJson(String source) => Photo.fromMap(json.decode(source));
}
